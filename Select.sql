USE employees;

SELECT first_name, last_name
FROM employees;
SELECT dept_no
FROM departments;

# WHERE
SELECT *
FROM employees
WHERE first_name = 'Denis';

# AND
SELECT *
FROM employees
WHERE first_name = 'Denis'
  AND gender = 'M';

# OR
SELECT *
FROM employees
WHERE first_name = 'Kellie'
   OR first_name = 'Aruna';

# OPERATOR PRECEDENCE
# AND is executed prior to OR
SELECT *
FROM employees
WHERE first_name = 'Denis' AND gender = 'M'
   OR gender = 'F'; # incorrect!
SELECT *
FROM employees
WHERE first_name = 'Denis'
  AND (gender = 'M' OR gender = 'F');
# correct!

# IN, NOT IN
SELECT *
FROM employees
WHERE first_name IN ('Cathie', 'Mark', 'Nathan');

# LIKE, NOT LIKE
SELECT *
FROM employees
WHERE first_name LIKE ('Mar%'); # matches Mark, Margaret, etc.
SELECT *
FROM employees
WHERE first_name LIKE ('%ar'); # matches Otmar, Mokhtar, Aleksandar, Volkmar, etc.
SELECT *
FROM employees
WHERE first_name LIKE ('%ar%'); # matches Mark, Margaret, Parto, Otmar, Karsten, Berhard, etc.

SELECT *
FROM employees
WHERE first_name LIKE ('Mar_');
# matches Mark, Marc, Marl, Mara, Mart, etc.
/*
% matches a sequence
_ matches a single character
Searches are case-INsensitive!
*/

# BETWEEN ... AND ...
-- gives an INCLUSIVE interval
SELECT *
FROM employees
WHERE hire_date BETWEEN '1990-01-01' AND '2000-01-01';

# <, >, >=, <=, !=
SELECT *
FROM employees
WHERE first_name != 'Denis';
#SELECT * FROM employees WHERE first_name <> 'Denis';
SELECT *
FROM employees
WHERE hire_date >= '2000-01-01';

# IS NULL, IS NOT NULL
SELECT *
FROM employees
WHERE first_name IS NULL;

# DISTINCT
SELECT DISTINCT gender
FROM employees;
SELECT DISTINCT hire_date
FROM employees;

# COUNT
-- Remember, COUNT ignores NULL values
SELECT COUNT(emp_no)
FROM employees;
SELECT COUNT(DISTINCT first_name)
FROM employees;

# ORDER BY
SELECT *
FROM employees
ORDER BY first_name;

SELECT *
FROM employees
ORDER BY first_name DESC;

SELECT *
FROM employees
ORDER BY first_name DESC, last_name ASC;

# GROUP BY
# Must be placed after WHERE, if present, and before ORDER BY
SELECT first_name, COUNT(first_name)
FROM employees
GROUP BY first_name
ORDER BY first_name
;

SELECT first_name,
       gender,
       COUNT(gender)
FROM employees
WHERE first_name LIKE 'D%'
GROUP BY first_name, gender
ORDER BY first_name
;

# ALIAS
-- AS renames a given aggregate function such that the display name is better
SELECT salary,
       COUNT(emp_no) AS emps_with_same_salary
FROM salaries
WHERE salary > 80000
GROUP BY salary
ORDER BY salary ASC;

SELECT emp_no, AVG(salary) AS 'Average salary'
FROM salaries
GROUP BY emp_no
HAVING AVG(salary) > 80000;

# HAVING
-- refines the output from records that do not satisfy a certain condition
-- frequently implemented with GROUP BY, which it must follow (and before ORDER BY)
-- acts like WHERE for the GROUP BY block
-- WHERE applies the condition *before* re-organising the output into groups
-- after HAVING, we can have a condition with an aggregate function, but for WHERE this is not possible
-- Note: HAVING cannot contain both an aggregated and a non-aggregated condition

SELECT emp_no, AVG(salary)
FROM salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000;

-- extract a list of names encountered fewer than 200 times
-- let the data refer to employees hired after 1st January 1999
SELECT first_name,
       COUNT(first_name) AS names_count
FROM employees
WHERE hire_date > '1999-01-01'
GROUP BY first_name
HAVING COUNT(first_name) < 200
ORDER BY COUNT(first_name) DESC
;

-- Select the employee numbers of all individuals who have signed more than 1 contract after the 1st of January 2000.
SELECT emp_no,
       COUNT(from_date) AS number_of_contracts
FROM dept_emp
WHERE from_date > '2000-01-01'
GROUP BY emp_no
HAVING COUNT(from_date) > 1
ORDER BY emp_no
;

# LIMIT
-- limit the number of records displayed from the query
-- Can be modified in the settings:
-- SQL edit -> SQL Execution -> Limit Rows
-- it can be also implemented using an explicit LIMIT statement at the end of the block


