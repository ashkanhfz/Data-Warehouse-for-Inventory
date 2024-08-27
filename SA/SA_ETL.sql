use SA;

GO
create or alter procedure Fill_SA_Category
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Category'  , GETDATE() , 'start run procedure'   , ' ' , 0 )

truncate table SA.dbo.SA_Category

declare @number_of_rows int;

insert into SA.dbo.SA_Category (category_id,category_name,category_description) 
select category_id,
    category_name,
    category_description
	from [Source].dbo.Category

select @number_of_rows = count(*) from [Source].dbo.Category
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Category'  , GETDATE() , 'end run procedure'   , '[Source].dbo.Category' , @number_of_rows)

end
-------------------------------------------------------------------------------
go
create or alter procedure Fill_SA_City
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_City'  , GETDATE() , 'start run procedure'   , ' ' , 0 )

truncate table SA.dbo.SA_City;

insert into SA.dbo.SA_City(city_code,city_name,city_description) 
select city_code,
	city_name,
	city_description
	from [Source].dbo.City

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.City
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_City'  , GETDATE() , 'end run procedure'   , '[Source].dbo.City' , @number_of_rows)
end
-------------------------------------------------------------------------------
go
create or alter procedure Fill_SA_Company
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Company'  , GETDATE() , 'start run procedure'   , ' ' , 0 )
truncate table SA.dbo.SA_Company;

insert into SA.dbo.SA_Company(company_id,[name],registration_code,phone_number,email,[address],location_id) 
select company_id,
	[name],
	registration_code,
	phone_number,
	email,
	[address],
	location_id
	from [Source].dbo.Company

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.Company
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Company'  , GETDATE() , 'end run procedure'   , '[Source].dbo.Company' , @number_of_rows)
end
-------------------------------------------------------------------------------
go
create or alter procedure Fill_SA_Contract_type
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Contract_type'  , GETDATE() , 'start run procedure'   , ' ' , 0)
truncate table SA.dbo.SA_Contract_type

insert into SA.dbo.SA_Contract_type(contract_type_id,[description]) 
select contract_type_id,
	[description]
	from [Source].dbo.Contract_type

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.Contract_type
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Contract_type'  , GETDATE() , 'end run procedure'   , '[Source].dbo.Contract_type' , @number_of_rows)
end
-------------------------------------------------------------------------------
go
CREATE OR ALTER PROCEDURE Fill_SA_Customer
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Customer'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA.dbo.SA_Customer;

    INSERT INTO SA.dbo.SA_Customer(
           [customer_id]
          ,[name]
          ,[last_name]
          ,[national_id]
          ,[gender]
          ,[phone_number]
          ,[email]
          ,[address])
    SELECT 
           [customer_id]
          ,[name]
          ,[last_name]
          ,[national_id]
          ,CASE WHEN [gender] = 1 THEN 'MALE' ELSE 'FEMALE' END
          ,[phone_number]
          ,[email]
          ,[address]
    FROM [Source].[dbo].[Customer];

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Customer'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Customer]' , @number_of_rows)
END;
-------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE Fill_SA_Discount_Code_Type
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Discount_Code_Type'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA.dbo.SA_Discount_Code_Type;

    INSERT INTO SA.dbo.SA_Discount_Code_Type(
           [discount_code_type_id]
		  ,[description]
		  ,[minimum_purchase]
		  ,[start_date]
		  ,[end_date]
		  ,[category_id])
    SELECT [discount_code_type_id]
		  ,[description]
		  ,[minimum_purchase]
		  ,[start_date]
		  ,[end_date]
		  ,[category_id]
    FROM [Source].[dbo].[Discount_Code_Type];
declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Discount_Code_Type]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Discount_Code_Type'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Discount_Code_Type]' , @number_of_rows)
END;
-------------------------------------------------------------------------------
go
CREATE OR ALTER PROCEDURE Fill_SA_Discount_Code
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Discount_Code'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA.dbo.SA_Discount_Code;

    INSERT INTO SA.dbo.SA_Discount_Code(
           [discount_code_id]
		  ,customer_id
		  ,discount_code_type_id)
    SELECT [discount_code_id]
		  ,customer_id
		  ,discount_code_type_id
    FROM [Source].[dbo].[Discount_Code];
declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Discount_Code]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Discount_Code'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Discount_Code]' , @number_of_rows)
END;
-------------------------------------------------------------------------------
go
create or alter procedure Fill_SA_Employee
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Employee'  , GETDATE() , 'start run procedure'   , ' ' , 0)
truncate table SA.dbo.SA_Employee

