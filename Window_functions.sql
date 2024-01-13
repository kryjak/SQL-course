# A window function performs a calculation for every record in the data set,
# using other records associated with the specified one from the table
# The 'window' is the extent over which the given function evaluation will be performed
# There are 'aggregate' and 'non-aggregate' window functions. The latter are further subdivided into 'ranking'
# and 'value' window functions.

# 1) the windows might not be specified (empty OVER clause), then the function is applied to all rows
# 2) PARTITION BY organises data into partitions
# for example, partitioning by emp_no groups all records associated with one employee into a single partition

USE employees;

SELECT emp_no, salary, ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS row_num
FROM salaries;

# Alternative syntax:
SELECT emp_no, salary, ROW_NUMBER() OVER w AS row_num
FROM salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

# Write a query that upon execution, assigns a row number to all managers we have information for
# in the "employees" database (regardless of their department).
# Let the numbering disregard the department the managers have worked in.
# Also, let it start from the value of 1. Assign that value to the manager with the lowest employee number.

SELECT *, ROW_NUMBER() OVER (ORDER BY emp_no) AS row_num
FROM dept_manager;

# Write a query that upon execution, assigns a sequential number for each employee number registered in the "employees" table.
# Partition the data by the employee's first name and order it by their last name in ascending order (for each partition).

SELECT *, ROW_NUMBER() OVER (PARTITION BY first_name ORDER BY last_name) AS row_num
FROM employees;

# Obtain a result set containing the salary values each manager has signed a contract for. To obtain the data, refer to the "employees" database.
# Use window functions to add the following two columns to the final output:
#   - a column containing the row number of each row from the obtained dataset, starting from 1.
#   - a column containing the sequential row numbers associated to the rows for each manager,
#     where their highest salary has been given a number equal to the number of rows in the given partition, and their lowest - the number 1.
# Finally, while presenting the output, make sure that the data has been ordered by the values in the first of the
# row number columns, and then by the salary values for each partition in ascending order.

SELECT dm.emp_no                                                  AS manager_no,
       s.salary,
       ROW_NUMBER() OVER ()                                       AS row_num,
       ROW_NUMBER() OVER (PARTITION BY dm.emp_no ORDER BY salary) AS contract_num
FROM dept_manager dm
         JOIN salaries s ON dm.emp_no = s.emp_no
ORDER BY row_num, contract_num;

# Useful trick to illustrate the difference between PARTITION BY and GROUP BY
# Start with the usual GROUP BY:
SELECT emp_no, MAX(salary)
FROM salaries
GROUP BY emp_no;

# Wrap it:
SELECT a.emp_no, MAX(salary)
FROM (SELECT emp_no, salary
      FROM salaries) a
GROUP BY emp_no;

# Then replace with a window function:
SELECT a.emp_no, a.salary
FROM (SELECT emp_no, salary, ROW_NUMBER() OVER w AS row_num
      FROM salaries
      WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC)) a
WHERE a.row_num = 1;
# The advantage here is that we can also select the second salary from each partition, the third, etc.
# MAX and MIN allow us to extract only the first and last!

# Find out the lowest salary value each employee has ever signed a contract for.
# To obtain the desired output, use a subquery containing a window function,
# as well as a window specification introduced with the help of the WINDOW keyword.
SELECT emp_no, MIN(salaries.salary) AS min_salary
FROM salaries
GROUP BY emp_no;

SELECT s.emp_no, s.salary AS min_salary
FROM (SELECT emp_no, salary, ROW_NUMBER() OVER w AS row_num
      FROM salaries
      WINDOW w AS (PARTITION BY emp_no ORDER BY salary)) s
WHERE s.row_num = 1;

# RANK() window function
SELECT emp_no, salaries.salary, ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salaries.salary DESC) AS row_num
FROM salaries
WHERE emp_no = 10001;
# all these salary values are different.
# consider an employee who has two identical salary values in the 'salaries' table
# to identify such employees, run:

SELECT emp_no, COUNT(salary) - COUNT(DISTINCT salary) AS diff
FROM salaries
GROUP BY emp_no
HAVING diff > 0
ORDER BY emp_no;
# 205 employees have signed more than one contract with the same salary values
# let's look at at emp_no = 11839:
SELECT emp_no, salaries.salary, ROW_NUMBER() OVER (PARTITION BY emp_no ORDER BY salaries.salary DESC) AS row_num
FROM salaries
WHERE emp_no = 11839;
# row_num 3 and 4 correspond to the same salary values
# if we want to assign the same number to both these rows, use RANK() instead of ROW_NUMBER():
SELECT emp_no, salaries.salary, RANK() OVER (PARTITION BY emp_no ORDER BY salaries.salary DESC) AS row_num
FROM salaries
WHERE emp_no = 11839;
# rank 3 is duplicated, rank 4 is skipped
# alternatively, use DENSE_RANK():
SELECT emp_no, salaries.salary, DENSE_RANK() OVER (PARTITION BY emp_no ORDER BY salaries.salary DESC) AS row_num
FROM salaries
WHERE emp_no = 11839;
# rank 3 is duplicated, rank 4 is next. Last rank is 11, not 12.

