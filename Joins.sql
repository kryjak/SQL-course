USE employees;
/*
A join shows a result set containing fields derived from two or more tables.
We must find a related column from the two tables that contains the same type of data.
The columns must represent the same object, such as employee_id, but the tables do not have to be logically adjacent 
*/

# preparation of data
ALTER TABLE departments_duplicate 
RENAME TO departments_dup;

ALTER TABLE departments_dup
DROP COLUMN dept_manager;

ALTER TABLE departments_dup
CHANGE COLUMN dept_no dept_no CHAR(4) NULL;

ALTER TABLE departments_dup
CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL;

INSERT INTO departments_dup (dept_name)
VALUES ('Public Relations');

DELETE FROM departments_dup
WHERE
    dept_no = 'd002';
    
SELECT * FROM departments_dup;

# Create and fill in the ‘dept_manager_dup’ table, using the following code:
DROP TABLE IF EXISTS dept_manager_dup;

CREATE TABLE dept_manager_dup (
    emp_no INT NOT NULL,
    dept_no CHAR(4) NULL,
    from_date DATE NOT NULL,
    to_date DATE NULL
);
 
INSERT INTO dept_manager_dup
SELECT * FROM dept_manager;

INSERT INTO dept_manager_dup (emp_no, from_date)
VALUES
    (999904, '2017-01-01'),
    (999905, '2017-01-01'),
    (999906, '2017-01-01'),
    (999907, '2017-01-01');


DELETE FROM dept_manager_dup
WHERE
    dept_no = 'd001';
    
########### END OF PREPARATION ##############
SELECT 
    *
FROM
    dept_manager_dup
ORDER BY dept_no ASC;

SELECT 
    *
FROM
    departments_dup
ORDER BY dept_no ASC;

/* GENERIC JOIN SYNTAX
SELECT 
    t1.cols, t2.cols
FROM
    table1 t1  # alias without AS!
JOIN
    table2 t2 ON t1.cols = t2.cols;
*/

# INNER JOIN
# INNER JOIN extracts only records in which the values in the related columns match
# NULL values, or values appearing in just one of the two tables, are not displayed
# INNER JOIN = JOIN in SQL
SELECT 
    m.dept_no, m.emp_no, GROUP_CONCAT(d.dept_name) AS dept_names
FROM
    dept_manager_dup m
        INNER JOIN
    departments_dup d ON m.dept_no = d.dept_no
# GROUP BY m.emp_no # if the tables contain duplicates row, we should GROUP BY the column that differs most among records
GROUP BY m.emp_no, m.dept_no
ORDER BY m.dept_no; 

# Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date. 
SELECT 
    m.emp_no,
    m.dept_no,
    e.first_name,
    e.last_name,
    e.hire_date
FROM
    dept_manager_dup m
        INNER JOIN
    employees e ON m.emp_no = e.emp_no
ORDER BY m.emp_no;

# LEFT JOIN (= LEFT OUTER JOIN)
# returns all matching values of the two tables AND all values from the left table that match no values in the right table
-- first, remove the duplicates from our tables
DELETE FROM dept_manager_dup 
WHERE
    emp_no = '110228';
    
DELETE FROM departments_dup 
WHERE
    emp_no = 'd009';
    
INSERT INTO dept_manager_dup
VALUES ('110228', 'd003', '1992-03-21', '9999-01-01');

INSERT INTO departments_dup
VALUES ('d009', 'Customer Service');

SELECT 
    m.dept_no, m.emp_no, GROUP_CONCAT(d.dept_name) AS dept_names
FROM
    dept_manager_dup m
        LEFT JOIN
    departments_dup d ON m.dept_no = d.dept_no
# GROUP BY m.emp_no # if the tables contain duplicates row, we should GROUP BY the column that differs most among records
GROUP BY m.emp_no, m.dept_no
ORDER BY m.dept_no; 

# For left and right joins, the ordering MATTERS!
# Also note that in this case the aliases matter, i.e. be careful about the m and d in the above example
SELECT 
    d.dept_no, m.emp_no, GROUP_CONCAT(d.dept_name) AS dept_names  -- Note d.dept_no
FROM
    departments_dup d
        LEFT JOIN
    dept_manager_dup m ON m.dept_no = d.dept_no
# GROUP BY m.emp_no # if the tables contain duplicates row, we should GROUP BY the column that differs most among records
GROUP BY m.emp_no, d.dept_no
ORDER BY d.dept_no; -- Note d.dept_no

# LEFT JOIN can produce a list with all records from the left table that do not match any rows from the right table.
# Let's look at the first LEFT JOIN above and think about how we can get to these records.
# Note that such records come in two types:
# 1) They have NULL dept_no in dept_manager_dup. These will not match dept_no in departments_dup, therefore their dept_name after LEFT JOIN will be NULL.
# 2) They have non-null dept_no in dept_manager_dup, but it does not match dept_no in departments_dup. In this case, their dept_name after LEFT JOIN is also NULL.
# Therefore, we can access the values present only in the left table by looking for records after the LEFT JOIN where dept_name is NULL:
SELECT 
    m.dept_no, m.emp_no, GROUP_CONCAT(d.dept_name) AS dept_names
