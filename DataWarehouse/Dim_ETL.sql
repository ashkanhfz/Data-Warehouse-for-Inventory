use DatawareHouse
go
------------load diemention
-----------------------------

GO
CREATE OR ALTER PROCEDURE Fill_dim_warehouse
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    IF (NOT (NOT EXISTS (SELECT 1 FROM [DatawareHouse].[dbo].[dim_warehouse]) 
            AND EXISTS (SELECT 1 FROM [DatawareHouse].[dbo].[tmp3_dim_warehouse])))
    BEGIN 
        TRUNCATE TABLE [DatawareHouse].[dbo].[tmp1_dim_warehouse];
        TRUNCATE TABLE [DatawareHouse].[dbo].[tmp2_dim_warehouse];
        TRUNCATE TABLE [DatawareHouse].[dbo].[tmp3_dim_warehouse];

        INSERT INTO [DatawareHouse].[dbo].[tmp1_dim_warehouse] (
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        FROM [DatawareHouse].[dbo].[dim_warehouse];
declare @number_of_rows int;
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp1_dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'insert dim data'   , '[DatawareHouse].[dbo].[tmp1_dim_warehouse]' , @number_of_rows)
        INSERT INTO [DatawareHouse].[dbo].[tmp2_dim_warehouse] (
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT
            SA_W.Warehouse_id,
            SA_W.Warehouse_Name,
            SA_W.Warehouse_Description,
            SA_W.Manager_ID,
            1,
            NULL,
            GETDATE(),
            SA_L.Location_ID,
            SA_L.State,
            SA_CI.City_Code,
            SA_CI.City_Name
        FROM [SA].[dbo].[SA_Warehouse] AS SA_W
        INNER JOIN [SA].[dbo].[SA_Location] AS SA_L ON SA_W.Location_ID = SA_L.Location_ID
        INNER JOIN [SA].[dbo].[SA_CITY] AS SA_CI ON SA_CI.City_Code = SA_L.City_Code;

select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp2_dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'insert sa data'   , '[DatawareHouse].[dbo].[tmp2_dim_warehouse]' , @number_of_rows)

        INSERT INTO [DatawareHouse].[dbo].[tmp3_dim_warehouse] (
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        FROM [DatawareHouse].[dbo].[tmp1_dim_warehouse] AS x
        WHERE x.Currentflag = 0 OR (
            x.Currentflag = 1 AND EXISTS (
                SELECT 1 
                FROM [DatawareHouse].[dbo].[tmp2_dim_warehouse] AS y 
                WHERE x.Warehouse_id = y.Warehouse_id AND x.ManagerID = y.ManagerID
            )
			OR (
            x.Currentflag = 1 AND x.Warehouse_id not in ( select s.Warehouse_id from tmp2_dim_warehouse as  s) )
        );

select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp3_dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'insert'   , '[DatawareHouse].[dbo].[tmp3_dim_warehouse]' , @number_of_rows)

        DECLARE @MAXIMUM_Warehouse_Surrogate INT;
        SELECT @MAXIMUM_Warehouse_Surrogate = MAX(SurrogateWarehouseKey) 
        FROM [DatawareHouse].[dbo].[tmp1_dim_warehouse];

        INSERT INTO [DatawareHouse].[dbo].[tmp3_dim_warehouse] (
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY Warehouse_id) + @MAXIMUM_Warehouse_Surrogate,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            1,
            NULL,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        FROM [DatawareHouse].[dbo].[tmp2_dim_warehouse] AS y
        WHERE EXISTS (
                SELECT 1 
                FROM [DatawareHouse].[dbo].[tmp1_dim_warehouse] AS x 
                WHERE x.Warehouse_id = y.Warehouse_id AND x.ManagerID <> y.ManagerID AND x.Currentflag = 1
            ) 
            OR y.Warehouse_id NOT IN (
                SELECT x.Warehouse_id 
                FROM [DatawareHouse].[dbo].[tmp1_dim_warehouse] AS x
            );
select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[tmp3_dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'insert'   , '[DatawareHouse].[dbo].[tmp3_dim_warehouse]' , @number_of_rows)
        INSERT INTO [DatawareHouse].[dbo].[tmp3_dim_warehouse] (
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            0,
            DATEADD(day, -1, GETDATE()),
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        FROM [DatawareHouse].[dbo].[tmp1_dim_warehouse] AS x
        WHERE x.Currentflag = 1 AND EXISTS (
            SELECT 1 
            FROM [DatawareHouse].[dbo].[tmp2_dim_warehouse] AS y 
            WHERE x.Warehouse_id = y.Warehouse_id AND x.ManagerID <> y.ManagerID
        );

select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[tmp3_dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'insert'   , '[DatawareHouse].[dbo].[tmp3_dim_warehouse]' , @number_of_rows)

        TRUNCATE TABLE [DatawareHouse].[dbo].[dim_warehouse];

        INSERT INTO [DatawareHouse].[dbo].[dim_warehouse] (
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        )
        SELECT 
            SurrogateWarehouseKey,
            Warehouse_id,
            WarehouseName,
            WarehouseDescription,
            ManagerID,
            Currentflag,
            EndDate,
            StartDate,
            LocationID,
            State,
            CityCode,
            CityName
        FROM [DatawareHouse].[dbo].[tmp3_dim_warehouse];

select @number_of_rows = count(*) from [DatawareHouse].[dbo].[dim_warehouse]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'Fill_dim_warehouse'  , GETDATE() , 'insert data to dim'   , '[DatawareHouse].[dbo].[dim_warehouse]' , @number_of_rows)
    END

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_warehouse'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;