# Write a query containing a window function to obtain all salary values that employee number 10560 has ever signed a contract for.
# Order and display the obtained salary values from highest to lowest.
SELECT emp_no, salary, ROW_NUMBER() OVER (ORDER BY salary DESC)
FROM salaries
WHERE emp_no = '10560';

# Write a query that upon execution, displays the number of salary contracts that each manager has ever signed while working in the company.
SELECT dm.emp_no, COUNT(s.salary) AS salary_count
FROM dept_manager dm
         JOIN salaries s ON dm.emp_no = s.emp_no
GROUP BY dm.emp_no
ORDER BY dm.emp_no;

# Write a query that upon execution retrieves a result set containing all salary values that employee 10560 has ever signed a contract for.
# Use a window function to rank all salary values from highest to lowest in a way that equal salary values bear
# the same rank and that gaps in the obtained ranks for subsequent rows are allowed.
SELECT emp_no, salary, RANK() OVER (ORDER BY salary DESC) AS 'rank'
FROM salaries
WHERE emp_no = '10560';

# Write a query that upon execution retrieves a result set containing all salary values that employee 10560 has ever signed a contract for.
# Use a window function to rank all salary values from highest to lowest in a way that equal salary values bear the
# same rank and that gaps in the obtained ranks for subsequent rows are not allowed.
SELECT emp_no, salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS 'rank'
FROM salaries
WHERE emp_no = '10560';

# A complicated task:
# 1. obtain data about the managers from the 'employees' DB
# 2. partition by the department
# 3. order by salary values in descending order
# 4. rank the managers according to the salaries in a certain department (total number of salaries within each
#    department should be preserved)
# 5. display the start and end dates of each salary contract
# 6. display the first and last date in which an employee has been a manager

SELECT dm.dept_no,
       d.dept_name,
       dm.emp_no,
       RANK() OVER (PARTITION BY dm.dept_no ORDER BY s.salary DESC) AS 'rank',
       # RANK() OVER (PARTITION BY dm.emp_no ORDER BY s.salary DESC) AS 'rank', # check out the difference!
       s.salary,
       s.from_date                                                  AS salary_from_date,
       s.to_date                                                    AS salary_to_date,
       dm.from_date                                                 AS dept_manager_from_date,
       dm.to_date                                                   AS dept_manager_to_date
FROM dept_manager dm
         JOIN salaries s ON dm.emp_no = s.emp_no AND
                            (s.from_date BETWEEN dm.from_date AND dm.to_date) AND
                            (s.to_date BETWEEN dm.from_date AND dm.to_date)
         JOIN departments d
              ON dm.dept_no = d.dept_no
;

# Write a query that ranks the salary values in descending order of all contracts signed by employees numbered
# between 10500 and 10600 inclusive. Let equal salary values for one and the same employee bear the same rank.
# Also, allow gaps in the ranks obtained for their subsequent rows.
SELECT emp_no, salary, RANK() OVER (PARTITION BY emp_no ORDER BY salary DESC) AS 'rank'
FROM salaries
WHERE emp_no BETWEEN 10500 AND 10600;

# Write a query that ranks the salary values in descending order of the following contracts from the "employees" database:
#   - contracts that have been signed by employees numbered between 10500 and 10600 inclusive.
#   - contracts that have been signed at least 4 full-years after the date when the given employee was hired
#     in the company for the first time.
# In addition, let equal salary values of a certain employee bear the same rank. Do not allow gaps in the ranks
# obtained for their subsequent rows.
SELECT s.emp_no,
       s.salary,
       YEAR(s.from_date) - YEAR(e.hire_date)                            AS year_diff,
       DENSE_RANK() OVER (PARTITION BY s.emp_no ORDER BY s.salary DESC) AS 'rank'
FROM salaries s
         JOIN employees e ON s.emp_no = e.emp_no
WHERE (s.emp_no BETWEEN 10500 AND 10600)
  AND (YEAR(s.from_date) - YEAR(e.hire_date) > 4);

# VALUE WINDOW FUNCTIONS return a value that can be found in the databases
SELECT emp_no,
       salary,
       LAG(salary) OVER w           AS previous_salary,
       LEAD(salary) OVER w          AS next_salary,
       salary - LAG(salary) OVER w  AS diff_salary_current_previous,
       LEAD(salary) OVER w - salary AS diff_salary_next_current
FROM salaries
WHERE emp_no = 10001
WINDOW w AS (ORDER BY salary);
# no need to partition by emp_no as we have specified only one employee right above
# note empty output for first and last row

# Write a query that can extract the following information from the "employees" database:
# - the salary values (in ascending order) of the contracts signed by all employees numbered between 10500 and 10600 inclusive
# - a column showing the previous salary from the given ordered list
# - a column showing the subsequent salary from the given ordered list
# - a column displaying the difference between the current salary of a certain employee and their previous salary
# - a column displaying the difference between the next salary of a certain employee and their current salary
# Limit the output to salary values higher than $80,000 only.
# Also, to obtain a meaningful result, partition the data by employee number.
SELECT emp_no,
       salary,
       LAG(salary) OVER w,
       LEAD(salary) OVER w,
       salary - LAG(salary) OVER w,
       LEAD(salary) OVER w - salary
