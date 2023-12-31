/*
COMMIT:
- saves changes in the database
- cannot be undone
 
ROLLBACK:
- reverts to the last committed state (aborts changes in the working directory)
 */
 
 # Preferences -> SQL Editor -> Disable the option 'Safe Updates'
 # Reconnect to the database
 
 /*
 UPDATE table_name
 SET col_1 = val_1, col_2 = val_2, ...
 [WHERE conditions];
 */
 
SELECT * from employees where emp_no = 999903;
 
UPDATE employees 
SET
    first_name = 'Stella',
    last_name = 'Parkinson',
    birth_date = '1990-12-31',
    gender = 'F'
WHERE
    emp_no = 999903;  # the WHERE condition is crucial, otherwise all fields would be updated!
    
SELECT * from employees where emp_no = 999903;

# Let's incorrectly update all the departments, instead of a single one, by omitting a condition
SET AUTOCOMMIT = OFF;

COMMIT;
UPDATE departments_duplicate 
SET 
    dept_no = 'd011',
    dept_name = 'DUMMY';

SELECT * FROM departments_duplicate;
ROLLBACK;
SELECT * FROM departments_duplicate;
COMMIT;

# Change the “Business Analysis” department name to “Data Analysis”.
SELECT * from departments ORDER BY dept_no DESC;

UPDATE departments 
SET 
    dept_name = 'Data Analysis'
WHERE
    dept_name = 'Business Analytics';
#WHERE dept_no = 'd010'