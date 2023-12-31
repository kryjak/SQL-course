# INSERT INTO table_name (col_1, col_2, ..., col_n)
# VALUES (val_1, val_2, ..., val_n);
-- note that we do not have to specify all the columns, only the ones we need
-- also, the column names do not need to be in the same order as in the table
-- the column names in the first round brackets can be omitted
-- but then we need to specify all the n columns and in the same order as in the table

INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES (999903, '1986-04-21', 'John', 'Smith', 'M', '2011-01-01');

SELECT 
    *
FROM
    employees
ORDER BY emp_no DESC
LIMIT 10;

# Select ten records from the “titles” table to get a better idea about its content.
# Then, in the same table, insert information about employee number 999903. State that he/she is a “Senior Engineer”, who has started working in this position on October 1st, 1997.
# At the end, sort the records from the “titles” table in descending order to check if you have successfully inserted the new record.

SELECT 
    *
FROM
    titles
LIMIT 10;

INSERT INTO titles (emp_no, title, from_date)
VALUES (999903, 'Senior Engineer', '1997-10-01');

SELECT 
    *
FROM
    titles
ORDER BY emp_no DESC
LIMIT 10;

# Insert information about the individual with employee number 999903 into the “dept_emp” table. 
# He/She is working for department number 5, and has started work on  October 1st, 1997; her/his contract is for an indefinite period of time.

SELECT 
    *
FROM
    dept_emp
LIMIT 10;

INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date)
VALUES (999903, 'd005', '1997-10-01', '9999-01-01');

# Inserting information from one table into another
# INSERT INTO table_2 (col_1, col_2, ..., col_n)
# SELECT (col_1, col_2, ..., col_n);
# FROM table 1
# [WHERE condition];

-- let's insert information from 'departments' table into its duplicate
CREATE TABLE departments_duplicate (
    dept_no CHAR(4) NOT NULL,
    dept_name VARCHAR(40) NOT NULL
);
-- at this point, we have an empty table

INSERT INTO departments_duplicate (dept_no, dept_name)
SELECT * FROM departments;

-- SELECT * FROM departments_duplicate;

# Create a new department called “Business Analysis”. Register it under number ‘d010’.
INSERT INTO departments (dept_no, dept_name)
VALUES ('d010','Business Analytics');