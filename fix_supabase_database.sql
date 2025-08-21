-- إصلاح قاعدة البيانات في Supabase
-- تشغيل هذا الملف في Supabase SQL Editor

-- إضافة الأعمدة المفقودة
ALTER TABLE carts ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS driver_id TEXT;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS pickup_location JSONB;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS delivery_location JSONB;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS picked_up_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE carts ADD COLUMN IF NOT EXISTS notes TEXT;

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_carts_driver_id ON carts(driver_id);
CREATE INDEX IF NOT EXISTS idx_carts_status ON carts(status);
CREATE INDEX IF NOT EXISTS idx_carts_created_at ON carts(created_at);

-- تحديث البيانات الموجودة
UPDATE carts 
SET 
  customer_name = 'عميل تجريبي ' || substr(id, 1, 8),
  customer_phone = '+96650' || substr(id, 1, 8),
  pickup_location = '{"latitude": 24.7136, "longitude": 46.6753, "address": "الرياض، المملكة العربية السعودية"}',
  delivery_location = '{"latitude": 24.7136, "longitude": 46.6753, "address": "الرياض، المملكة العربية السعودية"}',
  notes = 'طلب تجريبي'
WHERE customer_name IS NULL;

-- إضافة بيانات تجريبية جديدة
INSERT INTO carts (id, customer_id, customer_name, customer_phone, pickup_location, delivery_location, status, total_amount, created_at, updated_at, notes)
VALUES 
  ('test-cart-1', 'customer-1', 'أحمد محمد', '+966501234567', 
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع الملك فهد، الرياض"}',
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع التحلية، الرياض"}',
   'pending', 45.0, NOW(), NOW(), 'طلب تجريبي 1'),
   
  ('test-cart-2', 'customer-2', 'فاطمة علي', '+966507654321',
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع العليا، الرياض"}',
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع النزهة، الرياض"}',
   'pending', 30.0, NOW(), NOW(), 'طلب تجريبي 2'),
   
  ('test-cart-3', 'customer-3', 'محمد عبدالله', '+966505555555',
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع الثمامة، الرياض"}',
   '{"latitude": 24.7136, "longitude": 46.6753, "address": "شارع الملك عبدالله، الرياض"}',
   'pending', 55.0, NOW(), NOW(), 'طلب تجريبي 3')
ON CONFLICT (id) DO NOTHING;

-- التحقق من الهيكل
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'carts' 
ORDER BY ordinal_position;

-- جدول الحضور اليومي للمندوب/الكابتن
CREATE TABLE IF NOT EXISTS driver_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id TEXT NOT NULL,
  check_in_at TIMESTAMPTZ NOT NULL,
  check_in_location JSONB,
  check_out_at TIMESTAMPTZ,
  check_out_location JSONB,
  duration_minutes INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_attendance_driver_month
  ON driver_attendance(driver_id, check_in_at);

-- جدول تتبع الموقع الحالي
CREATE TABLE IF NOT EXISTS driver_live_locations (
  driver_id TEXT PRIMARY KEY,
  location JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

