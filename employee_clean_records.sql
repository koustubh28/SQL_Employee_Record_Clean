-- ============================================================
--  DATA CLEANING PROJECT — EMPLOYEE RECORDS
--  SKILLS USED (exactly 5):
--   1. TRIM()               — remove leading/trailing whitespace
--   2. UPPER() / LOWER()    — normalize case for comparisons
--   3. CASE WHEN            — map dirty categorical values to
--                             canonical ones; handle bad data
--   4. CAST()               — convert text to correct data types
--   5. ROW_NUMBER() OVER()  — deduplicate with a window function
-- ============================================================

-- ── STAGE A: Remove exact duplicate rows ─────────────────────
DROP TABLE IF EXISTS employees_deduped;

CREATE TABLE employees_deduped AS 
SELECT 
  employee_id, 
  first_name, 
  last_name, 
  department, 
  gender, 
  age, 
  hire_date, 
  salary, 
  employment_status, 
  email 
FROM 
  (
    SELECT 
      *, 
      ROW_NUMBER() OVER(
        PARTITION BY employee_id 
        ORDER BY employee_id
      ) AS rn 
    FROM 
      employees_raw
  ) ranked 
WHERE 
  rn = 1;

-- Verify: duplicate employee_ids should now be zero
SELECT 
  employee_id, 
  COUNT(*) AS emp_count 
FROM 
  employees_deduped 
GROUP BY 
  employee_id 
HAVING 
  COUNT(*) > 1;


-- ── STAGE B: Build clean table ───────────────────────────────
DROP TABLE IF EXISTS employees_clean;

CREATE TABLE employees_clean AS 
SELECT 
  CAST(employee_id AS UNSIGNED) AS employee_id, 
  TRIM(first_name) AS first_name, 
  TRIM(last_name) AS last_name, 
  
  -- Fixed: All matching array tokens standardized to UPPERCASE
  CASE 
    WHEN UPPER(TRIM(department)) IN ('SALESS', 'SALES', 'SALE') THEN 'Sales' 
    WHEN UPPER(TRIM(department)) IN ('ENGINEERING', 'ENGINERING', 'ENG') THEN 'Engineering' 
    WHEN UPPER(TRIM(department)) IN ('MARKETING', 'MARKTING', 'MKTG') THEN 'Marketing' 
    WHEN UPPER(TRIM(department)) IN ('HR', 'HUMAN RESOURCES') THEN 'HR' 
    WHEN UPPER(TRIM(department)) IN ('FINANCE', 'FINANCEE', 'FIN') THEN 'Finance' 
    ELSE NULL 
  END AS department, 
  
  -- Fixed: All matching array tokens standardized to UPPERCASE
  CASE 
    WHEN UPPER(TRIM(gender)) IN ('MALE', 'M') THEN 'Male' 
    WHEN UPPER(TRIM(gender)) IN ('FEMALE', 'F') THEN 'Female' 
    ELSE NULL 
  END AS gender, 
  
  -- Age Cleanup
  CASE 
    WHEN TRIM(age) IS NULL OR TRIM(age) = '' THEN NULL 
    WHEN REGEXP_REPLACE(TRIM(age), '[^0-9]', '') = '' THEN NULL 
    WHEN CAST(REGEXP_REPLACE(TRIM(age), '[^0-9]', '') AS UNSIGNED) BETWEEN 18 AND 80 
      THEN CAST(REGEXP_REPLACE(TRIM(age), '[^0-9]', '') AS UNSIGNED) 
    ELSE NULL 
  END AS age, 
  
  -- Hire Date Cleanup
  CASE 
    WHEN TRIM(hire_date) IS NULL OR TRIM(hire_date) = '' THEN NULL 
    WHEN TRIM(hire_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
      THEN STR_TO_DATE(TRIM(hire_date), '%Y-%m-%d') 
    WHEN TRIM(hire_date) LIKE '%/%' 
      THEN STR_TO_DATE(TRIM(hire_date), '%m/%d/%Y') 
    WHEN TRIM(hire_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' 
      THEN STR_TO_DATE(TRIM(hire_date), '%d-%m-%Y') 
    ELSE NULL 
  END AS hire_date, 
  
  -- Salary Cleanup
-- ── Salary Cleanup (Fixed Error 1292) ───────────────────────
  CASE 
    WHEN TRIM(salary) IS NULL OR TRIM(salary) = '' THEN NULL 
    
    -- 1. Strip symbols. Cast to DECIMAL first to safely handle floating points like '125000.0'
    WHEN CAST(REGEXP_REPLACE(TRIM(salary), '[$, ]|USD', '') AS DECIMAL(10, 2)) <= 0 THEN NULL 
    
    -- 2. Pass through DECIMAL first, then convert to UNSIGNED integer to drop the trailing decimals safely
    ELSE CAST(CAST(REGEXP_REPLACE(TRIM(salary), '[$, ]|USD', '') AS DECIMAL(10, 2)) AS UNSIGNED)
  END AS salary,  
  -- Employment Status Cleanup
  CASE 
    WHEN TRIM(employment_status) LIKE 'activ%' THEN 'Active' 
    WHEN TRIM(employment_status) LIKE 'in-activ%' THEN 'Inactive' 
    WHEN TRIM(employment_status) LIKE 'inactiv%' THEN 'Inactive' 
    WHEN TRIM(employment_status) LIKE '%leave%' THEN 'On Leave' 
    ELSE NULL 
  END AS employment_status, 
  
  -- Email Cleanup
  CASE 
    WHEN TRIM(email) IS NULL OR TRIM(email) = '' THEN NULL 
    WHEN TRIM(email) NOT LIKE '%%@%%' THEN NULL 
    ELSE LOWER(TRIM(email)) 
  END AS email 
FROM 
  employees_deduped;