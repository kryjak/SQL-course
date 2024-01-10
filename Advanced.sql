# VARIABLES TYPES
# LOCAL VARIABLES are visible only in the BEGIN-END block
# the DECLARE keyword can be used to create local variables only

# A session is a series of information exchange interactions between a computer and a user
# It is a dialogue between the MySQL server and a client application like DataGrip or MySQL Workbench
# It is possible to create SESSION VARIABLES

SET @s_var1 = 3;
SELECT @s_var1;
# this will be visible in this session but not in another one

# To declare GLOBAL VARIABLES:
# SET GLOBAL var = value;
# Or
# SET @@global.var = value;
# Not any variable can be declared global. A specific group of SQL variables which can be declared as global
# is called 'system variables'
SET GLOBAL MAX_CONNECTIONS = 1;
SET @@global.max_connections = 1;

# Local variables can only be user-defined
# Only system variables can be set as global
# Both user-defined and system variables can be used as session variables

#########################################################################
# TRIGGERS
# A trigger is a type of a stored programme associated with a table that will be activated automatically once a
# specific event occurs. It must be associated to a table and represented by INSERT, UPDATE or DELETE
# There are 'before' and 'after' triggers

USE employees;
COMMIT;

# Let's create an BEFORE INSERT trigger
DELIMITER $$
DROP TRIGGER IF EXISTS before_salaries_insert;
CREATE TRIGGER before_salaries_insert
    BEFORE INSERT
    ON salaries
    FOR EACH ROW
BEGIN
    IF new.salary < 0 THEN
        SET new.salary = 0;
    END IF;
END $$

DELIMITER ;

INSERT INTO salaries
VALUES ('10001', -92342, '2010-06-22', '9999-01-01');

SELECT *
FROM salaries
WHERE emp_no = '10001';
# the salary is changed to 0

# Let's now create a BEFORE UPDATE trigger
DELIMITER $$
DROP TRIGGER IF EXISTS before_salaries_update;
CREATE TRIGGER before_salaries_update
    BEFORE UPDATE
    ON salaries
    FOR EACH ROW
BEGIN
    IF new.salary < 0 THEN
        SET new.salary = OLD.salary;
    END IF;
END $$

DELIMITER ;

UPDATE salaries
SET salary = 98765
WHERE emp_no = '10001'
  AND from_date = '2010-06-22';

SELECT *
FROM salaries
WHERE emp_no = '10001'
  AND from_date = '2010-06-22';
# the salary is successfully updated
# now let's try to update with a negative value

UPDATE salaries
SET salary = -10235987
WHERE emp_no = '10001'
  AND from_date = '2010-06-22';

SELECT *
FROM salaries
WHERE emp_no = '10001'
  AND from_date = '2010-06-22';
# the old salary is kept

# SYSTEM FUNCTIONS often provide data about the moment of the execution of a certain query
SELECT SYSDATE();

####################
# a new employee has been promoted to a manager
# ➢ annual salary should immediately become 20,000 dollars higher than
#   the highest annual salary they’d ever earned until that moment
# ➢ a new record in the “department manager” table
# ➢ create a trigger that will apply several modifications to the
# “salaries” table once the relevant record in the “department
# manager” table has been inserted:
#   • make sure that the end date of the previously highest salary contract
#   of that employee is the one from the execution of the insert statement
#   • insert a new record in the “salaries” table about the same employee
#   that reflects their next contract as a manager
#   • a start date the same as the new “from date” from the newly
#   inserted record in “department manager”
#   • a salary equal to 20,000 dollars higher than their highest-ever
#   salary
#   • let that be a contract of indefinite duration ('9999-01-01')

DELIMITER $$

CREATE TRIGGER trig_ins_dept_mng
    AFTER INSERT
    ON dept_manager
    FOR EACH ROW
BEGIN
    DECLARE v_curr_salary INT;

    SELECT MAX(salary) INTO v_curr_salary FROM salaries WHERE emp_no = NEW.emp_no;

    IF v_curr_salary IS NOT NULL THEN
        UPDATE salaries SET to_date = SYSDATE() WHERE emp_no = NEW.emp_no AND to_date = NEW.to_date;

        INSERT INTO salaries VALUES (NEW.emp_no, v_curr_salary + 20000, NEW.from_date, NEW.to_date);

    END IF;
