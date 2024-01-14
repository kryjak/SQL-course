# temporary tables save time and memory when retrieving the data
# they act just like a norma, permanent, table
# BUT they are valid only for a given session!
# a temporary table can be invoked only once!

USE employees;

# Store the highest contract salary values of all male employees in a temporary table called male_max_salaries.
CREATE TEMPORARY TABLE male_max_salares
SELECT s.emp_no, MAX(s.salary)
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
WHERE s.emp_no
GROUP BY s.emp_no;

SELECT *
FROM male_max_salares;

# Create a temporary table called dates containing the following three columns:
# - one displaying the current date and time,
# - another one displaying two months earlier than the current date and time, and a
# - third column displaying two years later than the current date and time.

DROP TABLE dates;
CREATE TEMPORARY TABLE dates
SELECT SYSDATE()                         AS now,
       DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
       DATE_SUB(NOW(), INTERVAL -2 YEAR) AS two_years_later;

SELECT *
FROM dates;

# Create a query joining the result sets from the dates temporary table you created during the previous lecture with
# a new Common Table Expression (CTE) containing the same columns. Let all columns in the result set appear on the same row.
WITH cte AS (SELECT SYSDATE()                         AS now,
                    DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
                    DATE_SUB(NOW(), INTERVAL -2 YEAR) AS two_years_later)
SELECT *
FROM dates d
         JOIN cte c;

# Again, create a query joining the result sets from the dates temporary table you created during the previous lecture
# with a new Common Table Expression (CTE) containing the same columns. This time, combine the two sets vertically.
WITH cte AS (SELECT SYSDATE()                         AS now,
                    DATE_SUB(NOW(), INTERVAL 2 MONTH) AS two_months_earlier,
                    DATE_SUB(NOW(), INTERVAL -2 YEAR) AS two_years_later)
SELECT *
FROM dates
UNION
SELECT *
FROM cte;