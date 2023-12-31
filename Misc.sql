USE employees;
# ROUND(number, decimal_places)
SELECT
    ROUND(AVG(salary), 2)
FROM
    salaries;
    
# COALESCE()
-- first, let's prepare the departments_duplicate table for the purposes of the next exercise
SELECT 
    *
FROM
    departments_duplicate;
    
ALTER TABLE departments_duplicate
CHANGE COLUMN dept_name dept_name VARCHAR(40) NULL;
    
INSERT INTO departments_duplicate (dept_no)
VALUES ('d010'), ('d011');

ALTER TABLE departments_duplicate
ADD COLUMN dept_manager VARCHAR(255) NULL AFTER dept_name;

COMMIT;

# IFNULL(expr1, expr2) returns expr1 if the underlying data value is NOT NULL and returns expr2 if the value is NULL
# Note that this is the opposite syntax to most programming languages!
SELECT 
    dept_no,
    IFNULL(dept_name,
            'Department name not provided') AS dept_name
FROM
    departments_duplicate;
    
# COALESCE(expr1, expr2, ..., exprN) is like IFNULL with more than two parameters
# it will return the first non-null value
SELECT 
    dept_no, 
    dept_name, 
    COALESCE(dept_manager, dept_name, 'N/A') as dept_manager
FROM
    departments_duplicate
ORDER BY 
    dept_no;

# A nice COALESCE trick:
SELECT 
    dept_no, dept_name, COALESCE('fake col') AS dept_info -- actually, the coalesce is not needed, 'fake col' is enough
FROM
    departments_duplicate
ORDER BY dept_no;
# But note this doesn't work with ISNULL, as it takes precisely two arguments

# Select the department number and name from the ‘departments_duplicate’ table and add a third column where you name the department number (‘dept_no’) as ‘dept_info’.
# If ‘dept_no’ does not have a value, use ‘dept_name’.
SELECT 
    dept_no, dept_name, IFNULL(dept_no, dept_name) AS dept_info
FROM
    departments_duplicate;
    
# Modify the code obtained from the previous exercise in the following way. 
# Apply the IFNULL() function to the values from the first and second column, so that ‘N/A’ is displayed whenever a department number has no value, 
# and ‘Department name not provided’ is shown if there is no value for ‘dept_name’.
SELECT 
    IFNULL(dept_no, 'N/A') AS dept_no, IFNULL(dept_name, 'Department name not provided') AS dept_name
FROM
    departments_duplicate;
    
/*
GROUP BY and error 1055:
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

CREATE TABLE cities (
    country VARCHAR(20),
    city VARCHAR(20),
    population INT
);

INSERT INTO cities
VALUES ('Italy', 'Milano', 1000000), ('Italy', 'Rome', 2000000), ('Italy', 'Bologna', 800000), ('Poland', 'Warszawa', 1000000), ('Poland', 'Wroclaw', 700000);

SELECT 
    country, city, MAX(population)
FROM
    cities
WHERE
    population = (SELECT 
            MAX(population)
        FROM
            cities
        # GROUP BY country -- does not work, because that the subquery returns two records
        )
GROUP BY country, city;

# this work, but is surprisingly complicated for what I thought would be a simple task in SQL
# https://dba.stackexchange.com/questions/331813/conditional-selection-in-a-group-by-clause
SELECT A.country,A.city,B.pop population FROM
(SELECT country,city,population pop FROM cities) A INNER JOIN
(SELECT country,MAX(population) pop FROM cities GROUP BY country) B 
USING (country,pop);