-- DROP TABLE customers;--

CREATE TABLE IF NOT EXISTS customers (  
    customer_id INT,  
    first_name varchar(255),  
    last_name varchar(255),  
    email_address varchar(255),  
    number_of_complaints int DEFAULT 0,  
PRIMARY KEY (customer_id),
UNIQUE KEY (email_address)
);

CREATE TABLE IF NOT EXISTS items (
	item_code VARCHAR(255) PRIMARY KEY,  
	item VARCHAR(255),  
	unit_price NUMERIC(10, 2),
	company­_id VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(255) PRIMARY KEY,
    company_name VARCHAR(255),
    headquarters_phone_number INT
);

DROP TABLE IF EXISTS sales;

CREATE TABLE IF NOT EXISTS sales (
	purchase_number INT NOT NULL AUTO_INCREMENT,
	date_of_purchase DATE NOT NULL,
	customer_id INT,
	item_code VARCHAR(10) NOT NULL,
PRIMARY KEY (purchase_number),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

/*
the child column 'customer_id' in the sales table references the parent column 'customer_id' in the 'customers' table
note that these two names do not have to be the same, although it obviously makes sense
ON DELETE CASCADE means that a deletion of a record in the parent will cascade onto its children
so in this case, if we remove a customer ID in the customers table, all the corresponding sales records will be dropped too
*/

/* 
The constraint is automatically assigned the name:
sales_ibfk_1
*/

/*
We can also add the foreign key as:
ALTER TABLE sales -- no semicolon here
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;

To delete the key:
ALTER TABLE sales
DROP FOREIGN KEY sales_ibfk_1;
*/

/* 
Foreign keys can also be managed using the MySQL GUI. Right click on the table name in the window on the LHS -> Alter Table -> Foreign Keys.
*/


/* 
Similarly, for the unique keys:
ALTER TABLE customers
ADD UNIQUE KEY (email_address);

But note that for deleting:
ALTER TABLE customers
DROP INDEX email_address; -- because a unique key acts as the index of the table
*/

DROP TABLE sales, customers, items, companies;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email_address VARCHAR(255) UNIQUE KEY,
    number_of_complaints INT DEFAULT 0,
PRIMARY KEY (customer_id)
); 

-- Another way to change the default value in a column
ALTER TABLE customers
CHANGE COLUMN number_of_complaints number_of_complaints INT DEFAULT 0;

-- inserting a new column after the column 'last_name'
ALTER TABLE customers
ADD COLUMN gender ENUM('M', 'F') AFTER last_name;

-- inserting a particular record into the customers table 
INSERT INTO customers (first_name, last_name, gender, email_address)
VALUES ('John', 'Mackinley', 'M', 'john.mckinley@365careers.com'); -- without modifying the default value for the number_of_complaints

INSERT INTO customers (first_name, last_name, gender, email_address, number_of_complaints)
VALUES ('Karen', 'McWhiney', 'F', 'speakto@manager.com', 27); -- modifying the default value


SELECT * FROM customers;

CREATE TABLE companies (
	company_id INT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL DEFAULT 'X',
    headquarters_phone_number VARCHAR(255) UNIQUE KEY,
PRIMARY KEY (company_id)
);

ALTER TABLE companies
MODIFY company_name VARCHAR(255) NULL;
-- CHANGE COLUMN company_name company_name VARCHAR(255) NOT NULL;

DROP TABLE companies;    