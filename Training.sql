USE Sales;

CREATE TABLE IF NOT EXISTS CUSTOMERS2
(
    CUSTOMER_ID          INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    FIRST_NAME           VARCHAR(255),
    LAST_NAME            VARCHAR(255),
    EMAIL_ADDRESS        VARCHAR(255),
    NUMBER_OF_COMPLAINTS INT
);

DROP TABLE CUSTOMERS2;

USE employees;

SELECT dept_no
FROM departments;

SELECT *
FROM employees
WHERE first_name = 'Elvis';

SELECT *
FROM employees
WHERE first_name = 'Kellie'
  AND gender = 'F';

SELECT *
FROM employees
WHERE first_name = 'Kellie'
   OR first_name = 'Aruna';

SELECT *
FROM employees
WHERE gender = 'F'
  AND (first_name = 'Kellie' OR first_name = 'Aruna');

SELECT *
FROM employees
WHERE first_name IN ('Dennis', 'Elvis');

SELECT *
FROM employees
WHERE first_name NOT IN ('John', 'Mark', 'Jacob');

SELECT *
FROM employees
WHERE first_name LIKE 'Mark%';

SELECT *
FROM salaries
WHERE salary BETWEEN 66000 AND 70000;

SELECT *
FROM salaries
WHERE emp_no NOT BETWEEN 10004 AND 10012;

SELECT *
FROM departments
WHERE departments.dept_no IS NOT NULL;

SELECT *
FROM employees
WHERE gender = 'F'
  AND hire_date > '2000-01-01';

SELECT DISTINCT hire_date
FROM employees
LIMIT 10;

SELECT COUNT(*)
FROM salaries
WHERE salary >= 100000;

SELECT COUNT(*)
FROM dept_manager;

SELECT *
FROM employees
ORDER BY hire_date DESC;

SELECT emp_no, AVG(salary)
FROM salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000;

SELECT emp_no, AVG(salary)
FROM salaries
WHERE salary > 120000
GROUP BY emp_no
ORDER BY emp_no;

SELECT *
FROM salaries
WHERE emp_no = 11486;

SELECT employees.first_name, COUNT(employees.first_name) AS 'count_names '
FROM employees
WHERE hire_date > '1999-01-01'
GROUP BY first_name
HAVING COUNT(first_name) < 200
ORDER BY COUNT(first_name) DESC;

SELECT emp_no, COUNT(emp_no)
FROM dept_emp
WHERE from_date > '2000-01-01'
GROUP BY emp_no
HAVING COUNT(emp_no) > 1
ORDER BY COUNT(emp_no) DESC;