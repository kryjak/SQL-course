# Stored routines allow us to reuse bits of code to save us time and effort
# They come in two types:
# 1) Stored procedures, e.g. select first column from a table and then order by something else in descending order
# 2) Stored functions (as opposed to built-in functions), e.g. we could define a function to compute a weighted average

# Routines should use a temporary delimiter, for example $$ or //
# Otherwise, when invoking the procedure, SQL will execute only until it encounters the first ; and then stop!

# DELIMITER $$ # define a temporary delimiter
# CREATE PROCEDURE procedure_name(param_1, param_2, ...)

USE employees;

DROP PROCEDURE IF EXISTS select_employees;

DELIMITER $$
CREATE PROCEDURE select_employees()
BEGIN
    SELECT * FROM employees LIMIT 10;
END $$
DELIMITER ; # reset the delimiter

CALL select_employees();

# Create a procedure that will provide the average salary of all employees
DROP PROCEDURE IF EXISTS get_avg_salary;

DELIMITER $$
CREATE PROCEDURE get_avg_salary()
BEGIN
    SELECT AVG(salary)
    FROM salaries;
END $$
DELIMITER ;

CALL get_avg_salary;

# Procedures with an input parameter
# Need to include IN and specify variable type
DROP PROCEDURE IF EXISTS emp_salary;
DELIMITER $$
CREATE PROCEDURE emp_salary(IN p_emp_no INTEGER)
BEGIN
    SELECT e.first_name,
           e.last_name,
           s.salary,
           s.from_date,
           s.to_date
    FROM employees e
             JOIN salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;
END $$

DELIMITER ;

CALL emp_salary(11300);

# Procedures can also store the outcome as an 'out' parameter
# This parameter can then be used for further applications
# Such a procedure can only return one output row
# SELECT ... INTO ... FROM

DROP PROCEDURE IF EXISTS emp_salary_out;
DELIMITER $$
CREATE PROCEDURE emp_salary_out(IN p_emp_no INTEGER, OUT p_avg_salary DECIMAL(10, 2))
BEGIN
    SELECT AVG(s.salary)
    INTO p_avg_salary
    FROM employees e
             JOIN salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;
END $$

DELIMITER ;

CALL emp_salary_out(11300, @test);

# SELECT @test, salary
# FROM salaries
# LIMIT 4;

# Create a procedure called ‘emp_info’ that uses as parameters the first and the last name of an individual, and returns their employee number.
DROP PROCEDURE IF EXISTS emp_info;
DELIMITER $$
CREATE PROCEDURE emp_info(IN p_first_name VARCHAR(14), IN p_last_name VARCHAR(16), OUT p_emp_no INT)
BEGIN
    SELECT emp_no INTO p_emp_no FROM employees WHERE first_name = p_first_name AND last_name = p_last_name LIMIT 1;
END $$

DELIMITER ;

SET @v_emp_no = 0; # select default value
CALL emp_info('Georgi', 'Facello', @v_emp_no);
SELECT @v_emp_no;

# declaring this variable is optional, however
CALL emp_info('Aruna', 'Journel', @v_emp_no_2);
SELECT @v_emp_no_2;

# Note: IN-OUT parameters exist as well. They act like a feedback loop, with the OUT variable replacing the IN variable on the next run

# Functions are similar, but:
# there are no OUT parameters, only IN
# therefore, the IN keyword might be omitted
# there's also a RETURNS keyword

DELIMITER $$
DROP FUNCTION IF EXISTS f_emp_avg_salary;
CREATE FUNCTION f_emp_avg_salary(p_emp_no INT) RETURNS DECIMAL(10, 2)
    DETERMINISTIC
BEGIN
    DECLARE v_avg_salary DECIMAL(10, 2);
    SELECT AVG(s.salary)
    INTO v_avg_salary
    FROM employees e
             JOIN salaries s ON e.emp_no = s.emp_no
    WHERE e.emp_no = p_emp_no;

    RETURN v_avg_salary;
END $$

DELIMITER ;

SELECT f_emp_avg_salary(11300);

#Create a function called ‘emp_info’ that takes for parameters the first and last name of an employee, and returns the salary from the newest contract of that employee.
# Hint: In the BEGIN-END block of this program, you need to declare and use two variables – v_max_from_date that will be of the DATE type, and v_salary, that will be of the DECIMAL (10,2) type.
# Finally, select this function.

DROP FUNCTION IF EXISTS f_emp_info;
DELIMITER $$
CREATE FUNCTION f_emp_info(p_first_name VARCHAR(14), p_last_name VARCHAR(16)) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE v_max_from_date DATE;
    DECLARE v_salary DECIMAL(10, 2);

    SELECT MAX(from_date)
    INTO v_max_from_date
    FROM salaries s
             JOIN employees e ON s.emp_no = e.emp_no
    WHERE e.first_name = p_first_name
      AND e.last_name = p_last_name;

    SELECT salary
    INTO v_salary
    FROM salaries s
             JOIN employees e ON s.emp_no = e.emp_no
    WHERE e.first_name = p_first_name
      AND e.last_name = p_last_name
      AND s.from_date = v_max_from_date;

    RETURN v_salary;
END $$
DELIMITER ;

SELECT f_emp_info('Aruna', 'Journel');

# stored procedure      | user-defined function
# -----------------------------------------------
# can have multiple     | can return only a single value
# OUT parameters        |
# ------------------------------------------------
# we can use INSERT,    | can't use any of these
# UPDATE, DELETE in a   | since a function must return a value
# procedure without an  |
# out parameter         |
# ------------------------------------------------
# are CALLed            | are SELECTed
# ------------------------------------------------
#                       | can be invoked in a SELECT statement