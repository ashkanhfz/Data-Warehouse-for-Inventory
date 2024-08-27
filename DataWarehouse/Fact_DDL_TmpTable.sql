use DatawareHouse
go

DROP TABlE IF EXISTS tmp_Factless_HR;
CREATE TABLE tmp_factless_HR (
    EmployeeID1 INT,
	EmployeeID2 INT
);

DROP TABLE IF EXISTS tmp_factless_fact_discount;
CREATE TABLE tmp_factless_fact_discount (
    CustomerID INT,
    DiscountTypeID INT
);

DROP TABLE IF EXISTS tmp1_trn_fact_inventory;
CREATE TABLE tmp1_trn_fact_inventory (
    warehouse_SurrogateKey INT,
    warehouse_id INT,
    DateID VARCHAR(255),
    CompanyId INT,
    Product_SurrogateKey INT,
    ProductID INT,
    EmployeeID INT,
    QuantityReceived INT,
    QuantityOut INT,
    cost INT,
	price INT
);




DROP TABLE IF EXISTS tmp_periodic_fact_inventory;

CREATE TABLE tmp_periodic_fact_inventory (
    warehouse_SurrogateKey INT,
    warehouse_id INT,
    DateID VARCHAR(255),
    CompanyId INT,
    Product_SurrogateKey INT,
    ProductID INT,
    DailyQuantityReceived INT,
    DailyQuantityOut INT,
    DailyQuantityOnHand INT,
    DayWithoutReceived INT,
    DayWithoutOUT INT,
    totalcost INT,
    totalprice INT
);

DROP TABLE IF EXISTS tmp_acc_fact_inventory;
CREATE TABLE tmp_acc_fact_inventory (
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

DROP TABLE IF EXISTS tmp1_acc_fact_inventory;
CREATE TABLE tmp1_acc_fact_inventory (
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

DROP TABLE IF EXISTS tmp2_acc_fact_inventory;
CREATE TABLE tmp2_acc_fact_inventory (
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

DROP TABLE IF EXISTS tmp1_trn_fact_discount;
CREATE TABLE tmp1_trn_fact_discount (
    DateID VARCHAR(255),
    warehouse_SurrogateKey INT,
    warehouse_id INT,
    CustomerID INT,
    EmployeeId INT,
    DiscountTypeID INT,
    Product_SurrogateKey INT,
    ProductID INT,
    SalesAmount float,
    DiscountPercentage float,
    DiscountAmount float,
    QuantitySoldOfProduct INT,
    TimeTaken INt
);


DROP TABLE IF EXISTS Tmp_Acc_fact_discount;
CREATE TABLE Tmp_Acc_fact_discount (
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

DROP TABLE IF EXISTS Tmp1_Acc_fact_discount;
CREATE TABLE Tmp1_Acc_fact_discount (
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

DROP TABLE IF EXISTS Tmp2_Acc_fact_discount;
CREATE TABLE Tmp2_Acc_fact_discount (
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


DROP TABLE IF exists tmp_acc_fact_HR;
CREATE TABLE tmp_acc_fact_HR (
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

DROP TABLE IF exists tmp1_acc_fact_HR;
CREATE TABLE tmp1_acc_fact_HR (
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

DROP TABLE IF exists tmp2_acc_fact_HR;
CREATE TABLE tmp2_acc_fact_HR (
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

DROP TABLE IF EXISTS tmp_cros_join_dimD_dimC;
CREATE TABLE tmp_cros_join_dimD_dimC(
	DimD_DiscountTypeId INT,
	dimC_CustomerId INT
);
drop TAble if exists tmp_cros_join_dimW_dimP;
CREATE TABLE tmp_cros_join_dimW_dimP(
	dimW_SurrogateWarehouseKey int ,
	dimW_warehouse_id int,
	dimP_CompanyId int,
	dimP_SurrogateKey int ,
	dimP_Product_id int,
	dimP_CostPrice int,
	dimP_ProductionPrice int
);