GO
Create OR ALTER PROCEDURE Fill_dim_discountType
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_discountType'  , GETDATE() , 'start run procedure'   , ' ' , 0)
	IF (NOT (NOT EXISTS (SELECT 1 FROM dim_discountType) and EXISTS (SELECT 1 from tmp_dim_DiscountType)))
	begin
		
		truncate table  [DatawareHouse].[dbo].[tmp_dim_discountType];



		insert into [DatawareHouse].[dbo].[tmp_dim_discountType](
		[DiscountTypeId]
      ,[DiscountTypeDescription]
      ,[MinimumPurchase]
      ,[StartDate]
      ,[EndDate]
      ,[CategoryID]
      ,[CategoryName]
      ,[CategoryDescription])

		select [DiscountTypeId]
			,[DiscountTypeDescription]
			,[MinimumPurchase]
			,[StartDate]
			,[EndDate]
			,[CategoryID]
			,[CategoryName]
			,[CategoryDescription]
		from [DatawareHouse].[dbo].[dim_discountType]

		declare @number_of_rows int;
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp_dim_discountType]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_discountType'  , GETDATE() , 'inset dim data'   , '[DatawareHouse].[dbo].[tmp_dim_discountType]' , @number_of_rows)

		INSERT INTO [DataWarehouse].[dbo].[tmp_dim_discountType]
        (DiscountTypeId, DiscountTypeDescription, MinimumPurchase, StartDate, EndDate, CategoryID, CategoryName, CategoryDescription)
		SELECT 
			dis.discount_code_type_id, dis.description, dis.minimum_purchase, dis.start_date, dis.end_date, 
			dis.category_id, cat.category_name, cat.category_description
		FROM [SA].[dbo].[SA_Discount_code_type] AS dis
		INNER JOIN [SA].[dbo].[SA_Category] AS cat ON dis.category_id = cat.category_id
		Where dis.discount_code_type_id not in (select [DiscountTypeId] from [DatawareHouse].[dbo].[dim_discountType])

select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[tmp_dim_discountType]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_discountType'  , GETDATE() , 'inset sa new data'   , '[DatawareHouse].[dbo].[tmp_dim_discountType]' , @number_of_rows)

		
		truncate table  [DatawareHouse].[dbo].[dim_discountType]; 

		insert into [DatawareHouse].[dbo].[dim_discountType](
		[DiscountTypeId]
      ,[DiscountTypeDescription]
      ,[MinimumPurchase]
      ,[StartDate]
      ,[EndDate]
      ,[CategoryID]
      ,[CategoryName]
      ,[CategoryDescription])

		select [DiscountTypeId]
			,[DiscountTypeDescription]
			,[MinimumPurchase]
			,[StartDate]
			,[EndDate]
			,[CategoryID]
			,[CategoryName]
			,[CategoryDescription]
		from [DatawareHouse].[dbo].[tmp_dim_discountType]

		select @number_of_rows = count(*) from[DatawareHouse].[dbo].[dim_discountType]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_discountType'  , GETDATE() , 'inset data to dim'   , '[DatawareHouse].[dbo].[dim_discountType]' , @number_of_rows)
	end;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_dim_discountType'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE fill_dim_company
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_company'  , GETDATE() , 'start run procedure'   , ' ' , 0)
	IF (NOT (NOT EXISTS (SELECT 1 FROM dim_company) and EXISTS (SELECT 1 from tmp_dim_Company)))    BEGIN
        TRUNCATE TABLE tmp_dim_Company;
        INSERT INTO [DatawareHouse].[dbo].[tmp_dim_company]
            ([Company_id]
            ,[Name]
            ,[Registration_Code]
            ,[PhoneNumber]
            ,[Email]
            ,[Address]
            ,[LocationID]
            ,[State]
            ,[CityName]
            ,[CityCode])
        SELECT
            [Company_id]
            ,[Name]
            ,[Registration_Code]
            ,[PhoneNumber]
            ,[Email]
            ,[Address]
            ,[LocationID]
            ,[State]
            ,[CityName]
            ,[CityCode]
        FROM [DatawareHouse].[dbo].[dim_company];