FROM
    dept_manager_dup m
        LEFT JOIN
    departments_dup d ON m.dept_no = d.dept_no
WHERE
    dept_name IS NULL
GROUP BY m.emp_no, m.dept_no
ORDER BY m.dept_no; 

# Join the 'employees' and the 'dept_manager' tables to return a subset of all the employees whose last name is Markovitch. See if the output contains a manager with that name.
SELECT 
    e.emp_no, GROUP_CONCAT(e.first_name) first_name, GROUP_CONCAT(e.last_name) last_name, GROUP_CONCAT(d.dept_no) dept_no, GROUP_CONCAT(d.from_date) from_date
FROM
    employees e
        LEFT JOIN
    dept_manager d ON e.emp_no = d.emp_no
WHERE
    e.last_name = 'Markovitch'
GROUP BY e.emp_no, d.dept_no
ORDER BY d.dept_no DESC, e.emp_no DESC; 

# RIGHT JOIN (= RIGHT OUTER JOIN)
# returns all matching values of the two tables AND all values from the right table that match no values in the left table

# OLD VS NEW SYNTAX
# It is also possible to obtain the result of the INNER JOIN using a normal SELECT clause with a condition:
/* 
SELECT
    t1.col1, t1.col2, ..., t2.col1, t2.col2, ...
FROM
    table_1 t1,
    table_2 t2
WHERE
    t1.coln = t2.colm;
*/
# This gives the same as the INNER JOIN above:
SELECT m.dept_no, m.emp_no, GROUP_CONCAT(d.dept_name) AS dept_names
FROM
    dept_manager_dup m,
    departments_dup d
WHERE m.dept_no = d.dept_no
GROUP BY m.emp_no, m.dept_no
ORDER BY m.dept_no;
# But using WHERE is slower and so its use in this case is obsolete
# Moreover, with JOIN we can join more than two tables

# Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date.
# Use the old type of join syntax to obtain the result.
SELECT d.emp_no, e.first_name, e.last_name, d.dept_no, e.hire_date
FROM
    dept_manager d,
    employees e
WHERE
    d.emp_no = e.emp_no
;

# Note that JOIN and WHERE can be used together, for example:
SELECT 
    e.emp_no, e.first_name, e.last_name, s.salary
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    s.salary > 145000;
    
# Select the first and last name, the hire date, and the job title of all employees whose first name is “Margareta” and have the last name “Markovitch”.
SELECT 
    e.emp_no, e.first_name, e.last_name, e.hire_date, t.title
FROM
    employees e
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE
    e.first_name = 'Margareta' AND e.last_name = 'Markovitch';
    
# CROSS JOIN
# Takes values from a certain table and connects them with all the values from the tables we want to join it with.
# INNER JOIN connects only the matching values, CROSS JOIN connects all the values, not just those that match.
# It is the Cartesian product of all the values of two or more sets.
# Particularly useful when the tables in a database are not well connected.
# CROSS JOIN can be applied two more than two tables, but the result might quickly become too big!
# In the following example, each employee number from 'dept_manager' gets connected to ALL the possible departments from the 'departments' table:
SELECT 
    dm.*, d.*
FROM
    dept_manager dm
        CROSS JOIN
    departments d
ORDER BY dm.emp_no , d.dept_no;
# The same can be achieved in the 'old' syntax:
SELECT 
    dm.*, d.*
FROM
    dept_manager dm,
    departments d
ORDER BY dm.emp_no , d.dept_no;
# or even using a normal join, but without ON:
SELECT 
    dm.*, d.*
FROM
    dept_manager dm
        JOIN
    departments d
ORDER BY dm.emp_no , d.dept_no;
# Using JOIN without ON is not good practice, use CROSS JOIN instead!

# This will not include the duplicate department number:
SELECT 
    dm.*, d.*
FROM
    dept_manager dm
        CROSS JOIN
    departments d
WHERE
    d.dept_no <> dm.dept_no
ORDER BY dm.emp_no , d.dept_no;

# Different types of joins can be combined too:
SELECT 
    e.*, d.*
FROM
    departments d
        CROSS JOIN
    dept_manager dm
        JOIN
    employees e ON dm.emp_no = e.emp_no
WHERE
    d.dept_no <> dm.dept_no
ORDER BY dm.emp_no , d.dept_no;

# Use a CROSS JOIN to return a list with all possible combinations between managers from the dept_manager table and department number 9.
SELECT 
    dm.*, d.*
FROM
    dept_manager dm
        CROSS JOIN
    departments d
WHERE
    d.dept_no = 'd009'
ORDER BY d.dept_no;

# Return a list with the first 10 employees with all the departments they can be assigned to.
select emp_no from employees;

SELECT 
    e.*, d.*
FROM
    employees e
        CROSS JOIN
    departments d
WHERE
    e.emp_no < 10011
ORDER BY e.emp_no, d.dept_no;