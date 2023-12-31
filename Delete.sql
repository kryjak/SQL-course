USE employees;
COMMIT;

SELECT 
    *
FROM
    employees
WHERE
    emp_no = 999903;

INSERT INTO employees (emp_no, birth_date, first_name, last_name, hire_date)
VALUES (999903, '1999-01-01', 'John', 'Smith', '2000-01-01');

# DELETE FROM table_name
# [WHERE condition];  -- if WHERE is not included, we might delete all records of the table!

DELETE FROM employees 
WHERE
    emp_no = 999903;

-- COMMIT;
-- ROLLBACK;

/*
DROP VS TRUNCATE VS DELETE
- DROP removes the records, the table as a structure, indices, constraints, etc.
- does not allow a ROLLBACK

- TRUNCATE removes records, but keeps the table as a structure
- after TRUNCATE, auto-increment values are reset to 1

- DELETE removes records row by row, as specified by the WHERE conditions
- if the conditions are omitted, this is equivalent to TRUNCATE
- after DELETE, auto-increment values are NOT reset

*/