insert into SA.dbo.SA_Employee(employee_id,[name],last_name,gender,phone_number,email,hire_date,warehouse_id,position_id,contract_type_id,job_title)
select employee_id,
	[name],
	last_name,
	case gender when 1 then 'Male' when 0 then 'Female' end,
	phone_number,
	email,
	hire_date,
	warehouse_id,
	position_id,
	contract_type_id,
	job_title
	from [Source].dbo.Employee

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.Employee
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Employee'  , GETDATE() , 'end run procedure'   , '[Source].dbo.Employee' , @number_of_rows)
end
-------------------------------------------------------------------------------
go
create or alter procedure Fill_SA_Location
as
begin 
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Location'  , GETDATE() , 'start run procedure'   , ' ' , 0)
truncate table SA.dbo.SA_Location

insert into SA.dbo.SA_Location(location_id,[state],city_code) 
select location_id,
	[state],
	city_code
	from [Source].dbo.[Location]

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.[Location]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Location'  , GETDATE() , 'end run procedure'   , '[Source].dbo.[Location]' , @number_of_rows)
end
-------------------------------------------------------------------------------
GO
create or Alter PROCEDURE Fill_SA_Position
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Position'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA_Position;

    insert into SA_Position(position_id,description,hours_of_work,maximum_hours_of_over_time,hours_of_work_leave,days_of_work_leave)
    SELECT 
        position_id,description,hours_of_work,maximum_hours_of_over_time,hours_of_work_leave,days_of_work_leave
    from [Source].[dbo].[Position]

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Position]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Position'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Position]' , @number_of_rows)
END
-------------------------------------------------------------------------------
GO
create or Alter PROCEDURE Fill_SA_Product
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Product'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA_Product;

    insert into SA_Product(
	   [product_id]
      ,[name]
      ,[product_description]
      ,[category_id]
      ,[company_id]
      ,[price]
      ,[cost])
    SELECT 
       [product_id]
      ,[name]
      ,[product_description]
      ,[category_id]
      ,[company_id]
      ,[price]
      ,[cost]
    from [Source].[dbo].[Product]

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Position]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Product'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Product]' , @number_of_rows)
END
-------------------------------------------------------------------------------
GO
create or Alter PROCEDURE Fill_SA_Representative
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Representative'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA_Representative;

    insert into SA_Representative(representative_id,[presented_id])
    SELECT 
        representative_id,presented_id
    from [Source].[dbo].[Representative]

declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Representative]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Representative'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Representative]' , @number_of_rows)
END
-------------------------------------------------------------------------------
GO
create or Alter PROCEDURE Fill_SA_Warehouse
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    TRUNCATE TABLE SA_Warehouse;

    insert into SA_Warehouse(warehouse_id,warehouse_name,warehouse_description,manager_id,location_id)
    SELECT 
        warehouse_id,warehouse_name,warehouse_description,manager_id,location_id
    from [Source].[dbo].[Warehouse]

	declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].[dbo].[Warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse'  , GETDATE() , 'end run procedure'   , '[Source].[dbo].[Warehouse]' , @number_of_rows)
END
-------------------------------------------------------------------------------
go
CREATE OR ALTER PROCEDURE Fill_SA_Cummuting_time
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Cummuting_time'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    DECLARE @minimum_date DATE;
    DECLARE @end_date DATE;
    DECLARE @current_day DATE;

    SELECT @minimum_date = MIN([date]) FROM [Source].[dbo].[Commuting_time];
    SELECT @end_date = MAX([date]) FROM [Source].[dbo].[Commuting_time];
    SELECT @current_day = ISNULL((SELECT DATEADD(DAY, 1, MAX([date])) FROM [dbo].[SA_Commuting_time]), @minimum_date);
	declare @number_of_rows int;
	select @number_of_rows = count(*) from  sa.[dbo].[SA_Commuting_time]

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO sa.[dbo].[SA_Commuting_time] (
            id,
		[date] ,
		[time] ,
		employee_id ,
		commuting 
        )
        SELECT 
               id,
		[date] ,
		[time] ,
		employee_id ,
		[commuting] 
   
        FROM [Source].[dbo].[Commuting_time]
        WHERE [date] >= @current_day AND [date] < DATEADD(DAY, 1, @current_day);

		select @number_of_rows = count(*) - @number_of_rows from sa.[dbo].[SA_Commuting_time]
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
	(  'Fill_SA_Cummuting_time'  , GETDATE() , concat ( 'insert data of ', convert ( varchar,@current_day ))  , 'sa.[dbo].[SA_Commuting_time]' , @number_of_rows)
        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Cummuting_time'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
-------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE Fill_SA_RollCall
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_RollCall'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    DECLARE @minimum_date DATE;
    DECLARE @end_date DATE;
    DECLARE @current_day DATE;

    SELECT @minimum_date = MIN([date]) FROM [Source].[dbo].[Rollcall];
    SELECT @end_date =  MAX([date]) FROM [Source].[dbo].[Rollcall];
    SELECT @current_day = ISNULL((SELECT DATEADD(DAY, 1, MAX([date])) FROM [dbo].[SA_Rollcall]), @minimum_date);
	declare @number_of_rows int;
	select @number_of_rows = count(*) from  sa.[dbo].[SA_Rollcall]

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO sa.[dbo].[SA_Rollcall] (
            id  ,
			[date] ,
			employee_id ,
			work_leave ,
			hours_of_work_leave ,
			overtime
        )
        SELECT 
              id  ,
			[date] ,
			employee_id ,
			work_leave ,
			hours_of_work_leave ,
			overtime
        FROM [Source].[dbo].[Rollcall]
        WHERE [date] >= @current_day AND [date] < DATEADD(DAY, 1, @current_day);

		select @number_of_rows = count(*) - @number_of_rows from sa.[dbo].[SA_Rollcall]
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
	(  'Fill_SA_RollCall'  , GETDATE() , concat ( 'insert data of ', convert ( varchar,@current_day))   , 'sa.[dbo].[SA_Rollcall]' , @number_of_rows)

        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_RollCall'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
-------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE Fill_SA_Warehouse_Entrance
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse_Entrance'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    DECLARE @minimum_date date;
    DECLARE @end_date date;
    DECLARE @current_day date;

    SELECT @minimum_date = MIN([time]) FROM [Source].[dbo].[warehouse_entrance];
    SELECT @end_date =  MAX([time]) FROM [Source].[dbo].[warehouse_entrance];
    SELECT @current_day = ISNULL((SELECT DATEADD(DAY, 1, MAX([time])) FROM [SA].[dbo].[SA_Warehouse_Entrance]), @minimum_date);
	declare @number_of_rows int;
	select @number_of_rows = count(*) from  [SA].[dbo].[SA_Warehouse_Entrance]

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO [SA].[dbo].[SA_Warehouse_Entrance] (
            [id],
            [warehouse_id],
            [product_id],
            [quantity],
            [time],
			EmployeeID
        )
        SELECT 
            [id],
            [warehouse_id],
            [product_id],
            [quantity],
            [time],
			EmployeeID
        FROM [Source].[dbo].[Warehouse_Entrance]
        WHERE [time] >= @current_day AND [time] < DATEADD(DAY, 1, @current_day);

		select @number_of_rows = count(*) - @number_of_rows from [SA].[dbo].[SA_Warehouse_Entrance]
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
	(  'Fill_SA_Warehouse_Entrance'  , GETDATE() , concat ( 'insert data of ', convert ( varchar,@current_day ))  , '[SA].[dbo].[SA_Warehouse_Entrance]' , @number_of_rows)

        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;

		insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse_Entrance'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
-------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE Fill_SA_Warehouse_Outlet
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse_Outlet'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    DECLARE @minimum_date date;
    DECLARE @end_date date;
    DECLARE @current_day date;

    SELECT @minimum_date = MIN([time]) FROM [Source].[dbo].[Warehouse_Outlet];
    SELECT @end_date =  MAX([time]) FROM [Source].[dbo].[Warehouse_Outlet];
    SELECT @current_day = ISNULL((SELECT DATEADD(DAY, 1, MAX([time])) FROM [SA].[dbo].[SA_Warehouse_Outlet]), @minimum_date);
		declare @number_of_rows int;
	select @number_of_rows = count(*) from  [SA].[dbo].SA_Warehouse_Outlet

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO [SA].[dbo].[SA_Warehouse_Outlet] (
            [id],
            [warehouse_id],
            [product_id],
            [customer_id],
            [quantity],
            [time],
			EmployeeID,
			DiscountID
        )
        SELECT 
            [id],
            [warehouse_id],
            [product_id],
            [customer_id],
            [quantity],
            [time],
			EmployeeID,
			DiscountID
        FROM [Source].[dbo].[Warehouse_Outlet]
        WHERE [time] >= @current_day AND [time] < DATEADD(DAY, 1, @current_day);

		select @number_of_rows = count(*) - @number_of_rows from  [SA].[dbo].SA_Warehouse_Outlet
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
	(  'Fill_SA_Warehouse_Outlet'  , GETDATE() , concat ( 'insert data of ', convert ( varchar,@current_day ))  , ' [SA].[dbo].SA_Warehouse_Outlet' , @number_of_rows)

        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;
		insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Warehouse_Outlet'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
-------------------------------------------------------------------------------
GO
create or Alter PROCEDURE Fill_SA_Representative
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Representative'  , GETDATE() , 'start run procedure'   , ' ' , 0 )
    TRUNCATE TABLE SA_Representative;

    insert into SA_Representative(representative_id,presented_id)
    SELECT 
        representative_id,presented_id
    from [Source].[dbo].[Representative]
declare @number_of_rows int;
select @number_of_rows = count(*) from [Source].dbo.City
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_SA_Representative'  , GETDATE() , 'end run procedure'   , '[Source].dbo.City' , @number_of_rows)
END
