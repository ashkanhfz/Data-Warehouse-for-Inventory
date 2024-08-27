USE SA
GO

-- Drop existing tables if they exist
IF OBJECT_ID('SA_warehouse_outlet', 'U') IS NOT NULL
    DROP TABLE SA_warehouse_outlet;

IF OBJECT_ID('SA_warehouse_entrance', 'U') IS NOT NULL
    DROP TABLE SA_warehouse_entrance;

IF OBJECT_ID('SA_Product', 'U') IS NOT NULL
    DROP TABLE SA_Product;

IF OBJECT_ID('SA_Category', 'U') IS NOT NULL
    DROP TABLE SA_Category;

IF OBJECT_ID('SA_Company', 'U') IS NOT NULL
    DROP TABLE SA_Company;

IF OBJECT_ID('SA_Warehouse', 'U') IS NOT NULL
    DROP TABLE SA_Warehouse;

IF OBJECT_ID('SA_Employee', 'U') IS NOT NULL
    DROP TABLE SA_Employee;

IF OBJECT_ID('SA_Location', 'U') IS NOT NULL
    DROP TABLE SA_Location;

IF OBJECT_ID('SA_City', 'U') IS NOT NULL
    DROP TABLE SA_City;

IF OBJECT_ID('SA_Rollcall', 'U') IS NOT NULL
    DROP TABLE SA_Rollcall;

IF OBJECT_ID('SA_Commuting_time', 'U') IS NOT NULL
    DROP TABLE SA_Commuting_time;

IF OBJECT_ID('SA_Representative', 'U') IS NOT NULL
    DROP TABLE SA_Representative;

IF OBJECT_ID('SA_Discount_code', 'U') IS NOT NULL
    DROP TABLE SA_Discount_code;

IF OBJECT_ID('SA_Discount_code_type', 'U') IS NOT NULL
    DROP TABLE SA_Discount_code_type;

IF OBJECT_ID('SA_Customer', 'U') IS NOT NULL
    DROP TABLE SA_Customer;

IF OBJECT_ID('SA_Position', 'U') IS NOT NULL
    DROP TABLE SA_Position;

IF OBJECT_ID('SA_Contract_type', 'U') IS NOT NULL
    DROP TABLE SA_Contract_type;

-- Create tables

CREATE TABLE SA_City ( 
    city_code INT,
    city_name VARCHAR(50),
    city_description VARCHAR(100)
);

CREATE TABLE SA_Location ( 
    location_id INT,
    [state] VARCHAR(50),
    city_code INT
);

CREATE TABLE SA_Employee ( 
    employee_id INT,
    [name] VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(20) CHECK ( gender in ( 'Male' , 'Female')),
    phone_number VARCHAR(15),
    email VARCHAR(50),
    job_title VARCHAR(50),
    hire_date DATE,
    warehouse_id INT,
    position_id INT,
    contract_type_id INT
);


CREATE TABLE SA_Warehouse ( 
    warehouse_id INT,
    warehouse_name VARCHAR(50),
    warehouse_description VARCHAR(100),
    manager_id INT,
    location_id INT
);


CREATE TABLE SA_Company (
    company_id INT,
    [name] VARCHAR(50),
    registration_code VARCHAR(15),
    phone_number VARCHAR(15),
    email VARCHAR(50),
    [address] VARCHAR(100),
    location_id INT
);

CREATE TABLE SA_Category ( 
    category_id INT,
    category_name VARCHAR(50),
    category_description VARCHAR(100)
);

CREATE TABLE SA_Product (
    product_id INT,
    [name] VARCHAR(50),
    product_description VARCHAR(100),
    category_id INT,
    company_id INT,
    price INT,
    cost INT
);

CREATE TABLE SA_Warehouse_Entrance (
    id INT,
    warehouse_id INT,
    product_id INT,
    quantity INT,
    time DATE,
    EmployeeID INT
);

CREATE TABLE SA_Customer (
    customer_id INT,
    [name] VARCHAR(50),
    last_name VARCHAR(50),
    national_id VARCHAR(15),
    gender VARCHAR(20),
    phone_number VARCHAR(15),
    email VARCHAR(50),
    [address] VARCHAR(100)
);

CREATE TABLE SA_Warehouse_Outlet (
    id INT,
    warehouse_id INT,
    product_id INT,
    customer_id INT,
    quantity INT,
    time DATE,
    EmployeeID INT,
    DiscountID INT
);

CREATE TABLE SA_Discount_code_type (
    discount_code_type_id INT,
    [description] VARCHAR(100),
    minimum_purchase INT,
    [start_date] DATE,
    [end_date] DATE,
    category_id INT
);

CREATE TABLE SA_Discount_code (
    discount_code_id INT,
    customer_id INT,
    discount_code_type_id INT
);

CREATE TABLE SA_Position (
    position_id INT,
    [description] VARCHAR(100),
    hours_of_work INT,
    maximum_hours_of_over_time INT,
    hours_of_work_leave INT,
    days_of_work_leave INT
);

CREATE TABLE SA_Contract_type (
    contract_type_id INT,
    [description] VARCHAR(100)
);

CREATE TABLE SA_Representative (
    representative_id INT,
    presented_id INT
);

drop table SA_Rollcall
CREATE TABLE SA_Rollcall (
    id INT,
    [date] DATE,
    employee_id INT,
    work_leave BIT,
    hours_of_work_leave INT,
	overtime int
);

drop TABLE SA_Commuting_time
CREATE TABLE SA_Commuting_time (
    id INT,
    [date] DATETIME,
	[time] time,
    employee_id INT,
    commuting bit, -- 0 : exit
);