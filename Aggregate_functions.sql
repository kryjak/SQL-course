/*
Functions such as COUNT(), SUM(), MIN(), MAX(), AVG() are known as aggregate functions, or summary functions
COUNT() can be used with both numeric and non-numeric data
But SUM(), MIN(), MAX(), AVG() can only be used with numeric data
*/

# COUNT ignore NULL values if we specify a column name in the argument, e.g. COUNT(salary)
# But COUNT(*) will include NULL values

# How many departments are there in the “employees” database? Use the ‘dept_emp’ table to answer the question.
SELECT 
    COUNT(DISTINCT dept_no)
FROM
    dept_emp;
    
# What is the total amount of money spent on salaries for all contracts starting after the 1st of January 1997?
SELECT 
    SUM(salary) AS 'total salaries'
FROM
    salaries
WHERE
    from_date > '1997-01-01';
    
# Which is the highes/lowest employee number in the database?
SELECT 
    MAX(emp_no) -- Min(emp_no)
FROM
    employees;

# What is the average annual salary paid to employees who started after the 1st of January 1997?
SELECT 
    AVG(salary)
FROM
    salaries
WHERE
    from_date > '1997-01-01';