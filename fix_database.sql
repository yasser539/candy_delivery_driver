-- إصلاح قاعدة البيانات لإضافة الأعمدة المفقودة
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

-- التحقق من الهيكل
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'carts' 
ORDER BY ordinal_position;

