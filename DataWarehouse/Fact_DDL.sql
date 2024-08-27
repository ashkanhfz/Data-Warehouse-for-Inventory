USE  DatawareHouse
Drop Table if exists trn_fact_HR;

CREATE TABLE trn_fact_HR (
    dateID date,
    EmployeeId INT,
    PositionID INT,
	------------------
    work_leave BIT,
    hours_of_work_leave INT,
	overtime int,
	work_time int
);

Drop Table if exists monthly_fact_HR;
CREATE TABLE monthly_fact_HR (
    dateID date,
    EmployeeId INT,
    PositionID INT,
	---------------
    monthly_DaysPresent INT,
    monthly_DaysAbsent INT,
    monthly_hours_of_work_leave int,
    monthly_OverTime int,
    monthly_MaximumOverTime int,
    tmonthly_work_time int
);
  

DROP TABLE IF exists acc_fact_HR;
CREATE TABLE acc_fact_HR (
    EmployeeId INT,
    PositionID INT,
	---------------
    TotalDaysPresent INT,
    TotalDaysAbsent INT,
    total_hours_of_work_leave int,
    total_OverTime int,
    total_MaximumOverTime int,
    total_work_time int
);

DROP TABlE IF EXISTS Factless_HR;
CREATE TABLE factless_HR (
    EmployeeID1 INT,
	EmployeeID2 INT
);


--------------------------
DROP TABLE IF exists trn_fact_inventory;
CREATE TABLE trn_fact_inventory (
    warehouse_SurrogateKey INT,
	warehouse_id INT,
    DateID VARCHAR(255),
    CompanyId INT,
	Product_SurrogateKey INT,
    ProductID INT,
	EmployeeID INT,
	---------------------
    QuantityReceived INT,
    QuantityOut INT,
    cost INT,
	price INT

);

DROP TABLE IF EXISTS periodic_fact_inventory;

CREATE TABLE periodic_fact_inventory (
    warehouse_SurrogateKey INT,
	warehouse_id INT,
    DateID VARCHAR(255),
    CompanyId INT,
	Product_SurrogateKey INT,
    ProductID INT,
	-------------------------
    DailyQuantityReceived INT,
    DailyQuantityOut INT,
    DailyQuantityOnHand INT,
    DayWithoutReceived INT,
	DayWithoutOUT INT,
	totalcost INT,
	totalprice INT
);

DROP TABLE IF EXISTS acc_fact_inventory;
CREATE TABLE acc_fact_inventory (
	warehouse_id INT,
    ProductID INT,
    CompanyId INT,
	-------------------------
    TotalQuantityReceived INT,
    TotalQuantityOut INT,
    TotalQuantityOnHand INT,
    NumberOfDayOutOfStock INT,
    NumberOfDaysNotReceived INT,
	NumberOfDaysNotOUT INT,
	TotalCost INT,
	TotalPrice INT
);

DROP TABLE IF EXISTS factless_fact_inventory;
CREATE TABLE factless_fact_inventory (
    WarehouseID INT,
    CustomerID INT
);
----------------------------------------

DROP TABLE IF EXISTS trn_fact_discount;
CREATE TABLE trn_fact_discount (
    DateID VARCHAR(255),
    warehouse_SurrogateKey INT,
	warehouse_id INT,
	CustomerID INT,
    EmployeeId INT,
    DiscountTypeID INT,
	Product_SurrogateKey INT,
	ProductId INT,
	-------------------------
    SalesAmount float,
    DiscountPercentage float,
    DiscountAmount float,
    QuantitySoldOfProduct INT,
    TimeTaken INT
);


DROP TABLE IF EXISTS Periodic_fact_discount;
CREATE TABLE Periodic_fact_discount (
    DiscountTypeID INT,
    DateID DATE,
    customerID INT,
	-----------------------------
    TotalSalesAmount float,
    AvgDiscountPercentage float,
    TotalDiscountAmount float,
    AvgDiscountAmount float,
	MaximumDiscountPercentage float,
    AvgQuantitySold float,
	TotalQuantitySold float,
    MaxTimeTaken INT,
    NumberOfUses INT
);

DROP TABLE IF EXISTS Acc_fact_discount;
CREATE TABLE Acc_fact_discount (
    DiscountTypeID INT,
    customerID INT,
	-----------------------------
    TotalSalesAmount float,
    AvgDiscountPercentage float,
    TotalDiscountAmount float,
    AvgDiscountAmount float,
	MaximumDiscountPercentage float,
    AvgQuantitySold float,
	TotalQuantitySold float,
    MaxTimeTaken INT,
    NumberOfUses INT
);


DROP TABLE IF EXISTS factless_fact_discount;
CREATE TABLE factless_fact_discount (
    CustomerID INT,
    DiscountTypeID INT
);

DROP TABLE IF EXISTS time_acc_fact_inventory;
create table time_acc_fact_inventory
(
	[date] date
)

DROP TABLE IF EXISTS time_acc_fact_discount;
create table time_acc_fact_discount
(
	[date] date
)


DROP TABLE IF EXISTS time_acc_fact_HR;
create table time_acc_fact_HR
(
	[date] date
)