FROM salaries
WHERE (emp_no BETWEEN 10500 AND 10600)
  AND (salary > 80000)
WINDOW w AS (PARTITION BY emp_no ORDER BY salary);

# The MySQL LAG() and LEAD() value window functions can have a second argument, designating how many rows/steps back
# (for LAG()) or forth (for LEAD()) we'd like to refer to with respect to a given record.
# With that in mind, create a query whose result set contains data arranged by the salary values associated to each
# employee number (in ascending order). Let the output contain the following six columns:
# - the employee number
# - the salary value of an employee's contract (i.e. which we’ll consider as the employee's current salary)
# - the employee's previous salary
# - the employee's contract salary value preceding their previous salary
# - the employee's next salary
# - the employee's contract salary value subsequent to their next salary
# Restrict the output to the first 1000 records you can obtain.

SELECT emp_no,
       salary,
       LAG(salary) OVER w,
       LAG(salary, 2) OVER w,
       LEAD(salary) OVER w,
       LEAD(salary, 2) OVER w
FROM salaries
WINDOW w AS (PARTITION BY emp_no ORDER BY salary)
LIMIT 1000;

# AGGREGATE WINDOW FUNCTIONS
# One needs to be very careful to understand whether we are applying an aggregate window function to groups of values
# or to data partitions
SELECT a.emp_no, a.dept_name, a.salary, a.avg_salary
FROM (SELECT de.emp_no,
             d.dept_name,
             s.salary,
             ROW_NUMBER() OVER (PARTITION BY de.emp_no ORDER BY de.from_date DESC) AS 'rank',
             b.avg_salary
      FROM dept_emp de
               JOIN salaries s ON de.emp_no = s.emp_no
               JOIN departments d ON de.dept_no = d.dept_no
               JOIN (SELECT d.dept_no, d.dept_name, AVG(salary) AS avg_salary
                     FROM departments d
                              JOIN dept_emp de ON d.dept_no = de.dept_no
                              JOIN salaries s ON de.emp_no = s.emp_no
                     GROUP BY d.dept_no) b ON d.dept_no = b.dept_no
      WHERE s.to_date > SYSDATE()) a
WHERE a.`rank` = 1;

# Create a query that upon execution returns a result set containing the employee numbers, contract salary values,
# start, and end dates of the first ever contracts that each employee signed for the company.
# To obtain the desired output, refer to the data stored in the "salaries" table.
SELECT s1.emp_no, s1.salary, s1.from_date, s1.to_date
FROM (SELECT s.emp_no, s.salary, s.from_date, s.to_date, RANK() OVER w AS salary_rank
      FROM salaries s
      WINDOW w AS (PARTITION BY s.emp_no ORDER BY s.from_date)) s1
WHERE s1.salary_rank = 1;

SELECT s1.emp_no, s.salary, s.from_date, s.to_date
FROM salaries s
         JOIN
     (SELECT s.emp_no, MIN(s.from_date) AS first_from_date
      FROM salaries s
      GROUP BY s.emp_no) s1 ON s.emp_no = s1.emp_no
WHERE s1.first_from_date = s.from_date;
# same result set, but the second solution is ~10x quicker!

# Consider the employees' contracts that have been signed after the 1st of January 2000 and
# terminated before the 1st of January 2002 (as registered in the "dept_emp" table).
# Create a MySQL query that will extract the following information about these employees:
# - Their employee number
# - The salary values of the latest contracts they have signed during the suggested time period
# - The department they have been working in (as specified in the latest contract they've signed during the suggested time period)
# - Use a window function to create a fourth field containing the average salary paid in the department the employee was
#   last working in during the suggested time period. Name that field "average_salary_per_department".
SELECT q1.emp_no,
       d.dept_name,
       q2.salary,
       AVG(q2.salary) OVER (PARTITION BY q1.dept_no) AS average_salary_per_department
FROM (SELECT de.emp_no, de.dept_no
      FROM dept_emp de
               JOIN
           (SELECT emp_no, MAX(from_date) AS max_dept_from_date
            FROM dept_emp
            GROUP BY emp_no) de1 ON de.emp_no = de1.emp_no
      WHERE from_date > '2000-01-01'
        AND to_date < '2002-01-01'
        AND de.from_date = de1.max_dept_from_date) q1
         JOIN
     (SELECT s.emp_no, s.salary
      FROM salaries s
               JOIN
           (SELECT emp_no, MAX(from_date) AS max_salary_from_date
            FROM salaries
            GROUP BY emp_no) s1 ON s.emp_no = s1.emp_no
      WHERE from_date > '2000-01-01'
        AND to_date < '2002-01-01'
        AND s.from_date = s1.max_salary_from_date) q2 ON q1.emp_no = q2.emp_no
         JOIN departments d ON q1.dept_no = d.dept_no
GROUP BY q1.emp_no, d.dept_name, q2.salary
ORDER BY q1.emp_no, q2.salary;