declare @number_of_rows int;
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp_dim_company]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_company'  , GETDATE() , ' insert dim data'   , '[DatawareHouse].[dbo].[tmp_dim_company]' , @number_of_rows)

        INSERT INTO [DatawareHouse].[dbo].[tmp_dim_company]
            ([Company_id]
            ,[Name]
            ,[Registration_Code]
            ,[PhoneNumber]
            ,[Email]
            ,[Address]
            ,[LocationID]
            ,[State]
            ,[CityName]
            ,[CityCode])
        SELECT
            com.company_id
            ,com.name
            ,com.registration_code
            ,com.phone_number
            ,com.email
            ,com.address
            ,com.location_id
            ,loc.state
            ,city.city_name
            ,city.city_code
        FROM [SA].[dbo].[SA_Company] AS com
        INNER JOIN [SA].[dbo].[SA_Location] AS loc ON com.location_id = loc.location_id
        INNER JOIN [SA].[dbo].[SA_City] AS city ON loc.city_code = city.city_code
        WHERE com.company_id NOT IN (
            SELECT [company_id]
            FROM [DatawareHouse].[dbo].[tmp_dim_company]
        );

select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[tmp_dim_company]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_company'  , GETDATE() , ' insert sa new data'   , '[DatawareHouse].[dbo].[tmp_dim_company]' , @number_of_rows)


        TRUNCATE TABLE dim_Company;
        INSERT INTO [DatawareHouse].[dbo].[dim_company]
            ([Company_id]
            ,[Name]
            ,[Registration_Code]
            ,[PhoneNumber]
            ,[Email]
            ,[Address]
            ,[LocationID]
            ,[State]
            ,[CityName]
            ,[CityCode])
        SELECT
            [Company_id]
            ,[Name]
            ,[Registration_Code]
            ,[PhoneNumber]
            ,[Email]
            ,[Address]
            ,[LocationID]
            ,[State]
            ,[CityName]
            ,[CityCode]
        FROM [DatawareHouse].[dbo].[tmp_dim_company];
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[dim_company]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_company'  , GETDATE() , ' insert data to dim'   , '[DatawareHouse].[dbo].[dim_company]' , @number_of_rows)

    END;

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_company'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE fill_dim_Location
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_Location'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    IF (NOT (NOT EXISTS (SELECT 1 FROM dim_location) and EXISTS (SELECT 1 from tmp_dim_Location)))
    BEGIN
        TRUNCATE TABLE tmp_dim_Location;
        INSERT INTO [DatawareHouse].[dbo].[tmp_dim_Location]
            ([LocationID]
            ,[State]
            ,[CityCode]
            ,[CityName])
        SELECT
            [LocationID]
            ,[State]
            ,[CityCode]
            ,[CityName]
        FROM [DatawareHouse].[dbo].[dim_Location];

declare @number_of_rows int;
select @number_of_rows = count(*) from [DatawareHouse].[dbo].[tmp_dim_Location]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_Location'  , GETDATE() , 'insert dim data'   , '[DatawareHouse].[dbo].[tmp_dim_Location]' , @number_of_rows)

        INSERT INTO [DatawareHouse].[dbo].[tmp_dim_Location]
            ([LocationID]
            ,[State]
            ,[CityCode]
            ,[CityName])
        SELECT
            loc.location_id
            ,loc.state
            ,loc.city_code
            ,city.city_name
        FROM [SA].[dbo].[SA_Location] AS loc
        INNER JOIN [SA].[dbo].[SA_City] AS city ON loc.city_code = city.city_code
        WHERE loc.location_id NOT IN (
            SELECT [LocationID]
            FROM [DatawareHouse].[dbo].[tmp_dim_Location]
        );
select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[tmp_dim_Location]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_Location'  , GETDATE() , 'insert sa new data'   , '[DatawareHouse].[dbo].[tmp_dim_Location]' , @number_of_rows)

        TRUNCATE TABLE dim_Location;
        INSERT INTO [DatawareHouse].[dbo].[dim_Location]
            ([LocationID]
            ,[State]
            ,[CityCode]
            ,[CityName])
        SELECT
            [LocationID]
            ,[State]
            ,[CityCode]
            ,[CityName]
        FROM [DatawareHouse].[dbo].[tmp_dim_Location];

		select @number_of_rows = count(*) - @number_of_rows from [DatawareHouse].[dbo].[dim_Location]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_Location'  , GETDATE() , 'insert data to dim'   , '[DatawareHouse].[dbo].[dim_Location]' , @number_of_rows)

    END;

	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_Location'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE fill_dim_position
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_position'  , GETDATE() , 'start run procedure'   , ' ' , 0)

    IF (NOT (NOT EXISTS (SELECT 1 FROM dim_position) and EXISTS (SELECT 1 from tmp_dim_Position)))
    BEGIN
        
        TRUNCATE TABLE tmp_dim_Position;
    
        INSERT INTO tmp_dim_Position
        (
            PositionId,
            PositionDescription,
            HoursOfWorkLeave,
            MaximumHoursOfOverTime,
            HoursOfWork,
            DaysOfWorkLeave
        )
        SELECT 
            pos.position_id,
            pos.description,
            pos.hours_of_work_leave,
            pos.maximum_hours_of_over_time,
            pos.hours_of_work,
            pos.days_of_work_leave
        FROM SA.dbo.SA_Position AS pos;

