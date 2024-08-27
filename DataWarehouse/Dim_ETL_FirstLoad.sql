use DatawareHouse
go

--------fill diemention
--------first load
GO
CREATE OR ALTER PROCEDURE first_fill_dim_company
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_company'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_company];

    INSERT INTO [DatawareHouse].[dbo].[dim_company]
        (Company_id, Name, Registration_Code, PhoneNumber, Email, Address, LocationID, State, CityName, CityCode)
    SELECT 
        com.company_id, com.name, com.registration_code, com.phone_number, com.email, com.address, 
        com.location_id, loc.state, city.city_name, city.city_code
    FROM [SA].[dbo].[SA_Company] AS com
    INNER JOIN [SA].[dbo].[SA_Location] AS loc ON com.location_id = loc.location_id
    INNER JOIN [SA].[dbo].[SA_City] AS city ON loc.city_code = city.city_code;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[dim_company]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_company'  , GETDATE() , 'end run procedure'   , '[DatawareHouse].[dbo].[dim_company]' , @number_of_rows)

END;
--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_customer
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_customer'  , GETDATE() , 'start run procedure'   , ' ' , 0)

    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_customer];

    INSERT INTO [DataWarehouse].[dbo].[dim_customer]
        (Customer_id, Name, LastName, NationalId, Gender, Phone, Email, CurrentAddress, OriginalAddress, EffectiveDate)
    SELECT 
        cus.customer_id, cus.name, cus.last_name, cus.national_id, 
        cus.gender AS Gender, 
        cus.phone_number, cus.email, cus.address, NULL, CONVERT(DATE, GETDATE())
    FROM [SA].[dbo].[SA_Customer] AS cus;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_customer'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_customer]' , @number_of_rows)
END;

--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_discountType
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_discountType'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_discountType];

    INSERT INTO [DataWarehouse].[dbo].[dim_discountType]
        (DiscountTypeId, DiscountTypeDescription, MinimumPurchase, StartDate, EndDate, CategoryID, CategoryName, CategoryDescription)
    SELECT 
        dis.discount_code_type_id, dis.description, dis.minimum_purchase, dis.start_date, dis.end_date, 
        dis.category_id, cat.category_name, cat.category_description
    FROM [SA].[dbo].[SA_Discount_code_type] AS dis
    INNER JOIN [SA].[dbo].[SA_Category] AS cat ON dis.category_id = cat.category_id;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_discountType]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_discountType'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_discountType]' , @number_of_rows)
END;
--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_employee
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_employee'  , GETDATE() , 'start run procedure'   , ' ' , 0)

    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_employee];

    INSERT INTO [DataWarehouse].[dbo].[dim_employee]
        (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
        OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
        OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
        ContractTypeDescription)
    SELECT 
        emp.employee_id, emp.name, emp.last_name, emp.gender, emp.phone_number, emp.email, 
        emp.hire_date, emp.warehouse_id, null, CONVERT(DATE, GETDATE()), 
        emp.position_id, pos.description, null, null, 
        CONVERT(DATE, GETDATE()), emp.contract_type_id, con.description
    FROM [SA].[dbo].[SA_Employee] AS emp
    INNER JOIN [SA].[dbo].[SA_Position] AS pos ON emp.position_id = pos.position_id
    INNER JOIN [SA].[dbo].[SA_Contract_type] AS con ON emp.contract_type_id = con.contract_type_id;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_employee]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_employee'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_employee]' , @number_of_rows)
END;
--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_location
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_location'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_location];

    INSERT INTO [DataWarehouse].[dbo].[dim_location]
        (LocationID, State, CityCode, CityName)
    SELECT 
        loc.location_id, loc.state, loc.city_code, city.city_name
    FROM [SA].[dbo].[SA_Location] AS loc
    INNER JOIN [SA].[dbo].[SA_City] AS city ON loc.city_code = city.city_code;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_location]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_location'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_location]' , @number_of_rows)
