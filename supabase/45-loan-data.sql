-- migrate trigger: 2026-06-24 (re-run via psql workflow)
-- ================================================================
-- LOAN_DATA — เก็บข้อมูลหน้า "ลูกหนี้คงค้าง / พอร์ตสินเชื่อ" บน server
-- 1 แถว = 1 บริษัท ใส่ output ของ loanParse ไว้ใน JSONB
-- ใช้ shared ทุกอุปกรณ์/ทุกคนที่ login ผ่าน RLS (เดิมเก็บแค่ localStorage)
-- ================================================================

CREATE TABLE IF NOT EXISTS loan_data (
  company_id  uuid        PRIMARY KEY REFERENCES companies(id) ON DELETE CASCADE,
  data        jsonb       NOT NULL,
  file_name   text,
  updated_at  timestamptz NOT NULL DEFAULT now(),
  updated_by  uuid        REFERENCES auth.users(id),
  version     int         NOT NULL DEFAULT 1
);

-- Grant สิทธิ์ (กัน trigger fail ตอน insert)
GRANT ALL ON loan_data TO supabase_auth_admin;
GRANT ALL ON loan_data TO authenticated;
GRANT ALL ON loan_data TO service_role;

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_loan_data_updated_at ON loan_data;
CREATE TRIGGER trg_loan_data_updated_at
  BEFORE UPDATE ON loan_data
  FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- RLS — ใครเข้าบริษัทได้ก็อ่านได้ · admin/finance_mgr/accountant/treasury เขียนได้
ALTER TABLE loan_data ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_loan_data_read   ON loan_data;
DROP POLICY IF EXISTS p_loan_data_write  ON loan_data;
DROP POLICY IF EXISTS p_loan_data_update ON loan_data;
DROP POLICY IF EXISTS p_loan_data_delete ON loan_data;

CREATE POLICY p_loan_data_read ON loan_data FOR SELECT TO authenticated
  USING (company_id IN (SELECT fn_my_companies()));

CREATE POLICY p_loan_data_write ON loan_data FOR INSERT TO authenticated
  WITH CHECK (
    company_id IN (SELECT fn_my_companies())
    AND fn_my_role(company_id) IN ('admin','finance_mgr','accountant','treasury')
  );

CREATE POLICY p_loan_data_update ON loan_data FOR UPDATE TO authenticated
  USING (
    company_id IN (SELECT fn_my_companies())
    AND fn_my_role(company_id) IN ('admin','finance_mgr','accountant','treasury')
  )
  WITH CHECK (
    company_id IN (SELECT fn_my_companies())
    AND fn_my_role(company_id) IN ('admin','finance_mgr','accountant','treasury')
  );

CREATE POLICY p_loan_data_delete ON loan_data FOR DELETE TO authenticated
  USING (
    company_id IN (SELECT fn_my_companies())
    AND fn_my_role(company_id) IN ('admin','finance_mgr')
  );

NOTIFY pgrst, 'reload schema';
SELECT 'loan_data table created' AS result;