declare @number_of_rows int;
select @number_of_rows = count(*) from tmp_dim_Position
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_position'  , GETDATE() , 'insert dim data'   , 'tmp_dim_Position' , @number_of_rows)

        INSERT INTO tmp_dim_Position
        (
            PositionId,
            PositionDescription,
            HoursOfWorkLeave,
            MaximumHoursOfOverTime,
            HoursOfWork,
            DaysOfWorkLeave
        )
        SELECT 
            PositionId,
            PositionDescription,
            HoursOfWorkLeave,
            MaximumHoursOfOverTime,
            HoursOfWork,
            DaysOfWorkLeave
        FROM dim_Position
        WHERE PositionId NOT IN (SELECT PositionId FROM tmp_dim_Position);

select @number_of_rows = count(*) - @number_of_rows from tmp_dim_Position
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_position'  , GETDATE() , 'insert sa new data'   , 'tmp_dim_Position' , @number_of_rows)

        TRUNCATE TABLE dim_Position;

        INSERT INTO dim_position
        (
            PositionId,
            PositionDescription,
            HoursOfWorkLeave,
            MaximumHoursOfOverTime,
            HoursOfWork,
            DaysOfWorkLeave
        )
        SELECT 
            PositionId,
            PositionDescription,
            HoursOfWorkLeave,
            MaximumHoursOfOverTime,
            HoursOfWork,
            DaysOfWorkLeave
        FROM tmp_dim_Position;

select @number_of_rows = count(*) from dim_position
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_position'  , GETDATE() , 'insert data to dim'   , 'dim_position' , @number_of_rows)
    END;

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_position'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

GO
 create or alter PROCEDURE fill_dim_product
 AS
 BEGIN
 insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_product'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	IF (NOT (NOT EXISTS (SELECT 1 FROM dim_product) and EXISTS (SELECT 1 from DatawareHouse.dbo.tmp3_dim_product)))
	begin

		 TRUNCATE table DatawareHouse.dbo.tmp1_dim_product;
		 TRUNCATE table DatawareHouse.dbo.tmp2_dim_product;
		 TRUNCATE table DatawareHouse.dbo.tmp3_dim_product;

		 --- temp1 - dim
		 insert into DatawareHouse.[dbo].tmp1_dim_product
			 ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits)
		 select 
			 SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits
		 from [DataWarehouse].[dbo].[dim_product]

declare @number_of_rows int;
select @number_of_rows = count(*) from  DatawareHouse.[dbo].tmp1_dim_product
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_product'  , GETDATE() , 'insert dim data'   , ' DatawareHouse.[dbo].tmp1_dim_product' , @number_of_rows)

		 --temp2  SA
		 insert into DatawareHouse.dbo.tmp2_dim_product
			 ( Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice)
		 select 
			 product_id, pr.name, product_description, cat.category_id, category_name
			 , category_description, com.company_id, com.name, price, cost
		 from [SA].[dbo].[SA_Product] as pr 
			 INNER JOIN [SA].[dbo].[SA_Company] as com on pr.[Company_ID]=com.[company_id]
			 inner JOIN [SA].[dbo].[SA_Category] as cat on pr.[category_id]= cat.[category_id]

select @number_of_rows = count(*) from  DatawareHouse.[dbo].tmp2_dim_product
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_product'  , GETDATE() , 'insert sa data'   , ' DatawareHouse.[dbo].tmp2_dim_product' , @number_of_rows)
  
	  -----------------------------------------------------------------------------------------------
