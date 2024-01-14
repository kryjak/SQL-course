# Find the average salary of the male and female employees in each department.
USE employees;

# Exercise 1
# Find the average salary of the male and female employees in each department.
SELECT d.dept_name, e.gender, AVG(salary) AS avg_salary
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
         JOIN dept_emp de ON e.emp_no = de.emp_no
         JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, e.gender
ORDER BY d.dept_name;

# Exercise 2
# Find the lowest department number encountered the 'dept_emp' table. Then, find the highest department number.
SELECT MIN(dept_no), MAX(dept_no)
FROM dept_emp;

# Exercise 3
# Obtain a table containing the following three fields for all individuals whose employee number is no greater than 10040:
# - employee number
# - the smallest department number among the departments where an employee has worked in (use a subquery to retrieve this value from the 'dept_emp' table)
# - assign '110022' as 'manager' to all individuals whose employee number is less than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive (use a CASE statement to create the third field).
# If you've worked correctly, you should obtain an output containing 40 rows.
SELECT e.emp_no, MIN(de.dept_no) AS dept_name, (CASE WHEN e.emp_no <= 10020 THEN 110022 ELSE 110039 END) AS manager
FROM employees e
         JOIN dept_emp de ON e.emp_no = de.emp_no
WHERE e.emp_no <= 10040
GROUP BY e.emp_no;

# Exercise 4
# Retrieve a list with all employees that have been hired in the year 2000.
SELECT *
FROM employees
WHERE hire_date BETWEEN '2000-01-01' AND '2000-12-31';
# a slightly neater solution:
SELECT *
FROM employees
WHERE YEAR(hire_date) = 2000;

# Exercise 5
# Retrieve a list with all employees from the ‘titles’ table who are engineers.
# Repeat the exercise, this time retrieving a list with all employees from the ‘titles’ table who are senior engineers.
SELECT *
FROM titles
#WHERE title = 'Engineer'; # if we are looking for all kinds of engineers, use the option below
WHERE title LIKE '%engineer%';
#WHERE title = 'Senior Engineer'; # second subtask

# Exercise 6
# Create a procedure that asks you to insert an employee number to obtain an output containing the same number,
# as well as the number and name of the last department the employee has worked for.
# Finally, call the procedure for employee number 10010.
# If you've worked correctly, you should see that employee number 10010 has worked for department number 6 - "Quality Management".
DROP PROCEDURE IF EXISTS last_department;

DELIMITER $$
CREATE PROCEDURE last_department(IN p_emp_no INT)
BEGIN
    SELECT p_emp_no, de.dept_no, d.dept_name
    FROM dept_emp de
             JOIN departments d ON de.dept_no = d.dept_no
    WHERE de.emp_no = p_emp_no
    ORDER BY from_date DESC
    LIMIT 1;
END $$
DELIMITER ; # reset the delimiter

CALL last_department(10010);

# Exercise 7
# How many contracts have been registered in the ‘salaries’ table with duration of more than one year and of value higher than or equal to $100,000?
# Hint: You may wish to compare the difference between the start and end date of the salaries contracts.
SELECT COUNT(*)
FROM salaries
WHERE salary >= 100000
  AND DATEDIFF(to_date, from_date) > 365;

# Exercise 8
# Create a trigger that checks if the hire date of an employee is higher than the current date.
# If true, set this date to be the current date. Format the output appropriately (YY-MM-DD).
# Extra challenge: You may try to declare a new variable called 'today' which stores today's data, and then use it in your trigger!
# After creating the trigger, execute the following code to see if it's working properly.
/*
INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2050-01-01');

SELECT
    *
FROM
    employees
ORDER BY emp_no DESC;
*/

DROP TRIGGER IF EXISTS t_check_date;

DELIMITER $$
CREATE TRIGGER t_check_date
    BEFORE INSERT
    ON employees
    FOR EACH ROW
BEGIN
    IF NEW.hire_date > NOW() THEN SET new.hire_date = NOW(); END IF;
END $$
DELIMITER ;

INSERT employees
VALUES ('999999', '1970-01-31', 'John', 'Johnson', 'M', '2050-01-01');
SELECT *
FROM employees
ORDER BY emp_no DESC;

# Exercise 9
# Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356.
# Also, what is the lowest salary value per contract of the same employee? You may want to create a new function
# that will deliver this number to you.  Apply it to employee number 11356 again.

DELIMITER $$
DROP FUNCTION IF EXISTS largest_emp_salary;
CREATE FUNCTION largest_emp_salary(p_emp_no INT) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE max_salary INT;
    SELECT MAX(salary)
    INTO max_salary
    FROM employees e
             JOIN salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;

    RETURN max_salary;
END $$

DELIMITER ;

SELECT largest_emp_salary(11356);

# Exercise 10
# Based on the previous example, you can now try to create a function that accepts also a second parameter which would be a character sequence.
# Evaluate if its value is 'min' or 'max' and based on that retrieve either the lowest or the highest salary (using the same logic and code
# from Exercise 9). If this value is a string value different from ‘min’ or ‘max’, then the output of the function should return
# the difference between the highest and the lowest salary.
DELIMITER $$
DROP FUNCTION IF EXISTS minmax_emp_salary;
CREATE FUNCTION minmax_emp_salary(p_emp_no INT, p_minmax VARCHAR(10)) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE selected_salary INT;
    SELECT CASE
               WHEN p_minmax = 'min' THEN MIN(salary)
               WHEN p_minmax = 'max' THEN MAX(salary)
               ELSE MAX(salary) - MIN(salary) END
    INTO selected_salary
    FROM employees e
             JOIN salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;

    RETURN selected_salary;
END $$

DELIMITER ;

SELECT minmax_emp_salary(11356, 'max');
SELECT minmax_emp_salary(11356, 'min');
SELECT minmax_emp_salary(11356, 'afluhanwld');
