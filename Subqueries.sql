# The inner query (subquery) is executed first
# Then, SQL executes the outer query

SELECT first_name, last_name
FROM employees
WHERE emp_no IN (SELECT emp_no FROM dept_manager);

# Extract the information about all department managers who were hired between the 1st of January 1990 and the 1st of January 1995.
SELECT *
FROM dept_manager dm
WHERE dm.emp_no IN (SELECT e.emp_no FROM employees e WHERE e.hire_date BETWEEN '1990-01-01' AND '1995-01-01');

SELECT *
FROM employees e
WHERE e.emp_no IN (SELECT dm.emp_no FROM dept_manager dm)
  AND (e.hire_date BETWEEN '1990-01-01' AND '1995-01-01');

# SELECT *
# FROM employees e
#          INNER JOIN dept_manager dm ON e.emp_no = dm.emp_no
# WHERE e.hire_date BETWEEN '1990-01-01' AND '1995-01-01';

# EXISTS checks whether certain row values are found within a subquery
# this check is conducted row by row
# it returns a Boolean value
# This example from above:
# SELECT first_name, last_name
# FROM employees
# WHERE emp_no IN (SELECT emp_no FROM dept_manager);
# can be reproduced with EXISTS in the following way:

SELECT e.first_name, e.last_name
FROM employees e
WHERE EXISTS(SELECT * FROM dept_manager dm WHERE e.emp_no = dm.emp_no);

-- EXISTS is quicker in retrieving large amounts of data
-- in is faster with smaller datasets

# Select the entire information for all employees whose job title is “Assistant Engineer”.

SELECT e.*
FROM employees e
WHERE e.emp_no IN (SELECT t.emp_no FROM titles t WHERE t.title = 'Assistant Engineer');

SELECT e.*
FROM employees e
WHERE EXISTS(SELECT * FROM titles t WHERE (e.emp_no = t.emp_no) AND (t.title = 'Assistant Engineer'));

###########################
SELECT A.*
FROM (SELECT e.emp_no                AS employee_ID,
             MIN(de.dept_no)         AS department_code,
             (SELECT emp_no
              FROM dept_manager
              WHERE emp_no = 110022) AS manager_ID
      FROM employees e
               JOIN dept_emp de ON e.emp_no = de.emp_no
      WHERE e.emp_no <= 10020
      GROUP BY e.emp_no
      ORDER BY e.emp_no) AS A
UNION
SELECT B.*
FROM (SELECT e.emp_no                AS employee_ID,
             MIN(de.dept_no)         AS department_code,
             (SELECT emp_no
              FROM dept_manager
              WHERE emp_no = 110039) AS manager_ID
      FROM employees e
               JOIN dept_emp de ON e.emp_no = de.emp_no
      WHERE e.emp_no > 10020
      GROUP BY e.emp_no
      ORDER BY e.emp_no
      LIMIT 20) AS B;

# what's the point of this subquery??? This is also fine:
# 110022 AS manager_ID
# but using the subquery ensures that emp_no 110022 is actually in the database (otherwise, it will throw an error)
# also, using the aliases A and B is not necessary for the UNION

#Starting your code with “DROP TABLE”, create a table called
# “emp_manager” (emp_no – integer of 11, not null; dept_no – CHAR of 4, null; manager_no – integer of 11, not null).

DROP TABLE IF EXISTS emp_manager;
CREATE TABLE emp_manager
(
    emp_no     INT(11)    NOT NULL,
    dept_no    VARCHAR(4) NULL,
    manager_no INT(11)    NOT NULL
);

INSERT INTO emp_manager
SELECT U.*
FROM ((SELECT e.emp_no AS employee_ID, MIN(de.dept_no) AS department_code, 110022 AS manager_ID
       FROM employees e
                JOIN dept_emp de ON e.emp_no = de.emp_no
       WHERE e.emp_no <= 10020
       GROUP BY e.emp_no
       ORDER BY e.emp_no)
      UNION
      (SELECT e.emp_no AS employee_ID, MIN(de.dept_no) AS department_code, 110039 AS manager_ID
       FROM employees e
                JOIN dept_emp de ON e.emp_no = de.emp_no
       WHERE e.emp_no BETWEEN 10021 AND 10040
       GROUP BY e.emp_no
       ORDER BY e.emp_no)
      UNION
      (SELECT e.emp_no AS employee_ID, MIN(de.dept_no) AS department_code, 110039 AS manager_ID
       FROM employees e
                JOIN dept_emp de ON e.emp_no = de.emp_no
       WHERE e.emp_no = 110022
       GROUP BY e.emp_no
       ORDER BY e.emp_no)
      UNION
      (SELECT e.emp_no AS employee_ID, MIN(de.dept_no) AS department_code, 110022 AS manager_ID
       FROM employees e
                JOIN dept_emp de ON e.emp_no = de.emp_no
       WHERE e.emp_no = 110039
       GROUP BY e.emp_no
       ORDER BY e.emp_no)) AS U;

select * from emp_manager;