select @number_of_rows = count(*) from  DatawareHouse.dbo.tmp3_dim_product

		insert into DatawareHouse.dbo.tmp3_dim_product
			 ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits)
		 select 
			 tm1.SurrogateKey, tm1.Product_id, tm1.ProductName, tm1.ProductDescription, tm1.CategoryId, tm1.CategoryName
			 , tm1.CategoryDescription, tm1.CompanyID, tm1.CompanyName, 
			 tm1.ProductionPrice,tm1.CostPrice,tm1.StartDate,tm1.EndDate,tm1.Currentflag,tm1.bits
		 from DatawareHouse.dbo.tmp1_dim_product  as tm1 where  tm1.Currentflag=0 or
		 tm1.Product_id not in (select t1.Product_id
		 from DatawareHouse.dbo.tmp1_dim_product as t1 inner join DatawareHouse.dbo.tmp2_dim_product as t2 on (t1.Currentflag = 1 and  t1.Product_id=t2.Product_id and (t1.CostPrice <> t2.CostPrice or t1.ProductionPrice <> t2.ProductionPrice)))
		 

		 insert into DatawareHouse.dbo.tmp3_dim_product
			 ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits)
		 select 
			 tm1.SurrogateKey, tm1.Product_id, tm1.ProductName, tm1.ProductDescription, tm1.CategoryId, tm1.CategoryName
			 , tm1.CategoryDescription, tm1.CompanyID, tm1.CompanyName, 
			 tm1.ProductionPrice,tm1.CostPrice,tm1.StartDate,getdate(),0,tm1.bits
		 from DatawareHouse.dbo.tmp1_dim_product  as tm1 where tm1.Product_id in (select t1.Product_id
		 from DatawareHouse.dbo.tmp1_dim_product as t1 inner join DatawareHouse.dbo.tmp2_dim_product as t2 on (t1.Currentflag=1 and t1.Product_id=t2.Product_id and (t1.CostPrice <> t2.CostPrice or t1.ProductionPrice <> t2.ProductionPrice)))
		 and tm1.Currentflag=1

		 declare @m int;
		 set @m = 0;
		 select @m = max (SurrogateKey) from DatawareHouse.dbo.tmp1_dim_product
		 if @m is null 
		 begin
			set @m = 0
		 end

		 insert into DatawareHouse.dbo.tmp3_dim_product
			 ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits)
		 select 
			 @m + row_number() over (order by t2.Product_id), t2.Product_id, t2.ProductName, t2.ProductDescription, t2.CategoryId, t2.CategoryName
			 , t2.CategoryDescription, t2.CompanyID, t2.CompanyName, 
			 t2.ProductionPrice,t2.CostPrice,getdate(),null,1,'00'
		 from DatawareHouse.dbo.tmp2_dim_product  as t2 where t2.Product_id not in (select Product_id from DatawareHouse.dbo.tmp1_dim_product)

		 select @m = max (SurrogateKey) from DatawareHouse.dbo.tmp3_dim_product
		 if @m is null 
		 begin
		 set @m = 0
		 end

		insert into DatawareHouse.dbo.tmp3_dim_product
		   ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
		   , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
		   , EndDate, Currentflag ,bits)
		 select 
			 @m + row_number() over (order by tm2.Product_id), tm2.Product_id, tm2.ProductName, tm2.ProductDescription, tm2.CategoryId, tm2.CategoryName
			 , tm2.CategoryDescription, tm2.CompanyID, tm2.CompanyName, 
			 tm2.ProductionPrice,tm2.CostPrice,getdate(),null,1, '11'
		 from DatawareHouse.dbo.tmp2_dim_product  as tm2 where tm2.Product_id in (select t1.Product_id
		 from DatawareHouse.dbo.tmp1_dim_product as t1 inner join DatawareHouse.dbo.tmp2_dim_product as t2 on 
		 (t1.Currentflag = 1 and t1.Product_id=t2.Product_id and (t1.CostPrice <> t2.CostPrice and t1.ProductionPrice <> t2.ProductionPrice)))
		 
		 select @m = max (SurrogateKey) from DatawareHouse.dbo.tmp3_dim_product
		 if @m is null 
		 begin
		 set @m = 0
		 end

		insert into DatawareHouse.dbo.tmp3_dim_product
		   ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
		   , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
		   , EndDate, Currentflag ,bits)
		 select 
			 @m + row_number() over (order by tm2.Product_id), tm2.Product_id, tm2.ProductName, tm2.ProductDescription, tm2.CategoryId, tm2.CategoryName
			 , tm2.CategoryDescription, tm2.CompanyID, tm2.CompanyName, 
			 tm2.ProductionPrice,tm2.CostPrice,getdate(),null,1, '10'
		 from DatawareHouse.dbo.tmp2_dim_product  as tm2 where tm2.Product_id in (select t1.Product_id
		 from DatawareHouse.dbo.tmp1_dim_product as t1 inner join DatawareHouse.dbo.tmp2_dim_product as t2 on 
		 (t1.Currentflag = 1 and t1.Product_id=t2.Product_id and (t1.CostPrice <> t2.CostPrice and t1.ProductionPrice = t2.ProductionPrice)))

		 select @m = max (SurrogateKey) from DatawareHouse.dbo.tmp3_dim_product
		 if @m is null 
		 begin
		 set @m = 0
		 end

		insert into DatawareHouse.dbo.tmp3_dim_product
		   ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
		   , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
		   , EndDate, Currentflag ,bits)
		 select 
			 @m + row_number() over (order by tm2.Product_id), tm2.Product_id, tm2.ProductName, tm2.ProductDescription, tm2.CategoryId, tm2.CategoryName
			 , tm2.CategoryDescription, tm2.CompanyID, tm2.CompanyName, 
			 tm2.ProductionPrice,tm2.CostPrice,getdate(),null,1, '01'
		 from DatawareHouse.dbo.tmp2_dim_product  as tm2 where tm2.Product_id in (select t1.Product_id
		 from DatawareHouse.dbo.tmp1_dim_product as t1 inner join DatawareHouse.dbo.tmp2_dim_product as t2 on 
		 (t1.Currentflag = 1 and t1.Product_id=t2.Product_id and (t1.CostPrice = t2.CostPrice and t1.ProductionPrice <> t2.ProductionPrice)))