END $$

DELIMITER ;

INSERT INTO dept_manager
VALUES ('111534', 'd009', DATE_FORMAT(SYSDATE(), '%Y-%m-%d'), '9999-01-01');

SELECT *
FROM dept_manager
WHERE emp_no = 111534;

SELECT *
FROM salaries
WHERE emp_no = 111534;

#delete from salaries where emp_no = '111534' and to_date = '2003-01-27';
#insert into salaries VALUES ('111534', 79393, '2002-01-27', '9999-01-01');
#COMMIT;
#ROLLBACK;

# Create a trigger that checks if the hire date of an employee is higher than the current date.
# If true, set this date to be the current date. Format the output appropriately (YY-MM-DD).

DELIMITER $$
CREATE TRIGGER trig_check_date
    BEFORE INSERT
    ON employees
    FOR EACH ROW
BEGIN
    IF NEW.hire_date > DATE_FORMAT(SYSDATE(), '%Y-%m-%d') THEN
        SET NEW.hire_date = DATE_FORMAT(SYSDATE(), '%Y-%m-%d');
    END IF;
END $$
DELIMITER ;

INSERT employees
VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2099-01-01');

SELECT *
FROM employees
ORDER BY emp_no DESC;

# an INDEX increases the retrieval speed of information from a table
# CREATE INDEX index_name
# ON table_name (col1, col2, ...);

SELECT *
FROM employees
WHERE hire_date > '2000-01-01'; # 265ms

CREATE INDEX i_hire_date ON employees (hire_date);

SELECT *
FROM employees
WHERE hire_date > '2000-01-01'; # 106ms

SHOW INDEXES FROM employees FROM employees;

# to drop the index:
ALTER TABLE employees
    DROP INDEX i_hire_date;

# CASE statement
SELECT emp_no,
       first_name,
       last_name,
       CASE
           WHEN gender = 'M' THEN 'Male'
           ELSE 'Female' END AS gender
FROM employees;
# Same result:
SELECT emp_no,
       first_name,
       last_name,
       CASE gender
           WHEN 'M' THEN 'Male'
           ELSE 'Female' END AS gender
FROM employees;
# Same result:
SELECT emp_no,
       first_name,
       last_name,
       IF(gender = 'M', 'Male', 'Female') AS gender
FROM employees;

# Note that case allows us to enter multiple condition, whereas IF can only handle one condition

# Similar to the exercises done in the lecture, obtain a result set containing the employee number, first name
# and last name of all employees with a number higher than 109990.
# Create a fourth column in the query, indicating whether this employee is also a manager, according to the data
# provided in the dept_manager table, or a regular employee.

SELECT emp_no,
       first_name,
       last_name,
       CASE
           WHEN e.emp_no IN (SELECT emp_no FROM dept_manager) THEN 'Manager'
           ELSE 'Employee' END AS role
FROM employees e
WHERE emp_no > 109990;

# Extract a dataset containing the following information about the managers: employee number, first name, and last name.
# Add two columns at the end – one showing the difference between the maximum and minimum salary of that employee,
# and another one saying whether this salary raise was higher than $30,000 or NOT.

SELECT dm.emp_no,
       e.first_name,
       e.last_name,
       MAX(s.salary) - MIN(s.salary)                                            AS 'salary difference',
       CASE WHEN MAX(s.salary) - MIN(s.salary) > 30000 THEN 'Yes' ELSE 'No' END AS 'Salary raise over 30000?'
FROM dept_manager dm
         JOIN employees e ON e.emp_no = dm.emp_no
         JOIN salaries s ON s.emp_no = dm.emp_no
GROUP BY dm.emp_no;

# Extract the employee number, first name, and last name of the first 100 employees,
# and add a fourth column, called “current_employee” saying “Is still employed” if the employee
# is still working in the company, or “Not an employee anymore” if they aren’t.

SELECT e.emp_no,
       e.first_name,
       e.last_name,
       CASE WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed' ELSE 'Not an employee anymore' END AS current_employee
FROM employees e
         JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY de.emp_no
LIMIT 100;