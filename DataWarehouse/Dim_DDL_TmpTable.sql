use DatawareHouse
go

DROP TABLE IF EXISTS tmp1_dim_warehouse;
CREATE TABLE tmp1_dim_warehouse (
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

DROP TABLE IF EXISTS tmp2_dim_warehouse;
CREATE TABLE tmp2_dim_warehouse (
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

DROP TABLE IF EXISTS tmp3_dim_warehouse;
CREATE TABLE tmp3_dim_warehouse (
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

Drop Table If Exists tmp_dim_DiscountType;
Create Table tmp_dim_DiscountType(
	    DiscountTypeId INT ,
		DiscountTypeDescription VarCHAR(255),
		MinimumPurchase INT,
		StartDate DATE,
		EndDate DATE,
		CategoryID INT,
		CategoryName VARCHAR(255),
		CategoryDescription VARCHAR(255)
);

DROP TABLE IF EXISTS tmp_dim_Company;
CREATE TABLE tmp_dim_Company (
    Company_id INT,
    Name VARCHAR(255),
    Registration_Code VARCHAR(50),
    PhoneNumber VARCHAR(20),
    Email VARCHAR(255),
    Address VARCHAR(255),
    LocationID INT,
    State VARCHAR(50),
    CityName VARCHAR(255),
    CityCode INT
);

DROP TABLE IF EXISTS tmp_dim_Location;
CREATE TABLE tmp_dim_Location (
    LocationID INT PRIMARY KEY,
    State VARCHAR(50),
    CityCode INT,
    CityName VARCHAR(255)
);

DROP TABLE IF EXISTS tmp_dim_Position;
CREATE TABLE tmp_dim_Position (
    PositionId INT,
    PositionDescription VARCHAR(255),
    HoursOfWorkLeave INT,
    MaximumHoursOfOverTime INT,
    HoursOfWork INT,
    DaysOfWorkLeave INT
);

DROP TABLE IF EXISTS tmp1_dim_product;
 CREATE  TABLE tmp1_dim_product (
         SurrogateKey INT PRIMARY KEY,
         Product_id INT,
         ProductName VARCHAR(255),
         ProductDescription VARCHAR(255),
         CategoryId INT,
         CategoryName VARCHAR(255),
         CategoryDescription VARCHAR(255),
         CompanyID INT,
         CompanyName VARCHAR(255),
         ProductionPrice DECIMAL(10, 2),
         CostPrice DECIMAL(10, 2),
         StartDate DATE,
         EndDate DATE,
         Currentflag bit,
         bits varchar(2)    
);

DROP TABLE IF EXISTS tmp2_dim_product;
CREATE  TABLE tmp2_dim_product (
    Product_id INT,
    ProductName VARCHAR(255),
    ProductDescription VARCHAR(255),
    CategoryId INT,
    CategoryName VARCHAR(255),
    CategoryDescription VARCHAR(255),
    CompanyID INT,
    CompanyName VARCHAR(255),
    ProductionPrice DECIMAL(10, 2),
    CostPrice DECIMAL(10, 2)
);

DROP TABLE IF EXISTS tmp3_dim_product;
     CREATE  TABLE tmp3_dim_product (
         SurrogateKey INT PRIMARY KEY,
         Product_id INT,
         ProductName VARCHAR(255),
         ProductDescription VARCHAR(255),
         CategoryId INT,
         CategoryName VARCHAR(255),
         CategoryDescription VARCHAR(255),
         CompanyID INT,
         CompanyName VARCHAR(255),
         ProductionPrice DECIMAL(10, 2),
         CostPrice DECIMAL(10, 2),
         StartDate DATE,
         EndDate DATE,
         Currentflag bit,
         bits varchar(2) 
);






drop table if EXISTS temp_dim_employee;
CREATE TABLE temp_dim_employee (
    Employee_id INT ,
    Name VARCHAR(255),
    LastName VARCHAR(255),
    gender VARCHAR(255),
    Phone VARCHAR(255),
    Email VARCHAR(255),
	HireDate DATE,
	CurrentWarehouseID INT,
	OriginalWareHouseID INT,
	EffectiveDateW Date,
    CurrentPositionID INT,
    CurrentPositionDesc VARCHAR(255),
    OriginalPositionID INT,
    OriginalPositionDesc VARCHAR(255),
    EffectiveDateP DATE,
    ContractTypeID INT,
    ContractTypeDescription VARCHAR(255)
);


drop table if EXISTS temp_sa_employee;
CREATE TABLE temp_sa_employee (
    Employee_id INT ,
    Name VARCHAR(255),
    LastName VARCHAR(255),
    gender VARCHAR(255),
    Phone VARCHAR(255),
    Email VARCHAR(255),
	HireDate DATE,
	CurrentWarehouseID INT,
	OriginalWareHouseID INT,
	EffectiveDateW Date,
    CurrentPositionID INT,
    CurrentPositionDesc VARCHAR(255),
    OriginalPositionID INT,
    OriginalPositionDesc VARCHAR(255),
    EffectiveDateP DATE,
    ContractTypeID INT,
    ContractTypeDescription VARCHAR(255)
);

drop table if EXISTS temp_employee;
CREATE TABLE temp_employee (
    Employee_id INT ,
    Name VARCHAR(255),
    LastName VARCHAR(255),
    gender VARCHAR(255),
    Phone VARCHAR(255),
    Email VARCHAR(255),
	HireDate DATE,
	CurrentWarehouseID INT,
	OriginalWareHouseID INT,
	EffectiveDateW Date,
    CurrentPositionID INT,
    CurrentPositionDesc VARCHAR(255),
    OriginalPositionID INT,
    OriginalPositionDesc VARCHAR(255),
    EffectiveDateP DATE,
    ContractTypeID INT,
    ContractTypeDescription VARCHAR(255)
);