select @number_of_rows = count(*) - @number_of_rows from  DatawareHouse.dbo.tmp3_dim_product
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
('fill_dim_product'  , GETDATE() , 'insert' , ' DatawareHouse.dbo.tmp3_dim_product' , @number_of_rows)

		 truncate table datawarehouse.dbo.dim_product

		 insert into  [DataWarehouse].[dbo].[dim_product]
			 ( SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits)
		 select 
			 SurrogateKey, Product_id, ProductName, ProductDescription, CategoryId, CategoryName
			 , CategoryDescription, CompanyID, CompanyName, ProductionPrice, CostPrice, StartDate
			 , EndDate, Currentflag ,bits
		 from DatawareHouse.dbo.tmp3_dim_product

select @number_of_rows = count(*)  from  [DataWarehouse].[dbo].[dim_product]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
('fill_dim_product'  , GETDATE() , 'insert data to dim' , ' [DataWarehouse].[dbo].[dim_product]' , @number_of_rows)

	end

	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_product'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

GO
CREATE OR ALTER PROCEDURE fill_dim_customer
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    IF NOT (NOT EXISTS (SELECT 1 FROM DatawareHouse.[dbo].[dim_Customer])
            AND EXISTS (SELECT 1 FROM DatawareHouse.[dbo].[tmp1_dim_customer]))
    BEGIN
        TRUNCATE TABLE DatawareHouse.[dbo].[tmp1_dim_customer];
        TRUNCATE TABLE DatawareHouse.[dbo].[tmp2_dim_customer];
        TRUNCATE TABLE DatawareHouse.[dbo].[tmp3_dim_customer];

        INSERT INTO DatawareHouse.[dbo].[tmp1_dim_customer] (
            Customer_id,
            Name,
            LastName,
            NationalID,
            Gender,
            Phone,
            Email,
            CurrentAddress,
            OriginalAddress,
            EffectiveDate
        )
        SELECT
            Customer_id,
            Name,
            LastName,
            NationalID,
            Gender,
            Phone,
            Email,
            CurrentAddress,
            OriginalAddress,
            EffectiveDate
        FROM DatawareHouse.[dbo].[dim_Customer];

declare @number_of_rows int;
select @number_of_rows = count(*) from DatawareHouse.[dbo].[tmp1_dim_customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'insert dim data'   , 'DatawareHouse.[dbo].[tmp1_dim_customer]' , @number_of_rows)

        INSERT INTO [DataWarehouse].[dbo].[tmp2_dim_customer] (
            Customer_id, 
            Name, 
            LastName, 
            NationalId, 
            Gender, 
            Phone, 
            Email, 
            Address
        )
        SELECT 
            cus.Customer_id, 
            cus.Name, 
            cus.Last_Name, 
            cus.National_ID, 
            cus.Gender, 
            cus.Phone_number, 
            cus.Email, 
            cus.Address
        FROM [SA].[dbo].[SA_Customer] AS cus;

select @number_of_rows = count(*) from DatawareHouse.[dbo].[tmp2_dim_customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'insert sa data'   , 'DatawareHouse.[dbo].[tmp2_dim_customer]' , @number_of_rows)

select @number_of_rows = count(*) from DatawareHouse.[dbo].[tmp3_dim_customer]

        INSERT INTO [DatawareHouse].[dbo].[tmp3_dim_customer] (
            Customer_id,
            Name,
            LastName,
            NationalID,
            Gender,
            Phone,
            Email,
            CurrentAddress,
            OriginalAddress,
            EffectiveDate
        )
        SELECT
            ISNULL(y.Customer_id, x.Customer_id),
            ISNULL(y.Name, x.Name),
            ISNULL(y.LastName, x.LastName),
            ISNULL(y.NationalID, x.NationalID),
            ISNULL(y.Gender, x.Gender),
            ISNULL(y.Phone, x.Phone),
            ISNULL(y.Email, x.Email),
            CASE 
                WHEN y.Address IS NOT NULL AND y.Address <> x.CurrentAddress THEN y.Address
                ELSE ISNULL(x.CurrentAddress,y.Address)
            END AS CurrentAddress,
            CASE 
                WHEN y.Address IS NOT NULL AND y.Address <> x.CurrentAddress THEN x.CurrentAddress
                ELSE x.OriginalAddress
            END AS OriginalAddress,
            CASE 
                WHEN y.Address IS NOT NULL AND y.Address <> x.CurrentAddress THEN DATEADD(day, -1, GETDATE())
                ELSE ISNULL(x.EffectiveDate,DATEADD(day, -1, GETDATE()))
            END AS EffectiveDate
        FROM DatawareHouse.[dbo].[tmp1_dim_customer] AS x
        FULL OUTER JOIN DatawareHouse.[dbo].[tmp2_dim_customer] AS y 
        ON x.Customer_id = y.Customer_id;

