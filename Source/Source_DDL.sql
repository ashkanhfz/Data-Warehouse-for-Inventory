USE [Source]
GO
-- Drop all foreign key constraints
DECLARE @SQL varchar(4000) = '';
SELECT @SQL = @SQL + 'ALTER TABLE ' + s.name + '.' + t.name + ' DROP CONSTRAINT [' + RTRIM(f.name) + '];' + CHAR(13)
FROM sys.Tables t
INNER JOIN sys.foreign_keys f ON f.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON s.schema_id = f.schema_id;
EXEC(@SQL);



-- Drop existing tables if they exist
IF OBJECT_ID('warehouse_outlet', 'U') IS NOT NULL
    DROP TABLE warehouse_outlet;

IF OBJECT_ID('warehouse_entrance', 'U') IS NOT NULL
    DROP TABLE warehouse_entrance;

IF OBJECT_ID('Product', 'U') IS NOT NULL
    DROP TABLE Product;

IF OBJECT_ID('Category', 'U') IS NOT NULL
    DROP TABLE Category;

IF OBJECT_ID('Company', 'U') IS NOT NULL
    DROP TABLE Company;

IF OBJECT_ID('Warehouse', 'U') IS NOT NULL
    DROP TABLE Warehouse;

IF OBJECT_ID('Employee', 'U') IS NOT NULL
    DROP TABLE Employee;

IF OBJECT_ID('Location', 'U') IS NOT NULL
    DROP TABLE Location;

IF OBJECT_ID('City', 'U') IS NOT NULL
    DROP TABLE City;

IF OBJECT_ID('Rollcall', 'U') IS NOT NULL
    DROP TABLE Rollcall;

IF OBJECT_ID('Commuting_time', 'U') IS NOT NULL
    DROP TABLE Commuting_time;

IF OBJECT_ID('Representative', 'U') IS NOT NULL
    DROP TABLE Representative;

IF OBJECT_ID('Discount_code', 'U') IS NOT NULL
    DROP TABLE Discount_code;

IF OBJECT_ID('Discount_code_type', 'U') IS NOT NULL
    DROP TABLE Discount_code_type;

IF OBJECT_ID('Customer', 'U') IS NOT NULL
    DROP TABLE Customer;

IF OBJECT_ID('Position', 'U') IS NOT NULL
    DROP TABLE Position;

IF OBJECT_ID('Contract_type', 'U') IS NOT NULL
    DROP TABLE Contract_type;

-- Create tables

CREATE TABLE City ( 
    city_code INT PRIMARY KEY,
    city_name VARCHAR(20),
	city_description VARCHAR(50)
);

CREATE TABLE Location ( 
    location_id INT PRIMARY KEY,
    [state] VARCHAR(20),
    city_code INT,
    FOREIGN KEY (city_code) REFERENCES City(city_code)
);




CREATE TABLE Warehouse ( 
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(20),
    warehouse_description VARCHAR(50),
    manager_id INT,
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);


CREATE TABLE Company (
    company_id INT PRIMARY KEY,
    [name] VARCHAR(20),
    registration_code VARCHAR(10),
    phone_number VARCHAR(10),
    email VARCHAR(40),
    [address] VARCHAR(20),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Category ( 
    category_id INT PRIMARY KEY,
    category_name VARCHAR(20),
    category_description VARCHAR(50)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    [name] VARCHAR(20),
    product_description VARCHAR(50),
    category_id INT,
    company_id INT,
    price INT,
    cost INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (company_id) REFERENCES Company(company_id)
);

CREATE TABLE Position (
    position_id INT PRIMARY KEY,
    [description] VARCHAR(50),
    hours_of_work INT,
    maximum_hours_of_over_time INT,
    hours_of_work_leave INT,
    days_of_work_leave INT
);

CREATE TABLE Contract_type (
    contract_type_id INT PRIMARY KEY,
    [description] VARCHAR(50)
);


CREATE TABLE Employee ( 
    employee_id INT PRIMARY KEY,
    [name] VARCHAR(20),
    last_name VARCHAR(30),
    gender bit, -- 1:male
    phone_number VARCHAR(10),
    email VARCHAR(40),
    job_title VARCHAR(20),
    hire_date DATE,
	position_id INT,
	contract_type_id INT,
	warehouse_id INT,
    FOREIGN KEY (position_id) REFERENCES Position(position_id),
    FOREIGN KEY (contract_type_id) REFERENCES Contract_type(contract_type_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id)
);


CREATE TABLE warehouse_entrance (
    id INT PRIMARY KEY,
    warehouse_id INT,
    product_id INT,
    quantity INT,
	EmployeeID INT,
    time DATE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
	FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(Employee_ID)
);


CREATE TABLE Customer(
    customer_id INT PRIMARY KEY,
    [name] VARCHAR(20),
    last_name VARCHAR(30),
    national_id VARCHAR(10),
    gender BIT,
    phone_number VARCHAR(10),
    email VARCHAR(40),
    [address] VARCHAR(20)
);

CREATE TABLE Discount_code_type (
    discount_code_type_id INT PRIMARY KEY,
    [description] VARCHAR(50),
    minimum_purchase INT,
    [start_date] DATE,
    [end_date] DATE,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);



CREATE TABLE Discount_code (
    discount_code_id INT PRIMARY KEY,
    customer_id INT,
    discount_code_type_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (discount_code_type_id) REFERENCES Discount_code_type(discount_code_type_id)
);

CREATE TABLE warehouse_outlet (
    id INT PRIMARY KEY,
    warehouse_id INT,
    product_id INT,
    customer_id INT,
    quantity INT,
    time DATE,
	EmployeeID INT,
	DiscountID INT,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
	FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(Employee_ID),
	FOREIGN KEY (DiscountID) REFERENCES [Discount_code](Discount_CODE_ID)
);







CREATE TABLE Representative (
    representative_id INT,
    presented_id INT,
    FOREIGN KEY (representative_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (presented_id) REFERENCES Employee(employee_id)
);


drop table Rollcall
CREATE TABLE Rollcall (
    id INT PRIMARY KEY,
    [date] DATE,
    employee_id INT,
    work_leave BIT,
    hours_of_work_leave INT,
	overtime int,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
   )

   drop TABLE Commuting_time

CREATE TABLE Commuting_time (
    id INT PRIMARY KEY,
    [date] DATETIME,
	[time] time,
    employee_id INT,
    commuting bit, -- 0 : exit
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
	)