END;
--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_position
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_position'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_position];

    INSERT INTO [DataWarehouse].[dbo].[dim_position]
        (PositionId, PositionDescription, HoursOfWorkLeave, MaximumHoursOfOverTime, HoursOfWork, DaysOfWorkLeave)
    SELECT 
        pos.position_id, pos.description, pos.hours_of_work_leave, pos.maximum_hours_of_over_time, 
        pos.hours_of_work, pos.days_of_work_leave
    FROM [SA].[dbo].[SA_Position] AS pos;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_position]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_position'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_position]' , @number_of_rows)
END;
--------------------------------------------------------------------------------
go
create or alter PROCEDURE first_fill_dim_product
as
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_product'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_product];

    insert into [DataWarehouse].[dbo].[dim_product] 
        ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
        , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
        , EndDate, Currentflag,bits)
    select 
        row_number() OVER(ORDER BY pr.product_id) , product_id, pr.name, product_description, pr.category_id, category_name
        , category_description, pr.company_id, com.name, price, cost, GETDATE()
        , NULL, 1, '00'
    from [SA].[dbo].[SA_Product] as pr 
        INNER JOIN [SA].[dbo].[SA_Company] as com on pr.[Company_ID]=com.[company_id]
        inner JOIN [SA].[dbo].[SA_Category] as cat on pr.[category_id]= cat.[category_id]

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_product] 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_product'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_product] ' , @number_of_rows)
end; 
--------------------------------------------------------------------------------
go 
Create or alter PROCEDURE first_fill_Dim_time
as 
BEGIN 

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_Dim_time'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	TRUNCATE TABLE  [DataWarehouse].[dbo].[dim_time]

	DECLARE @h INT;
	DECLARE @m INT;
	DECLARE @s INT;
	DECLARE @id VARCHAR(6);

	SET @h = 0;
	WHILE @h <= 23
	BEGIN
		SET @m = 0;
		WHILE @m <= 59
		BEGIN
			SET @s = 0;
			WHILE @s <= 59
			BEGIN
				SET @id = RIGHT('00' + CONVERT(VARCHAR(2), @h), 2) + RIGHT('00' + CONVERT(VARCHAR(2), @m), 2) + RIGHT('00' + CONVERT(VARCHAR(2), @s), 2);
            
				INSERT INTO dim_time (Timeid, Hour, Minute, Second)
				VALUES (@id, @h, @m, @s);

				SET @s = @s + 1;
			END
			SET @m = @m + 1;
		END
		SET @h = @h + 1;
	END
declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_time]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_Dim_time'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_time]' , @number_of_rows)
ENd;
--------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE first_fill_dim_warehouse
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_warehouse'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE [DataWarehouse].[dbo].[dim_warehouse];

    INSERT INTO [DataWarehouse].[dbo].[dim_warehouse]
        (SurrogateWarehouseKey, Warehouse_id, WarehouseName, WarehouseDescription, ManagerID, 
        Currentflag, EndDate, StartDate, LocationID, State, CityCode, CityName)
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ware.warehouse_id) AS SurrogateWarehouseKey, 
        ware.warehouse_id, ware.warehouse_name, ware.warehouse_description, ware.manager_id, 
        1 AS Currentflag, NULL AS EndDate, CONVERT(DATE, GETDATE()), ware.location_id, loc.state, 
        city.city_code, city.city_name
    FROM [SA].[dbo].[SA_Warehouse] AS ware
    INNER JOIN [SA].[dbo].[SA_Location] AS loc ON ware.location_id = loc.location_id
    INNER JOIN [SA].[dbo].[SA_City] AS city ON loc.city_code = city.city_code;

declare @number_of_rows int;
select @number_of_rows = count(*) from [DataWarehouse].[dbo].[dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'first_fill_dim_warehouse'  , GETDATE() , 'end run procedure'   , '[DataWarehouse].[dbo].[dim_warehouse]' , @number_of_rows)
END;
--------------------------------------------------------------------------------