select @number_of_rows = count(*) - @number_of_rows  from DatawareHouse.[dbo].[tmp3_dim_customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'insert'   , 'DatawareHouse.[dbo].[tmp3_dim_customer]' , @number_of_rows)
        TRUNCATE TABLE DatawareHouse.[dbo].[dim_Customer];

        INSERT INTO DatawareHouse.[dbo].[dim_Customer] (
            Customer_id,
            Name,
            LastName,
            NationalID,
            Gender,
            Phone,
            Email,
            CurrentAddress,
            OriginalAddress,
            EffectiveDate
        )
        SELECT
            Customer_id,
            Name,
            LastName,
            NationalID,
            Gender,
            Phone,
            Email,
            CurrentAddress,
            OriginalAddress,
            EffectiveDate
        FROM DatawareHouse.[dbo].[tmp3_dim_customer];

select @number_of_rows = count(*) - @number_of_rows  from DatawareHouse.[dbo].[dim_Customer]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'insert data to dim'   , 'DatawareHouse.[dbo].[dim_Customer]' , @number_of_rows)

    END

	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_customer'  , GETDATE() , 'end run procedure'   , ' ' , 0)

END;

go
create or alter procedure fill_dim_employee
AS
begin
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_employee'  , GETDATE() , 'start run procedure'   , ' ' , 0)
    IF (EXISTS (SELECT 1 FROM [DatawareHouse].[dbo].[dim_employee]))
    BEGIN
        TRUNCATE TABLE [DatawareHouse].[dbo].[temp_dim_employee];
        TRUNCATE TABLE [DatawareHouse].[dbo].[temp_sa_employee];
        TRUNCATE TABLE [DatawareHouse].[dbo].[temp_employee];


