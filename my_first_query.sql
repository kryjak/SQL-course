CREATE DATABASE IF NOT EXISTS Sales;
USE	Sales; -- indicates that the subsequent queries refers to this database

DROP TABLE IF EXISTS sales;

CREATE TABLE IF NOT EXISTS sales (
	purchase_number INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	date_of_purchase DATE NOT NULL,
	customer_id INT,
	item_code VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS customers (
	customer_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(255),
	last_name VARCHAR(255),
	email_address VARCHAR(255),
	number_of_complaints INT
-- PRIMARY KEY (customer_id) -- another way to assign the primary key
);

/* To select a particular table we can do either
USE Sales;
SELECT * FROM customers;

OR

SELECT * FROM Sales.customers;
*/
SELECT * FROM Sales.customers;
