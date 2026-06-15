/* Count Total Rows */
SELECT COUNT(*) FROM employees_raw;  -- expect ~1160

/* Null/Empty Counts per Column */
SELECT
    COUNT(*) - COUNT(NULLIF(TRIM(employee_id),'')) AS employee_id_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(first_name),'')) AS first_name_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(last_name),'')) AS last_name_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(department),'')) AS department_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(gender),'')) AS gender_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(age),'')) AS age_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(hire_date),'')) AS hire_date_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(salary),'')) AS salary_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(employment_status),'')) AS employment_status_nulls,
    COUNT(*) - COUNT(NULLIF(TRIM(email),'')) AS email_nulls
FROM employees_raw;

/* Find Duplicate Rows */
SELECT employee_id, COUNT(*) AS occurrences
FROM employees_raw
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

/* Inconsistent Department Values */
SELECT department, COUNT(*) AS row_count
FROM employees_raw
GROUP BY department
ORDER BY department;

/* Inconsistent Gender Values */
SELECT gender, COUNT(*) AS row_count
FROM employees_raw
GROUP BY gender
ORDER BY gender;

/* Check employ status inconsistency */
SELECT employment_status, COUNT(*) AS status_count
FROM employees_raw
GROUP BY employment_status
ORDER BY employment_status;

/* Check Age data type or any incorrect values */
SELECT age, COUNT(*) AS age_count
FROM employees_raw
GROUP BY age
ORDER BY age;

/* Check if Age column values are null */
SELECT age, COUNT(*) AS age_count
FROM employees_raw
WHERE age IS NULL
OR TRIM(age) = ''
OR age REGEXP '[^0-9]'
OR (
	age REGEXP '[^0-9]+$' 
    AND (CAST(age AS SIGNED) < 18 OR CAST(age AS SIGNED) > 80)
)
GROUP BY age
ORDER BY age_count DESC;

/* Salary check */
SELECT salary, COUNT(*) AS salary_count
FROM employees_raw
WHERE salary IS NULL
OR TRIM(salary) = ''
OR salary LIKE '$%'
OR salary LIKE '% usd'
OR CAST(salary AS REAL) <= 0
GROUP BY salary
ORDER BY salary_count DESC;

/* Inconsistent Date Formats */
/* Expected Date Format: YYYY-MM-DD */
SELECT hire_date, COUNT(*) AS row_count
FROM employees_raw
WHERE
    hire_date IS NULL
    OR TRIM(hire_date) = ''
GROUP BY hire_date
ORDER BY hire_date;

/* Malformed email addresses */
SELECT email, COUNT(*) AS email_row_count
FROM employees_raw
WHERE
	email IS NULL
    OR TRIM(email) = ''
    OR email NOT LIKE '%@%'
    OR email LIKE '%@%@%'
    OR email != TRIM(email)
GROUP BY email
ORDER BY email_row_count DESC;