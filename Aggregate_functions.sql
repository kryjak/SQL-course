/*
Functions such as COUNT(), SUM(), MIN(), MAX(), AVG() are known as aggregate functions, or summary functions
COUNT() can be used with both numeric and non-numeric data
But SUM(), MIN(), MAX(), AVG() can only be used with numeric data
*/

# COUNT ignore NULL values if we specify a column name in the argument, e.g. COUNT(salary)
# But COUNT(*) will include NULL values

# How many departments are there in the “employees” database? Use the ‘dept_emp’ table to answer the question.
USE employees;

SELECT COUNT(DISTINCT dept_no)
FROM dept_emp;

# What is the total amount of money spent on salaries for all contracts starting after the 1st of January 1997?
SELECT SUM(salary) AS 'total salaries'
FROM salaries
WHERE from_date > '1997-01-01';

# Which is the highest/lowest employee number in the database?
SELECT MAX(emp_no) -- Min(emp_no)
FROM employees;

# What is the average annual salary paid to employees who started after the 1st of January 1997?
SELECT ROUND(AVG(salary), 2) -- ROUND(number, decimal places)
FROM salaries
WHERE from_date > '1997-01-01';

-- preparation for COALESCE
DELETE
FROM departments_duplicate
WHERE dept_no = 'd010';

ALTER TABLE departments_duplicate
    CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL,
    ADD COLUMN dept_manager VARCHAR(255) NULL AFTER dept_name;

INSERT INTO departments_duplicate (dept_no)
VALUES ('d010'),
       ('d011');

COMMIT;

SELECT *
FROM departments_duplicate;

-- end of preparation

-- IFNULL(expr1, expr2) returns expr1 if the data value found in the table is NOT null and returns expr2 if the value is NULL
SELECT dept_no, IFNULL(dept_name, 'Department name not provided') AS 'dept_name'
FROM departments_duplicate;

-- COALESCE(expr1, expr2, ..., exprN) is similar, it will return the first non-null value when reading from left to right
SELECT dept_no, dept_name, COALESCE(dept_manager, dept_name, 'N/A') AS 'dept_manager'
FROM departments_duplicate
ORDER BY dept_no ASC;

-- A nice COALESCE trick:
SELECT
    dept_no, dept_name, COALESCE('fake col') AS dept_info
FROM
    departments_duplicate
ORDER BY dept_no;
# But note this doesn't work with ISNULL, as it takes precisely two arguments