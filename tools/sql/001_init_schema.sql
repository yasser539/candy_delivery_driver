-- ci: trigger apply-schema workflow on push (no-op change)
-- ========= Enums (match Dart enum names) =========
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE public.user_role AS ENUM ('customer','driver','admin');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE public.order_status AS ENUM ('pending','paid','preparing','out_for_delivery','delivered','canceled');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'delivery_status') THEN
    CREATE TYPE public.delivery_status AS ENUM ('pending','assigned','picked_up','in_transit','delivered','failed','returned');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
    CREATE TYPE public.payment_status AS ENUM ('unpaid','paid','refunded','failed');
  END IF;
END$$;

-- ========= Extensions =========
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

-- ========= Update timestamp trigger =========
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END $$;

-- ========= Tables =========

-- user_profiles
CREATE TABLE IF NOT EXISTS public.user_profiles (
  user_id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name  text,
  phone      text,
  role       public.user_role NOT NULL DEFAULT 'customer',
  created_at timestamptz NOT NULL DEFAULT NOW(),
  updated_at timestamptz NOT NULL DEFAULT NOW()
);
DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_updated_at
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- user_addresses
CREATE TABLE IF NOT EXISTS public.user_addresses (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  label      text,
  line1      text NOT NULL,
  line2      text,
  city       text NOT NULL,
  state      text,
  postal_code text,
  country    text NOT NULL DEFAULT 'US',
  lat        double precision,
  lng        double precision,
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT NOW(),
  updated_at timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON public.user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_addresses_default ON public.user_addresses(user_id) WHERE is_default;
DROP TRIGGER IF EXISTS trg_user_addresses_updated_at ON public.user_addresses;
CREATE TRIGGER trg_user_addresses_updated_at
BEFORE UPDATE ON public.user_addresses
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- app_orders
CREATE TABLE IF NOT EXISTS public.app_orders (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  address_id          uuid REFERENCES public.user_addresses(id) ON DELETE SET NULL,
  cart_id             uuid,
  status              public.order_status NOT NULL DEFAULT 'pending',
  payment_status      public.payment_status NOT NULL DEFAULT 'unpaid',
  subtotal_cents      integer NOT NULL DEFAULT 0,
  delivery_fee_cents  integer NOT NULL DEFAULT 0,
  total_cents         integer NOT NULL DEFAULT 0,
  notes               text,
  created_at          timestamptz NOT NULL DEFAULT NOW(),
  updated_at          timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_app_orders_user_id ON public.app_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_app_orders_created_at ON public.app_orders(created_at DESC);
DROP TRIGGER IF EXISTS trg_app_orders_updated_at ON public.app_orders;
CREATE TRIGGER trg_app_orders_updated_at
BEFORE UPDATE ON public.app_orders
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- app_delivery_tracking (one row per order)
CREATE TABLE IF NOT EXISTS public.app_delivery_tracking (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     uuid NOT NULL REFERENCES public.app_orders(id) ON DELETE CASCADE,
  driver_id    uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  status       public.delivery_status NOT NULL DEFAULT 'pending',
  scheduled_at timestamptz,
  picked_up_at timestamptz,
  delivered_at timestamptz,
  notes        text,
  created_at   timestamptz NOT NULL DEFAULT NOW(),
  updated_at   timestamptz NOT NULL DEFAULT NOW(),
  UNIQUE(order_id)
);
CREATE INDEX IF NOT EXISTS idx_tracking_driver_status ON public.app_delivery_tracking(driver_id, status);
DROP TRIGGER IF EXISTS trg_app_delivery_tracking_updated_at ON public.app_delivery_tracking;
CREATE TRIGGER trg_app_delivery_tracking_updated_at
BEFORE UPDATE ON public.app_delivery_tracking
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- app_delivery_events (append-only trail)
CREATE TABLE IF NOT EXISTS public.app_delivery_events (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id uuid NOT NULL REFERENCES public.app_delivery_tracking(id) ON DELETE CASCADE,
  status      public.delivery_status NOT NULL,
  note        text,
  location    jsonb,
  created_at  timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_delivery_events_delivery ON public.app_delivery_events(delivery_id);
CREATE INDEX IF NOT EXISTS idx_delivery_events_created ON public.app_delivery_events(created_at);

-- app_payments
CREATE TABLE IF NOT EXISTS public.app_payments (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     uuid NOT NULL REFERENCES public.app_orders(id) ON DELETE CASCADE,
  provider     text NOT NULL,
  provider_ref text,
  amount_cents integer NOT NULL,
  currency     text NOT NULL DEFAULT 'USD',
  status       public.payment_status NOT NULL DEFAULT 'unpaid',
  created_at   timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_app_payments_order ON public.app_payments(order_id);

-- ========= Compatibility view (repo fallback from 'orders') =========
CREATE OR REPLACE VIEW public.orders AS
  SELECT * FROM public.app_orders;

-- ========= RLS Policies =========

-- Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_delivery_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_delivery_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_payments ENABLE ROW LEVEL SECURITY;

-- user_profiles: only owner can read/write their profile
DROP POLICY IF EXISTS up_select_own ON public.user_profiles;
CREATE POLICY up_select_own ON public.user_profiles
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS up_insert_own ON public.user_profiles;
CREATE POLICY up_insert_own ON public.user_profiles
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS up_update_own ON public.user_profiles;
CREATE POLICY up_update_own ON public.user_profiles
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- user_addresses: only owner can CRUD
DROP POLICY IF EXISTS ua_select_own ON public.user_addresses;
CREATE POLICY ua_select_own ON public.user_addresses
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS ua_insert_own ON public.user_addresses;
CREATE POLICY ua_insert_own ON public.user_addresses
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS ua_update_own ON public.user_addresses;
CREATE POLICY ua_update_own ON public.user_addresses
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS ua_delete_own ON public.user_addresses;
CREATE POLICY ua_delete_own ON public.user_addresses
  FOR DELETE USING (user_id = auth.uid());

-- app_orders: customer (owner) can read/write own orders
DROP POLICY IF EXISTS ao_select_owner ON public.app_orders;
CREATE POLICY ao_select_owner ON public.app_orders
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS ao_insert_owner ON public.app_orders;
CREATE POLICY ao_insert_owner ON public.app_orders
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS ao_update_owner ON public.app_orders;
CREATE POLICY ao_update_owner ON public.app_orders
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- app_delivery_tracking: driver or order owner can read; only driver can update their deliveries
DROP POLICY IF EXISTS dt_select_driver_or_owner ON public.app_delivery_tracking;
CREATE POLICY dt_select_driver_or_owner ON public.app_delivery_tracking
  FOR SELECT USING (
    driver_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.app_orders o
      WHERE o.id = order_id AND o.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS dt_update_driver ON public.app_delivery_tracking;
CREATE POLICY dt_update_driver ON public.app_delivery_tracking
  FOR UPDATE USING (driver_id = auth.uid()) WITH CHECK (driver_id = auth.uid());

-- app_delivery_events: visible to driver or owner; driver can insert events
DROP POLICY IF EXISTS de_select_driver_or_owner ON public.app_delivery_events;
CREATE POLICY de_select_driver_or_owner ON public.app_delivery_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.app_delivery_tracking t
      JOIN public.app_orders o ON o.id = t.order_id
      WHERE t.id = delivery_id
        AND (t.driver_id = auth.uid() OR o.user_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS de_insert_driver ON public.app_delivery_events;
CREATE POLICY de_insert_driver ON public.app_delivery_events
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.app_delivery_tracking t
      WHERE t.id = delivery_id AND t.driver_id = auth.uid()
    )
  );

-- app_payments: owner can read
DROP POLICY IF EXISTS pay_select_owner ON public.app_payments;
CREATE POLICY pay_select_owner ON public.app_payments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.app_orders o WHERE o.id = order_id AND o.user_id = auth.uid()
    )
  );

-- Note: Inserts/updates to tracking, events, and payments are typically performed by backend/service role.
-- Service role bypasses RLS, so no additional policies are required for it.
