-- Creates DB if not already exists
CREATE DATABASE IF NOT EXISTS motorcycle_db;

USE motorcycle_db;

SELECT
	*
FROM
	moto_stage;

-- 1NF - No more than 1 values per cell, no repeating groups, each row unique
-- split: firstname, lastname

-- 2NF - table has to already be 1NF, no partial dependencies. Every Non-key column depends on the entire primary key
-- Remove customerInfo to its own table: name, city
-- Remove motorcycles information

-- 3NF - already in 2NF, transitive dependencies,no column depends on another non-key column
-- Moto table: id motor, model, manufacture, manufacurer country, category, engine CC
-- Remove manufacturer information from motorcycle tables

-- motorcycle_db schema
	-- Customers Table
		-- custID PK
		-- firstName
        -- lastName
        -- city
	
    -- manufactures table
		-- ManufacturerID PK
        -- ManufacturerName
        -- Country

	-- Motorcycles Table
		-- MotoID PK
        -- Model
        -- Category
        -- EngineCC
        -- ManufavturerID FK

	-- Sales (FACT table)
		-- SaleID PK
        -- Cust_ID FK
        -- Moto_ID FK
        -- Sales Date
        -- Sale Price

SELECT
	DISTINCT SUBSTRING_INDEX(customerName, " ", -1),
    SUBSTRING_INDEX(customerName, " ", 1),
    customerCity
FROM
	moto_stage;

-- Create customer table - DDL
CREATE TABLE customers (
	cust_id INT AUTO_INCREMENT PRIMARY KEY,
    lastname VARCHAR(50) NOT NULL,
    firstname VARCHAR(50) NOT NULL,
    city VARCHAR(100) DEFAULT NULL
);

-- Populate the table using DML
INSERT INTO customers (lastname, firstname, city)
SELECT
	DISTINCT SUBSTRING_INDEX(customerName, " ", -1),
    SUBSTRING_INDEX(customerName, " ", 1),
    customerCity
FROM
	moto_stage;

-- Testing new table
SELECT
	*
FROM
	customers;

-- manufactures table
	-- ManufacturerID PK
	-- ManufacturerName
	-- Country

SELECT
	DISTINCT manufacturer,
    manufacturerCountry
FROM
	moto_stage;




-- Creat Manufacturer Table - DDL
CREATE TABLE manufacturer (
	manu_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturerName VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(100) DEFAULT NULL
);

-- Populate Manufacturer Table - DML
INSERT INTO manufacturer (manufacturerName, country)
SELECT
	DISTINCT manufacturer,
    manufacturerCountry
FROM
	moto_stage;

SELECT
	*
FROM
	manufacturer;

-- Motorcycles Table
	-- MotoID PK
	-- Model
	-- Category
	-- EngineCC
	-- ManufavturerID FK

SELECT
	DISTINCT motorcycleModel,
    category,
    engineCC
FROM
	moto_stage;

CREATE TABLE motorcycle (
	motor_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50),
    engineCC INT,
    manufacturerID INT NOT NULL,
    FOREIGN KEY (manufacturerID)
		REFERENCES manufacturer (manu_id)
);

DROP TABLE motorcycle;

INSERT INTO motorcycle (model, category, engineCC, manufacturerID)
SELECT
	DISTINCT motorcycleModel,
    category,
    engineCC,
    m.manu_id
FROM
	moto_stage raw
    INNER JOIN manufacturer m
    ON raw.manufacturer = m.manufacturerName;

SELECT *
FROM motorcycle;

-- Sales (FACT table)
	-- SaleID PK
	-- Cust_ID FK
	-- Moto_ID FK
	-- Sales Date
	-- Sale Price

CREATE TABLE sale (
	saleID INT PRIMARY KEY,
    customer_id INT NOT NULL,
    motor_id INT NOT NULL,
    sale_date DATE DEFAULT NULL,
    sale_price DECIMAL(10, 2),

    FOREIGN KEY (customer_id)
		REFERENCES customers (cust_id),

	FOREIGN KEY (motor_id)
		REFERENCES motorcycle (motor_id)
);


INSERT INTO sale (saleID, customer_id, motor_id, sale_date, sale_price)
SELECT
	raw.saleID,
    c.cust_id,
    m.motor_id,
    CAST(raw.saledate AS date),
    raw.saleprice
FROM
	moto_stage raw
    INNER JOIN customers c
		ON raw.CustomerName = CONCAT(c.firstname, ' ', c.lastname)
	INNER JOIN motorcycle m
		ON raw.MotorcycleModel = m.model;

SELECT *
FROM sale;