--load sa 
        INSERT INTO [DataWarehouse].[dbo].[temp_sa_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            emp.employee_id, emp.name, emp.last_name, emp.gender, emp.phone_number, emp.email, 
            emp.hire_date, emp.warehouse_id, null, null, 
            emp.position_id, pos.description, null, null, 
           null, emp.contract_type_id, con.description
        FROM [SA].[dbo].[SA_Employee] AS emp
        INNER JOIN [SA].[dbo].[SA_Position] AS pos ON emp.position_id = pos.position_id
        INNER JOIN [SA].[dbo].[SA_Contract_type] AS con ON emp.contract_type_id = con.contract_type_id;

declare @number_of_rows int;
select @number_of_rows = count(*) from  [DataWarehouse].[dbo].[temp_sa_employee]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_employee'  , GETDATE() , 'insert sa data'   , ' [DataWarehouse].[dbo].[temp_sa_employee]' , @number_of_rows)

    --load dim
        INSERT INTO [DataWarehouse].[dbo].[temp_dim_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription
        FROM [DataWarehouse].[dbo].[dim_employee]

select @number_of_rows = count(*) from  [DataWarehouse].[dbo].[temp_dim_employee]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'fill_dim_employee'  , GETDATE() , 'insert dim data'   , '[DataWarehouse].[dbo].[temp_dim_employee]' , @number_of_rows)

select @number_of_rows = count(*) from  [DataWarehouse].[dbo].[temp_employee]

    --insert data that exist in sa_employee and dim_employee but warehouse and position is difrent(handle scd3)

        INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            dim.Employee_id, dim.Name, dim.LastName, dim.Gender, sa.Phone, sa.Email, dim.HireDate, sa.CurrentWarehouseID, 
            dim.CurrentWarehouseID, CONVERT(DATE, GETDATE()), sa.CurrentPositionID, sa.CurrentPositionDesc, 
            dim.CurrentPositionID, dim.CurrentPositionDesc,  CONVERT(DATE, GETDATE()), SA.ContractTypeID, 
            SA.ContractTypeDescription
        FROM [DataWarehouse].[dbo].[temp_dim_employee] as dim inner join 
        [DatawareHouse].[dbo].[temp_sa_employee] as sa on (sa.Employee_id = dim.employee_id 
        and dim.CurrentWarehouseID <> sa.CurrentWarehouseID and dim.CurrentPositionID <> sa.CurrentPositionID)


    --insert data that exist in sa_employee and dim_employee but warehouse  difrent(handle scd3) and position is equal
       INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            dim.Employee_id, dim.Name, dim.LastName, dim.Gender, sa.Phone, sa.Email, dim.HireDate, sa.CurrentWarehouseID, 
            dim.CurrentWarehouseID, CONVERT(DATE, GETDATE()), dim.CurrentPositionID, dim.CurrentPositionDesc, 
            dim.OriginalPositionID, dim.OriginalPositionDesc,  dim.EffectiveDateP, SA.ContractTypeID, 
            SA.ContractTypeDescription
        FROM [DataWarehouse].[dbo].[temp_dim_employee] as dim inner join 
        [DatawareHouse].[dbo].[temp_sa_employee] as sa on (sa.Employee_id = dim.employee_id 
        and dim.CurrentWarehouseID <> sa.CurrentWarehouseID and dim.CurrentPositionID = sa.CurrentPositionID)


    --insert data that exist in sa_employee and dim_employee but position  difrent(handle scd3) and warehouse is equal
        INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            dim.Employee_id, dim.Name, dim.LastName, dim.Gender, sa.Phone, sa.Email, dim.HireDate, dim.CurrentWarehouseID, 
            dim.OriginalWarehouseID, dim.EffectiveDateP, sa.CurrentPositionID, sa.CurrentPositionDesc, 
            dim.CurrentPositionID, dim.CurrentPositionDesc,  CONVERT(DATE, GETDATE()), dim.ContractTypeID, 
            dim.ContractTypeDescription
        FROM [DataWarehouse].[dbo].[temp_dim_employee] as dim inner join 
        [DatawareHouse].[dbo].[temp_sa_employee] as sa on (sa.Employee_id = dim.employee_id 
        and dim.CurrentPositionID <> sa.CurrentPositionID and dim.CurrentWarehouseID = sa.CurrentWarehouseID )

		--insert data that exist in sa_employee and dim_employee and position and warehouse is equal
        INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            dim.Employee_id, dim.Name, dim.LastName, dim.Gender, sa.Phone, sa.Email, dim.HireDate, dim.CurrentWarehouseID, 
            dim.OriginalWarehouseID, dim.EffectiveDateP, dim.CurrentPositionID, dim.CurrentPositionDesc, 
            dim.OriginalPositionID, dim.OriginalPositionDesc, dim.EffectiveDateW, dim.ContractTypeID, 
            dim.ContractTypeDescription
        FROM [DataWarehouse].[dbo].[temp_dim_employee] as dim inner join 
        [DatawareHouse].[dbo].[temp_sa_employee] as sa on (sa.Employee_id = dim.employee_id 
        and dim.CurrentPositionID = sa.CurrentPositionID and dim.CurrentWarehouseID = sa.CurrentWarehouseID )


    --insert data that exist in dim and not exist in sa 
        INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            dim.Employee_id, dim.Name, dim.LastName, dim.Gender, dim.Phone, dim.Email, dim.HireDate, dim.CurrentWarehouseID, 
            dim.OriginalWarehouseID, dim.EffectiveDateW, dim.CurrentPositionID, dim.CurrentPositionDesc, 
            dim.OriginalPositionID, dim.OriginalPositionDesc, dim.EffectiveDateP, dim.ContractTypeID, 
            dim.ContractTypeDescription
        FROM [DataWarehouse].[dbo].[temp_dim_employee] as dim 
        where dim.Employee_id not in (select sa.Employee_id
            from [DatawareHouse].[dbo].[temp_sa_employee] as sa 
        )



    --insert data that exist in sa and not exist in dim 

        INSERT INTO [DataWarehouse].[dbo].[temp_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        SELECT 
            sa.Employee_id, sa.Name, sa.LastName, sa.Gender, sa.Phone, sa.Email, sa.HireDate, sa.CurrentWarehouseID, 
            sa.OriginalWarehouseID, sa.EffectiveDateW, sa.CurrentPositionID, sa.CurrentPositionDesc, 
            sa.OriginalPositionID, sa.OriginalPositionDesc, sa.EffectiveDateP, sa.ContractTypeID, 
            sa.ContractTypeDescription
        FROM [DatawareHouse].[dbo].[temp_sa_employee] AS sa
        where sa.Employee_id not in ( select dim.Employee_id
            from [DatawareHouse].[dbo].[temp_dim_employee] as dim)

select @number_of_rows = count(*) - @number_of_rows from  [DataWarehouse].[dbo].[temp_employee]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'fill_dim_employee'  , GETDATE() , 'insert  '   , '[DataWarehouse].[dbo].[temp_dim_employee]' , @number_of_rows)
    --insert whole data in dimention 
        TRUNCATE table [DatawareHouse].[dbo].[dim_employee]

        INSERT INTO [DataWarehouse].[dbo].[dim_employee]
            (Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription)
        select 
            Employee_id, Name, LastName, Gender, Phone, Email, HireDate, CurrentWarehouseID, 
            OriginalWarehouseID, EffectiveDateW, CurrentPositionID, CurrentPositionDesc, 
            OriginalPositionID, OriginalPositionDesc, EffectiveDateP, ContractTypeID, 
            ContractTypeDescription
        from [DataWarehouse].[dbo].[temp_employee] 
select @number_of_rows = count(*) from   [DatawareHouse].[dbo].[dim_employee]
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'fill_dim_employee'  , GETDATE() , 'insert data to dim '   , ' [DatawareHouse].[dbo].[dim_employee]' , @number_of_rows)

	end

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'fill_dim_employee'  , GETDATE() , 'end run procedure'   , ' ' , 0)
end
