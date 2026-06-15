-- 1. Final row count (~1100, no duplicates) -------------
SELECT 
	COUNT(*) 
AS 
	final_row_count 
FROM 
	employees_clean;
    
-- 2. Unique Employee ID's -------------
SELECT
	employee_id, 
    COUNT(*) AS emp_count
FROM 
	employees_clean
GROUP BY 
	employee_id
HAVING COUNT(*) > 1;

 -- -- -- -- 3. Canonical Department Values  -------------
SELECT 
	department, 
	COUNT(*) AS department_count
FROM 
	employees_clean
GROUP BY 
	department 
ORDER BY 
	department;
    
 -- -- 4. Canonical Gender Values  -------------
SELECT gender, 
	COUNT(*) AS gender_count
FROM
	employees_clean
GROUP BY 
	gender
ORDER BY
	gender;
    
 -- -- 5. Make sure only 3 valid employment statuses -------------
SELECT 
	employment_status,
	COUNT(*) AS emp_status
FROM 
	employees_clean
GROUP BY
	employment_status
ORDER BY
	employment_status;
    
 -- -- 6. Age confirmation (valid range) -------------
SELECT 
	MIN(age) AS min_age,
    MAX(age) AS max_age,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_ages
FROM employees_clean;

 -- -- Check ages -------------
SELECT age FROM employees_clean;

 -- -- 7. Check Salaries -------------
SELECT
	MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_ages
FROM employees_clean;

 -- -- 8. Hire Date Format -------------
SELECT 
    hire_date,
    COUNT(*) AS date_cnt
FROM 
    employees_clean
WHERE 
    hire_date IS NOT NULL
    -- Matches the standard 4-digit year, 2-digit month, 2-digit day pattern
    AND hire_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
GROUP BY 
    hire_date;
    
 -- -- 9. Confirm Email Format is Valid -------------
SELECT
	email,
    COUNT(*) AS email_cnt
FROM 
	employees_clean
WHERE 
	email IS NOT NULL
AND (email != LOWER(email) OR email NOT LIKE '%@%')
GROUP BY email;

 -- -- 10. NULL summary for the clean table -------------
SELECT 
    SUM(employee_id IS NULL) AS employee_id_nulls,
    SUM(first_name IS NULL) AS first_name_nulls,
    SUM(last_name IS NULL) AS last_name_nulls,
    SUM(department IS NULL) AS department_nulls,
    SUM(gender IS NULL) AS gender_nulls,
    SUM(age IS NULL) AS age_nulls,
    SUM(hire_date IS NULL) AS hire_date_nulls,
    SUM(salary IS NULL) AS salary_nulls,
    SUM(employment_status IS NULL) AS employment_status_nulls,
    SUM(email IS NULL) AS email_nulls
FROM employees_clean;