USE DatawareHouse;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS dim_Date;
DROP TABLE IF EXISTS dim_employee;
DROP TABLE IF EXISTS dim_Product;
DROP TABLE IF EXISTS dim_position;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_Company;
DROP TABLE IF EXISTS dim_Warehouse;
DROP TABLE IF EXISTS dim_discountType;
DROP TABLE IF EXISTS dim_Location;
DROP TABLE IF EXISTS tmp1_dim_customer;
DROP TABLE IF EXISTS tmp2_dim_customer;
DROP TABLE IF EXISTS tmp3_dim_customer;
DROP TABLE IF EXISTS [Log];

-- Create tables
CREATE TABLE dim_Date (
    Date_id VARCHAR(255),
    Date DATE,
    Day INT,
    DayOfWeek VARCHAR(20),
    Week INT,
    Month VARCHAR(20),
    Quarter INT,
    Year INT
);

CREATE TABLE dim_employee (
    Employee_id INT,
    Name VARCHAR(255),
    LastName VARCHAR(255),
    gender VARCHAR(50),
    Phone VARCHAR(50),
    Email VARCHAR(255),
    HireDate DATE,
    CurrentWarehouseID INT,
    OriginalWareHouseID INT,
    EffectiveDateW DATE,
    CurrentPositionID INT,
    CurrentPositionDesc VARCHAR(255),
    OriginalPositionID INT,
    OriginalPositionDesc VARCHAR(255),
    EffectiveDateP DATE,
    ContractTypeID INT,
    ContractTypeDescription VARCHAR(255)
);

CREATE TABLE dim_Product (
    SurrogateKey INT,
    Product_id INT,
    ProductName VARCHAR(255),
    ProductDescription VARCHAR(255),
    CategoryId INT,
    CategoryName VARCHAR(255),
    CategoryDescription VARCHAR(255),
    CompanyID INT,
    CompanyName VARCHAR(255),
    ProductionPrice INT,
    CostPrice INT,
    StartDate DATE,
    EndDate DATE,
    Currentflag VARCHAR(10),
    bits VARCHAR(10)
);

CREATE TABLE dim_position (
    PositionId INT,
    PositionDescription VARCHAR(255),
    HoursOfWorkLeave INT,
    MaximumHoursOfOverTime INT,
    HoursOfWork INT,
    DaysOfWorkLeave INT
);

CREATE TABLE dim_customer (
    Customer_id INT,
    Name NVARCHAR(255),
    LastName NVARCHAR(255),
    NationalID INT,
    Gender VARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(255),
    CurrentAddress NVARCHAR(255),
    OriginalAddress NVARCHAR(255),
    EffectiveDate DATE
);

CREATE TABLE dim_company (
    Company_id INT,
    Name VARCHAR(255),
    Registration_Code VARCHAR(50),
    PhoneNumber VARCHAR(50),
    Email VARCHAR(255),
    Address VARCHAR(255),
    LocationID INT,
    State VARCHAR(50),
    CityName VARCHAR(255),
    CityCode INT
);

CREATE TABLE dim_warehouse (
    SurrogateWarehouseKey INT,
    Warehouse_id INT,
    WarehouseName VARCHAR(255),
    WarehouseDescription VARCHAR(255),
    ManagerID INT,
    Currentflag BIT,
    EndDate DATE,
    StartDate DATE,
    LocationID INT,
    State VARCHAR(50),
    CityCode INT,
    CityName VARCHAR(255)
);

CREATE TABLE dim_discountType (
    DiscountTypeId INT,
    DiscountTypeDescription VARCHAR(255),
    MinimumPurchase INT,
    StartDate DATE,
    EndDate DATE,
    CategoryID INT,
    CategoryName VARCHAR(255),
    CategoryDescription VARCHAR(255)
);

CREATE TABLE dim_location (
    LocationID INT PRIMARY KEY,
    State VARCHAR(50),
    CityCode INT,
    CityName VARCHAR(255)
);

CREATE TABLE tmp1_dim_customer (
    Customer_id INT,
    Name NVARCHAR(255),
    LastName NVARCHAR(255),
    NationalID INT,
    Gender VARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(255),
    CurrentAddress NVARCHAR(255),
    OriginalAddress NVARCHAR(255),
    EffectiveDate DATE
);

CREATE TABLE tmp2_dim_customer (
    Customer_id INT,
    Name NVARCHAR(255),
    LastName NVARCHAR(255),
    NationalID INT,
    Gender VARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(255),
    Address NVARCHAR(255)
);

CREATE TABLE tmp3_dim_customer (
    Customer_id INT,
    Name NVARCHAR(255),
    LastName NVARCHAR(255),
    NationalID INT,
    Gender VARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(255),
    CurrentAddress NVARCHAR(255),
    OriginalAddress NVARCHAR(255),
    EffectiveDate DATE
);

create  table Log(
procedure_name varchar(50),
date datetime,
description varchar(256),
table_name varchar(50),
number_of_row_inserted varchar(50)
)