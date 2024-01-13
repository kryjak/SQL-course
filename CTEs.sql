# In SQL, every query produces a result set
# CTEs are a tool for obtaining temporary result sets that exist only within the execution of a given query
# CTEs are called with the CTE clause
USE employees;

# count the number of salary contracts with above average value and signed by female employees
WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT COUNT(s.emp_no)
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
         JOIN cte
WHERE e.gender = 'F'
  AND s.salary > avg_salary;
# that is one possible solution, but we can also move the condition to an inner clause, such that there
# can be other select statements to which this condition does apply:
WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT SUM(CASE WHEN s.salary > c.avg_salary THEN 1 ELSE 0 END)             AS no_f_contracts_above_avg_sum,
       COUNT(CASE WHEN s.salary > c.avg_salary THEN s.salary ELSE NULL END) AS no_f_contracts_above_avg_count,
       # count needs to have NULL, otherwise it's also going to count the 0 values
       COUNT(s.salary)                                                      AS total_no_of_contracts
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
         JOIN cte c
WHERE e.gender = 'F';

# Use a CTE (a Common Table Expression) and a SUM()/COUNT() function in the SELECT statement in a query to find out how many
# male contracts have never signed a contract with a salary value higher than or equal to the all-time company salary average.
WITH cte AS (SELECT AVG(salary) AS avg_salary FROM salaries)
SELECT SUM(CASE WHEN e.gender = 'M' AND s.salary < avg_salary THEN 1 ELSE 0 END)      AS with_sum,
       COUNT(CASE WHEN e.gender = 'M' AND s.salary < avg_salary THEN 1 ELSE NULL END) AS with_count
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
         JOIN cte c;

# try to do the same but without CTE:
SELECT SUM(CASE WHEN s.salary < a.avg_salary THEN 1 ELSE 0 END) AS without_CTEs
FROM salaries s
         JOIN
         (SELECT AVG(salary) AS avg_salary FROM salaries) a
         JOIN employees e ON s.emp_no = e.emp_no
WHERE e.gender = 'M';

# one can also do this:
SELECT SUM(CASE WHEN s.salary < (SELECT AVG(salary) AS avg_salary FROM salaries) THEN 1 ELSE 0 END) AS without_CTEs_2
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
WHERE e.gender = 'M';

# Multiple subclauses in a WITH clause
WITH cte1 AS (SELECT AVG(salary) AS avg_salary FROM salaries),
     cte2 AS (SELECT e.emp_no, MAX(s.salary) AS highest_salary
              FROM salaries s
                       JOIN employees e ON s.emp_no = e.emp_no
              WHERE e.gender = 'F'
              GROUP BY s.emp_no)
SELECT SUM(CASE WHEN c2.highest_salary > c1.avg_salary THEN 1 ELSE 0 END) AS f_highest_salaries_above_avg,
       COUNT(c2.emp_no)                                                   AS f_employees,
       CONCAT(ROUND(SUM(CASE WHEN c2.highest_salary > c1.avg_salary THEN 1 ELSE 0 END) / (COUNT(c2.emp_no)) * 100, 2),
              '%')                                                        AS percentage
# f_highest_salaries_above_avg / f_employees doesn't work! - cannot use aliases at the same query level
#FROM employees e
#         JOIN cte2 c2 ON c2.emp_no = e.emp_no
#         JOIN cte1 c1;
FROM cte2 c2
         JOIN cte1 c1;

SELECT COUNT(e.emp_no)
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
WHERE e.gender = 'F';


# Use two common table expressions and a SUM() function in the SELECT statement of a query to obtain the number of
# male employees whose highest salaries have been below the all-time average.

WITH cte1 AS (SELECT AVG(salary) AS avg_salary FROM salaries),
     cte2 AS (SELECT s.emp_no, MAX(s.salary) AS max_salary
              FROM salaries s
                       JOIN employees e2 ON s.emp_no = e2.emp_no
              WHERE e2.gender = 'M'
              GROUP BY s.emp_no)
SELECT SUM(CASE WHEN c2.max_salary < c1.avg_salary THEN 1 ELSE 0 END) AS number
# COUNT(CASE WHEN c2.max_salary < c1.avg_salary THEN 1 ELSE NULL END) as number
#FROM employees e
#         JOIN cte2 c2 ON c2.emp_no = e.emp_no
#         JOIN cte1 c1;
FROM cte2 c2
         JOIN cte1 c1;
