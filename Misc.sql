USE employees;
# ROUND(number, decimal_places)
SELECT ROUND(AVG(salary), 2)
FROM salaries;

# COALESCE()
-- first, let's prepare the departments_duplicate table for the purposes of the next exercise
SELECT *
FROM departments_dup;

ALTER TABLE departments_dup
    CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL;

INSERT INTO departments_dup (dept_no)
VALUES ('d010'),
       ('d011');

ALTER TABLE departments_dup
    ADD COLUMN dept_manager VARCHAR(255) NULL AFTER dept_name;

COMMIT;

# IFNULL(expr1, expr2) returns expr1 if the underlying data value is NOT NULL and returns expr2 if the value is NULL
# Note that this is the opposite syntax to most programming languages!
SELECT dept_no,
       IFNULL(dept_name,
              'Department name not provided') AS dept_name
FROM departments_dup;

# COALESCE(expr1, expr2, ..., exprN) is like IFNULL with more than two parameters
# it will return the first non-null value
SELECT dept_no,
       dept_name,
       COALESCE(dept_manager, dept_name, 'N/A') AS dept_manager
FROM departments_dup
ORDER BY dept_no;

# A nice COALESCE trick:
SELECT dept_no,
       dept_name,
       COALESCE('fake col') AS dept_info -- actually, the coalesce is not needed, 'fake col' is enough
FROM departments_dup
ORDER BY dept_no;
# But note this doesn't work with ISNULL, as it takes precisely two arguments

# Select the department number and name from the ‘departments_duplicate’ table and add a third column where you name the department number (‘dept_no’) as ‘dept_info’.
# If ‘dept_no’ does not have a value, use ‘dept_name’.
SELECT dept_no,
       dept_name,
       IFNULL(dept_no, dept_name) AS dept_info
FROM departments_dup;

# Modify the code obtained from the previous exercise in the following way. 
# Apply the IFNULL() function to the values from the first and second column, so that ‘N/A’ is displayed whenever a department number has no value, 
# and ‘Department name not provided’ is shown if there is no value for ‘dept_name’.
SELECT IFNULL(dept_no, 'N/A')                            AS dept_no,
       IFNULL(dept_name, 'Department name not provided') AS dept_name
FROM departments_dup;

/*
GROUP BY and Error 1055:
Error 1055 occurs when the fields we want to include in a SELECT block with a GROUP BY statement are not included in this GROUP BY and are not aggregated.
For example, if we have a list of countries, cities within that country and their population,
then if we group by the country, we can display the total population with SUM(population) - an aggregate function - but including city_name within the SELECT
does not make sense, because it goes against the action of the group by. 
There are several ways to solve this. First, we can simply unselect the problematic column, in this case the city_name.
Alternatively, we can include this column in the GROUP BY, such that the SELECT also groups by the city name (since the city names are unique, in this case it won't group anything).
We can also apply an aggregate function to the problematic column, e.g. MAX(city_name), then only the last city name in alphabetical order is going to be listed per country.
Similarly, we can apply ANY_VALUE() or GROUP_CONCAT() to this column.
Finally, we can switch off the sql_mode known as ONLY_FULL_GROUP_BY.
https://database.guide/6-ways-to-fix-error-1055-expression-of-select-list-is-not-in-group-by-clause-and-contains-nonaggregated-column-in-mysql/
https://dev.mysql.com/doc/refman/8.0/en/group-by-handling.html
*/

CREATE TABLE cities
(
    country    VARCHAR(20),
    city       VARCHAR(20),
    population INT
);

INSERT INTO cities
VALUES ('Italy', 'Milano', 1000000),
       ('Italy', 'Rome', 2000000),
       ('Italy', 'Bologna', 800000),
       ('Poland', 'Warszawa', 1000000),
       ('Poland', 'Wroclaw', 700000);

SELECT country,
       city,
       MAX(population)
FROM cities
WHERE population = (SELECT MAX(population)
                    FROM cities
    # GROUP BY country -- does not work, because that the subquery returns two records
)
GROUP BY country, city;

# this work, but is surprisingly complicated for what I thought would be a simple task in SQL
# https://dba.stackexchange.com/questions/331813/conditional-selection-in-a-group-by-clause
SELECT A.country, A.city, B.pop population
FROM (SELECT country, city, population pop FROM cities) A
         INNER JOIN
         (SELECT country, MAX(population) pop FROM cities GROUP BY country) B
         USING (country, pop);

# MINUS SIGN WITH ORDER BY:
# ORDER BY col ASC; # puts NULL values at the top, as they have the 'least' value
# ORDER BY col DESC; # puts NULL values at the bottom
# ORDER BY -col ASC; # puts NULL values at the top, non-null numerical values will be sorted in descending order
# ORDER BY -col DESC; # puts NULL values at the bottom, non-null numerical values will be sorted in ascending order

# SELF-JOIN
SELECT DISTINCT e1.*
FROM emp_manager e1
         JOIN emp_manager e2 ON e1.emp_no = e2.manager_no;
# I think this can be more intuitively obtained like this:
SELECT *
FROM emp_manager e
WHERE e.emp_no IN (SELECT manager_no FROM emp_manager);

# VIEWS
# A View is a virtual table whose contents are obtained from an existing table(s), called base table(s)
# the view itself does not contain any real data, the data is physically store in the base table
# the view simply shows the data contained in the base table
# views are dynamic, i.e. the reflect the data changes in the underlying base table
# they do not take physical memory, they are just a copy of the query, not of the data itself

CREATE OR REPLACE VIEW v_dept_emp_latest_date AS
SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
FROM dept_emp
GROUP BY emp_no;

# Create a view that will extract the average salary of all managers registered in the database. Round this value to the nearest cent.
CREATE OR REPLACE VIEW v_avg_manager_salary AS
SELECT ROUND(AVG(salary), 2)
FROM salaries
WHERE emp_no IN (SELECT emp_no FROM dept_manager);

SELECT *
FROM employees.v_avg_manager_salary