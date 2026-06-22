-- ================================================================
-- LEGACY SALES TABLES (stub) — orders / order_items / sku_master
-- phase0-foundation.sql + ar-module.sql อ้าง/ALTER ตารางเหล่านี้ (ของ Sales Dashboard เดิม)
-- แต่ไม่มี migration สร้างมัน (ของเดิมสร้าง ad-hoc) → DB เปล่าจะพัง
-- ไฟล์นี้สร้าง stub IF NOT EXISTS + ADD COLUMN IF NOT EXISTS → ของเดิมที่มีอยู่แล้วข้าม · DB ใหม่ได้โครงพอ
-- (โมดูล Sales Dashboard ปิดในเว็บ clone อยู่แล้ว — ตารางพวกนี้แค่ว่างไว้)
-- รันก่อน 00-phase0-foundation.sql (เรียงตามชื่อ: "00-legacy" < "00-phase0")
-- ================================================================
CREATE TABLE IF NOT EXISTS orders (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company    text,
  order_no   text,
  sale_date  date,
  iv_no      text,
  status     text,
  net_amount numeric(18,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE orders      ADD COLUMN IF NOT EXISTS net_amount numeric(18,2);

CREATE TABLE IF NOT EXISTS order_items (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company    text,
  order_no   text,
  qty        numeric(18,2),
  price      numeric(18,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS company text;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS qty     numeric(18,2);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS price   numeric(18,2);

CREATE TABLE IF NOT EXISTS sku_master (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company    text,
  sku        text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
