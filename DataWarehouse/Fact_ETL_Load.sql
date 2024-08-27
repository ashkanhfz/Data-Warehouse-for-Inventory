use DatawareHouse
GO
CREATE OR ALTER PROCEDURE Fill_trn_fact_inventory
AS 
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_trn_fact_inventory'  , GETDATE() , 'start run procedure'   , ' ' , 0)
	if  exists (select 1 from DatawareHouse.dbo.trn_fact_inventory )
	begin 


    DECLARE @end_date DATETIME;
    DECLARE @current_day DATETIME;
	declare @number_of_rows int;

   SELECT @current_day = max([DateID]) FROM DatawareHouse.dbo.trn_fact_inventory
   SET @current_day = DATEADD(DAY, 1, @current_day);
   


    SELECT @end_date = 
    CASE 
        WHEN (SELECT max([time]) FROM [SA].[dbo].[SA_Warehouse_Outlet]) > (SELECT max([time]) FROM [SA].[dbo].[SA_Warehouse_Entrance])
        THEN (SELECT max([time]) FROM [SA].[dbo].[SA_Warehouse_Outlet])
        ELSE (SELECT max([time]) FROM [SA].[dbo].[SA_Warehouse_Entrance])
    END;

	--SET @end_date = DATEADD(DAY, 1, @end_date);

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO [dbo].[tmp1_trn_fact_inventory] (
            warehouse_SurrogateKey,
            warehouse_id,
            DateID,
            CompanyId,
            Product_SurrogateKey,
            ProductID,
            EmployeeID,
            QuantityReceived,
            QuantityOut,
            cost,
			price
        )
        SELECT 
            dimW.SurrogateWarehouseKey,
            dimW.warehouse_id,
            wo.time,
            dimP.companyid,
            dimP.SurrogateKey,
            dimP.Product_id,
            wo.EmployeeID,
            0,
            wo.quantity,
            0,
			wo.quantity * dimP.costPrice
        FROM DatawareHouse.dbo.dim_warehouse dimW 
         inner JOIN SA.dbo.SA_Warehouse_Outlet wo ON  ( dimW.Warehouse_id = wo.warehouse_id and dimW.StartDate <= wo.time and wo.time <= isnull(dimW.EndDate, DATEADD(YEAR, 100, getdate())))
         inner JOIN DatawareHouse.dbo.dim_Product dimP ON ( wo.product_id = dimP.Product_id and dimP.StartDate <= wo.time and wo.time <= isnull(dimP.EndDate, DATEADD(YEAR, 100, getdate())))
         WHERE wo.time = @current_day;

		INSERT INTO [dbo].[tmp1_trn_fact_inventory] (
            warehouse_SurrogateKey,
            warehouse_id,
            DateID,
            CompanyId,
            Product_SurrogateKey,
            ProductID,
            EmployeeID,
            QuantityReceived,
            QuantityOut,
            cost,
			price
        )
        SELECT 
            dimW.SurrogateWarehouseKey,
            dimW.warehouse_id,
            wo.time,
            dimP.companyid,
            dimP.SurrogateKey,
            dimP.Product_id,
            wo.EmployeeID,
            wo.quantity,
            0,
			wo.quantity * dimP.ProductionPrice,
			0
        FROM DatawareHouse.dbo.dim_warehouse dimW 
        inner JOIN SA.dbo.SA_Warehouse_Entrance wo ON ( dimW.Warehouse_id = wo.warehouse_id and dimW.StartDate <= wo.time and wo.time <= isnull(dimW.EndDate, DATEADD(YEAR, 100, getdate())))
         inner JOIN DatawareHouse.dbo.dim_Product dimP ON ( wo.product_id = dimP.Product_id and dimP.StartDate <= wo.time and wo.time <= isnull(dimP.EndDate, DATEADD(YEAR, 100, getdate())))
        WHERE wo.time = @current_day;

        INSERT INTO DatawareHouse.dbo.trn_fact_inventory (
            warehouse_SurrogateKey,
            warehouse_id,
            DateID,
            CompanyId,
            Product_SurrogateKey,
            ProductID,
            EmployeeID,
            QuantityReceived,
            QuantityOut,
            cost,
			price
        )
        SELECT 
            warehouse_SurrogateKey,
            warehouse_id,
            DateID,
            CompanyId,
            Product_SurrogateKey,
            ProductID,
            EmployeeID,
            QuantityReceived,
            QuantityOut,
			cost,
			price
            
        FROM DatawareHouse.dbo.tmp1_trn_fact_inventory;

        TRUNCATE TABLE DatawareHouse.dbo.tmp1_trn_fact_inventory;

        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;
	end;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'Fill_trn_fact_inventory'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


--------------------------------------------------------------

GO

CREATE OR ALTER PROCEDURE FILL_Periodic_Fact_inventory
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_Periodic_Fact_inventory'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	if (exists (select 1 from DatawareHouse.dbo.periodic_fact_inventory))
	begin
		TRUNCATE TABLE DatawareHouse.dbo.tmp_periodic_fact_inventory;
		
		truncate table tmp__cros_join_dimW_dimP;
		INSERT INTO tmp_cros_join_dimW_dimP(
			dimW_SurrogateWarehouseKey,
			dimW_warehouse_id,
			dimP_CompanyId,
			dimP_SurrogateKey,
			dimP_Product_id,
			dimP_CostPrice,
			dimP_ProductionPrice
		)
		SELECT
			dimW.SurrogateWarehouseKey,
			dimW.warehouse_id,
			dimP.CompanyId,
			dimP.SurrogateKey,
			dimP.Product_id,
			dimP.CostPrice,
			dimP.ProductionPrice
		FROM DatawareHouse.dbo.dim_warehouse dimW
		CROSS JOIN DatawareHouse.dbo.dim_Product dimP;

		DECLARE @end_date DATETIME;
		DECLARE @current_day DATETIME;

		SELECT @end_date = MAX(DateID) 
		FROM [DatawareHouse].dbo.trn_fact_inventory;
		

		SELECT @current_day = max([DateID]) FROM DatawareHouse.dbo.periodic_fact_inventory
		SET @current_day = DATEADD(DAY, 1, @current_day);
   


		WHILE @current_day <= @end_date
		BEGIN
			WITH PreviousDayInventory AS (
				SELECT
					ff.warehouse_id,
					ff.Productid,
					ISNULL(ff.DailyQuantityOnHand, 0) AS DailyQuantityOnHand,
					ISNULL(ff.DayWithoutReceived, 0) AS DayWithoutReceived,
					ISNULL(ff.DayWithoutOUT, 0) AS DayWithoutOUT
				FROM DatawareHouse.dbo.periodic_fact_inventory ff
				WHERE ff.DateID = DATEADD(DAY, -1, @current_day)
			),
			CurrentDayTransactions AS (
				SELECT
					tmp.dimW_SurrogateWarehouseKey AS SurrogateWarehouseKey,
					tmp.dimW_warehouse_id AS warehouse_id,
					tmp.dimP_CompanyId AS CompanyId,
					tmp.dimP_SurrogateKey AS SurrogateKey,
					tmp.dimP_Product_id AS Product_id,
					SUM(ISNULL(factI.QuantityReceived, 0)) AS DailyQuantityReceived,
					SUM(ISNULL(factI.QuantityOut, 0)) AS DailyQuantityOut,
					SUM(ISNULL(factI.QuantityReceived, 0)) * tmp.dimP_CostPrice AS totalcost,
					SUM(ISNULL(factI.QuantityOut, 0)) * tmp.dimP_ProductionPrice AS totalprice
				FROM tmp_cros_join_dimW_dimP tmp
				LEFT JOIN DatawareHouse.dbo.trn_fact_inventory factI 
					ON tmp.dimW_warehouse_id = factI.warehouse_id 
					AND tmp.dimP_Product_id = factI.ProductID
					AND factI.DateID = @current_day
				GROUP BY 
					tmp.dimW_SurrogateWarehouseKey,
					tmp.dimW_warehouse_id,
					tmp.dimP_CompanyId,
					tmp.dimP_SurrogateKey,
					tmp.dimP_Product_id,
					tmp.dimP_CostPrice,
					tmp.dimP_ProductionPrice
			)
			INSERT INTO DatawareHouse.dbo.tmp_periodic_fact_inventory (
				warehouse_SurrogateKey,
				warehouse_id,
				DateID,
				CompanyId,
				Product_SurrogateKey,
				ProductID,
				DailyQuantityReceived,
				DailyQuantityOut,
				DailyQuantityOnHand,
				DayWithoutReceived,
				DayWithoutOUT,
				totalcost,
				totalprice
			)
			SELECT
				cdt.SurrogateWarehouseKey,
				cdt.warehouse_id,
				CONVERT(VARCHAR(10), @current_day, 120),
				cdt.CompanyId,
				cdt.SurrogateKey,
				cdt.Product_id,
				cdt.DailyQuantityReceived,
				cdt.DailyQuantityOut,
				ISNULL(cdt.DailyQuantityReceived - cdt.DailyQuantityOut + isnull(pdi.DailyQuantityOnHand,0), 0) AS DailyQuantityOnHand,
				ISNULL(
					CASE 
						WHEN isnull(cdt.DailyQuantityReceived,0) = 0 THEN pdi.DayWithoutReceived + 1 
						ELSE pdi.DayWithoutReceived
					END, 
					CASE 
						WHEN isnull(cdt.DailyQuantityReceived,0) = 0 THEN 1 
						ELSE 0
					END
				) AS DayWithoutReceived,
				ISNULL(
					CASE 
						WHEN isnull(cdt.DailyQuantityOut,0) = 0  THEN pdi.DayWithoutOUT + 1 
						ELSE pdi.DayWithoutOUT
					END, 
					CASE
					WHEN isnull(cdt.DailyQuantityOut,0) = 0  THEN 1 
					ELSE 0
					End
				) AS DayWithoutOUT,
				cdt.totalcost,
				cdt.totalprice
			FROM CurrentDayTransactions cdt
			LEFT JOIN PreviousDayInventory pdi
			ON cdt.warehouse_id = pdi.warehouse_id
			AND cdt.Product_id = pdi.Productid;

			INSERT INTO DatawareHouse.dbo.periodic_fact_inventory (
				warehouse_SurrogateKey,
				warehouse_id,
				DateID,
				CompanyId,
				Product_SurrogateKey,
				ProductID,
				DailyQuantityReceived,
				DailyQuantityOut,
				DailyQuantityOnHand,
				DayWithoutReceived,
				DayWithoutOUT,
				totalcost,
				totalprice
			)
			SELECT 
				warehouse_SurrogateKey,
				warehouse_id,
				DateID,
				CompanyId,
				Product_SurrogateKey,
				ProductID,
				DailyQuantityReceived,
				DailyQuantityOut,
				DailyQuantityOnHand,
				DayWithoutReceived,
				DayWithoutOUT,
				totalcost,
				totalprice
			FROM DatawareHouse.dbo.tmp_periodic_fact_inventory;

			TRUNCATE TABLE DatawareHouse.dbo.tmp_periodic_fact_inventory;
			SET @current_day = DATEADD(DAY, 1, @current_day);
		END;
	END;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_Periodic_Fact_inventory'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;



---------------------------------------

GO

CREATE OR ALTER PROCEDURE FILL_ACC_Fact_inventory
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_ACC_Fact_inventory'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	if (exists(select 1 from DatawareHouse.dbo.acc_fact_inventory))
	begin 
		TRUNCATE TABLE tmp_acc_fact_inventory;

		DECLARE @end_date DATe;
		DECLARE @current_day DATE;

		SELECT @current_day = MIN(CONVERT(DATE, DateID, 120)), @end_date = MAX(CONVERT(DATE, DateID, 120))
		FROM [DatawareHouse].dbo.periodic_fact_inventory;

		select @current_day = ISNULL((SELECT DATEADD(DAY, 1, [date]) 
                           FROM DataWarehouse.dbo.time_acc_fact_inventory) , 
                          @current_day);

		WHILE @current_day <= @end_date
		BEGIN
			TRUNCATE TABLE tmp1_acc_fact_inventory;

			INSERT INTO tmp1_acc_fact_inventory (
				warehouse_id,
				ProductID,
				CompanyId,
				-------------------------
				TotalQuantityReceived,
				TotalQuantityOut,
				TotalQuantityOnHand,
				NumberOfDayOutOfStock,
				NumberOfDaysNotReceived,
				NumberOfDaysNotOUT,
				TotalCost,
				TotalPrice
			)
			SELECT
				warehouse_id,
				ProductID,
				CompanyId,
				-------------------------
				TotalQuantityReceived,
				TotalQuantityOut,
				TotalQuantityOnHand,
				NumberOfDayOutOfStock,
				NumberOfDaysNotReceived,
				NumberOfDaysNotOUT,
				TotalCost,
				TotalPrice
			FROM tmp_acc_fact_inventory;

			TRUNCATE TABLE tmp2_acc_fact_inventory;

			INSERT INTO tmp2_acc_fact_inventory (
				warehouse_id,
				ProductID,
				CompanyId,
				-------------------------
				TotalQuantityReceived,
				TotalQuantityOut,
				TotalQuantityOnHand,
				NumberOfDayOutOfStock,
				NumberOfDaysNotReceived,
				NumberOfDaysNotOUT,
				TotalCost,
				TotalPrice
			)
			SELECT
				warehouse_id,
				ProductID,
				CompanyId,
				SUM(DailyQuantityReceived) AS TotalQuantityReceived,
				SUM(DailyQuantityOut) AS TotalQuantityOut,
				MAX(DailyQuantityOnHand) AS TotalQuantityOnHand,
				0 AS NumberOfDayOutOfStock,
				MAX(DayWithoutReceived) AS NumberOfDaysNotReceived,
				MAX(DayWithoutOUT) AS NumberOfDaysNotOUT,
				SUM(totalcost) AS TotalCost,
				SUM(totalprice) AS TotalPrice
			FROM DatawareHouse.dbo.periodic_fact_inventory
			WHERE DateID = CONVERT(VARCHAR(10), @current_day, 120)
			GROUP BY warehouse_id, ProductID, CompanyId;

			TRUNCATE TABLE tmp_acc_fact_inventory;

			INSERT INTO tmp_acc_fact_inventory (
				warehouse_id,
				ProductID,
				CompanyId,
				-------------------------
				TotalQuantityReceived,
				TotalQuantityOut,
				TotalQuantityOnHand,
				NumberOfDayOutOfStock,
				NumberOfDaysNotReceived,
				NumberOfDaysNotOUT,
				TotalCost,
				TotalPrice
			)
			SELECT
				tmp2.warehouse_id,
				tmp2.ProductID,
				tmp2.CompanyId,
				-------------------------
				ISNULL(tmp1.TotalQuantityReceived, 0) + tmp2.TotalQuantityReceived,
				ISNULL(tmp1.TotalQuantityOut, 0) + tmp2.TotalQuantityOut,
				ISNULL(tmp1.TotalQuantityReceived, 0) + tmp2.TotalQuantityReceived - (ISNULL(tmp1.TotalQuantityOut, 0) + tmp2.TotalQuantityOut),
				ISNULL(tmp1.NumberOfDayOutOfStock, 0) + CASE WHEN (ISNULL(tmp1.TotalQuantityReceived, 0) + tmp2.TotalQuantityReceived - (ISNULL(tmp1.TotalQuantityOut, 0) + tmp2.TotalQuantityOut)) <= 0 THEN 1 ELSE 0 END,
				ISNULL(tmp1.NumberOfDaysNotReceived, 0) + CASE WHEN tmp2.TotalQuantityReceived = 0 THEN 1 ELSE 0 END,
				ISNULL(tmp1.NumberOfDaysNotOUT, 0) + CASE WHEN tmp2.TotalQuantityOut = 0 THEN 1 ELSE 0 END,
				ISNULL(tmp1.TotalCost, 0) + tmp2.TotalCost,
				ISNULL(tmp1.TotalPrice, 0) + tmp2.TotalPrice
			FROM tmp1_acc_fact_inventory tmp1
			right JOIN tmp2_acc_fact_inventory tmp2
			ON tmp1.warehouse_id = tmp2.warehouse_id AND tmp1.ProductID = tmp2.ProductID AND tmp1.CompanyId = tmp2.CompanyId;

			SET @current_day = DATEADD(DAY, 1, @current_day);
		END;


		Truncate table acc_fact_inventory;
		INSERT INTO DatawareHouse.dbo.acc_fact_inventory (
			warehouse_id,
			ProductID,
			CompanyId,
			-------------------------
			TotalQuantityReceived,
			TotalQuantityOut,
			TotalQuantityOnHand,
			NumberOfDayOutOfStock,
			NumberOfDaysNotReceived,
			NumberOfDaysNotOUT,
			TotalCost,
			TotalPrice
		)
		SELECT
			warehouse_id,
			ProductID,
			CompanyId,
			-------------------------
			TotalQuantityReceived,
			TotalQuantityOut,
			TotalQuantityOnHand,
			NumberOfDayOutOfStock,
			NumberOfDaysNotReceived,
			NumberOfDaysNotOUT,
			TotalCost,
			TotalPrice
		FROM DatawareHouse.dbo.tmp_acc_fact_inventory;

		TRUNCATE TABLE DataWarehouse.dbo.time_acc_fact_inventory;

		INSERT INTO DataWarehouse.dbo.time_acc_fact_inventory ([date])
		VALUES (@end_date);
	end;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_ACC_Fact_inventory'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


go
CREATE OR ALTER PROCEDURE FILL_Factless_fact_HR
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_Factless_fact_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	if (not(not exists (select 1 from factless_HR)and exists (select 1 from tmp_factless_HR)))
	begin
		truncate table tmp_factless_HR;
		
		INSERT INTO tmp_factless_HR(
			EmployeeID1,EmployeeID2
		)
		select EmployeeID1,EmployeeID2
		from factless_HR

		INSERT INTO tmp_factless_HR(
			EmployeeID1,EmployeeID2
		)
		select representative_id,presented_id
		from sa.dbo.SA_Representative as s
		where not exists (select 1 from tmp_factless_HR as t where s.representative_id=t.EmployeeID1 and s.presented_id=t.EmployeeID2 )


		truncate table factless_HR;
		INSERT INTO factless_HR(EmployeeID1,EmployeeID2)
		select EmployeeID1,EmployeeID2
		from tmp_factless_HR
	end;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_Factless_fact_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


Go 
CREATE OR ALTER PROCEDURE FILL_FACT_INVENTORY
AS 
begin
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_FACT_INVENTORY'  , GETDATE() , 'start run procedure'   , ' ' , 0)
	declare @number_of_rows int;

	truncate table factless_fact_inventory;
	insert into factless_fact_inventory(WarehouseID,CustomerID)
	select warehouse_id,customer_id
	from SA.dbo.SA_Warehouse_Outlet
	group by warehouse_id,customer_id

	select @number_of_rows = count(*) from factless_fact_inventory
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_FACT_INVENTORY'  , GETDATE() , 'insert'   , 'factless_fact_inventory' , @number_of_rows)

	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_FACT_INVENTORY'  , GETDATE() , 'end run procedure'   , ' ' , 0)
end;


Go 
CREATE OR ALTER PROCEDURE FILL_FACTLESS_FACT_discount
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_FACTLESS_FACT_discount'  , GETDATE() , 'start run procedure'   , ' ' , 0)
	if (not(not exists (select 1 from factless_fact_discount)and exists (select 1 from tmp_factless_fact_discount)))
	begin
		truncate table tmp_factless_fact_discount;
		
		INSERT INTO tmp_factless_fact_discount(
			CustomerID,DiscountTypeId
		)
		select CustomerID,DiscountTypeId
		from factless_fact_discount

		INSERT INTO tmp_factless_fact_discount(
			CustomerID,DiscountTypeId
		)
		select customer_id,discount_code_type_id
		from SA.dbo.SA_Discount_code s
		where not exists (select 1 from tmp_factless_fact_discount as t where s.Customer_Id=t.CustomerID and s.discount_code_type_id=t.DiscountTypeID)


		truncate table factless_fact_discount;
		INSERT INTO factless_fact_discount(CustomerID,DiscountTypeId)
		select CustomerID,DiscountTypeId
		from tmp_factless_fact_discount
	end;
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_FACTLESS_FACT_discount'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;




GO 

CREATE OR ALTER PROCEDURE  FILL_trn_fact_discount
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_trn_fact_discount'  , GETDATE() , 'start run procedure'   , ' ' , 0)

    if (exists (select 1 from DatawareHouse.dbo.trn_fact_discount))
	truncate table tmp1_trn_fact_discount
    DECLARE @end_date DATETIME;
    DECLARE @current_day DATETIME;
	SELECT @current_day = max([DateID]) FROM DatawareHouse.dbo.trn_fact_inventory
    SET @current_day = DATEADD(DAY, 1, @current_day);

    SELECT @end_date = MAX([time]) 
    FROM [SA].[dbo].[SA_Warehouse_Outlet];

    WHILE @current_day <= @end_date
    BEGIN
        INSERT INTO [dbo].[tmp1_trn_fact_discount] (
            DateID,
            warehouse_SurrogateKey,
            warehouse_id,
            CustomerID,
            EmployeeID,
            DiscountTypeID,
            Product_SurrogateKey,
            ProductID,
            SalesAmount,
            DiscountPercentage,
            DiscountAmount,
            QuantitySoldOfProduct,
            TimeTaken
        )
        SELECT 
            wo.time,
            dimW.SurrogateWarehouseKey,
            dimW.warehouse_id,
            wo.customer_id,
            wo.EmployeeID,
            dimD.DiscountTypeID,
            dimP.SurrogateKey,
            dimP.Product_id,
            wo.quantity * dimP.CostPrice,
			(wo.quantity * dimP.CostPrice+99999) / 100000,
			((wo.quantity * dimP.CostPrice+99999) / 100000) * (wo.quantity * dimP.CostPrice)/100,
            wo.quantity,
            DATEDIFF(DAY,dimD.startDATE,wo.time)
        FROM DatawareHouse.dbo.dim_warehouse dimW 
        INNER JOIN SA.dbo.SA_Warehouse_Outlet wo 
            ON dimW.Warehouse_id = wo.warehouse_id 
            AND dimW.StartDate <= wo.time 
            AND wo.time <= ISNULL(dimW.EndDate, DATEADD(YEAR, 100, GETDATE()))
        INNER JOIN DatawareHouse.dbo.dim_Product dimP 
            ON wo.product_id = dimP.Product_id 
            AND dimP.StartDate <= wo.time 
            AND wo.time <= ISNULL(dimP.EndDate, DATEADD(YEAR, 100, GETDATE()))
        INNER JOIN SA.dbo.SA_Discount_code dd 
            ON wo.DiscountID = dd.discount_code_id
        INNER JOIN datawareHouse.dbo.dim_Discounttype dimD 
            ON dd.discount_code_type_id = dimD.DiscountTypeID
        WHERE wo.time = @current_day and wo.DiscountID is not null;

        INSERT INTO DatawareHouse.dbo.trn_fact_discount (
            DateID,
            warehouse_SurrogateKey,
            warehouse_id,
            CustomerID,
            EmployeeID,
            DiscountTypeID,
            Product_SurrogateKey,
            ProductID,
            SalesAmount,
            DiscountPercentage,
            DiscountAmount,
            QuantitySoldOfProduct,
            TimeTaken
        )
        SELECT 
            DateID,
            warehouse_SurrogateKey,
            warehouse_id,
            CustomerID,
            EmployeeID,
            DiscountTypeID,
            Product_SurrogateKey,
            ProductID,
            SalesAmount,
            DiscountPercentage,
            DiscountAmount,
            QuantitySoldOfProduct,
            TimeTaken
        FROM [dbo].[tmp1_trn_fact_discount];

        TRUNCATE TABLE [dbo].[tmp1_trn_fact_discount];

        SET @current_day = DATEADD(DAY, 1, @current_day);
    END;
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_trn_fact_discount'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

GO 
CREATE OR ALTER PROCEDURE FILL_Periodic_fact_discount
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_Periodic_fact_discount'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	if (exists (select 1 from DatawareHouse.dbo.Periodic_fact_discount))
	begin
		TRUNCATE TABLE DatawareHouse.dbo.tmp_periodic_fact_discount;
		
		truncate table tmp_cros_join_dimD_dimC;
		INSERT INTO tmp_cros_join_dimD_dimC(
			DimD_DiscountTypeId,
			dimC_CustomerId
		)
		SELECT
			dimD.DiscountTypeID,
			dimC.Customer_id
		FROM DatawareHouse.dbo.dim_customer DimC
		CROSS JOIN DatawareHouse.dbo.dim_discountType DimD;

		DECLARE @end_date DATE;
		DECLARE @current_day DATE;

		SELECT @end_date = MAX(DateID) 
		FROM [DatawareHouse].dbo.trn_fact_discount;
		

		SELECT @current_day = max([DateID]) FROM DatawareHouse.dbo.Periodic_fact_discount
		SET @current_day = DATEADD(DAY, 1, @current_day);
   

		WHILE @current_day <= @end_date
		BEGIN

			INSERT INTO DatawareHouse.dbo.tmp_Periodic_fact_discount(
				DiscountTypeID,
				DateID,
				customerID,
				-----------------------------
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT 
				TDC.DimD_DiscountTypeId,
				@current_day,
				TDC.dimC_CustomerId,
				-----------------------------
				ISNULL(SUM(PFD.SalesAmount), 0),
				CASE WHEN ISNULL(SUM(PFD.SalesAmount), 0) = 0 THEN 0
					 ELSE SUM(PFD.DiscountAmount) / COUNT(PFD.DiscountPercentage)
				END,
				ISNULL(SUM(PFD.DiscountAmount), 0),
				CASE WHEN ISNULL(SUM(PFD.DiscountAmount), 0) = 0 THEN 0
					 ELSE SUM(PFD.DiscountAmount) / COUNT(PFD.DiscountAmount)
				END,
				MAX(ISNULL(PFD.DiscountPercentage, 0)),
				CASE WHEN ISNULL(SUM(PFD.QuantitySoldOfProduct), 0) = 0 THEN 0
					 ELSE SUM(PFD.QuantitySoldOfProduct) / COUNT(PFD.QuantitySoldOfProduct)
				END,
				ISNULL(SUM(PFD.QuantitySoldOfProduct), 0),
				MAX(PFD.TimeTaken),
				COUNT(PFD.DiscountPercentage)
			FROM tmp_cros_join_dimD_dimC TDC 
			LEFT JOIN DatawareHouse.dbo.TRN_fact_discount PFD 
			ON TDC.dimC_CustomerId = PFD.customerID 
			AND TDC.DimD_DiscountTypeId = PFD.DiscountTypeID
			WHERE PFD.DateID IS NULL OR PFD.DateID = @current_day
			GROUP BY TDC.DimD_DiscountTypeId, TDC.dimC_CustomerId;

			INSERT INTO DatawareHouse.dbo.tmp_Periodic_fact_discount(
				DiscountTypeID,
				DateID,
				customerID,
				-----------------------------
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT 
				TDC.DimD_DiscountTypeId,
				@current_day,
				TDC.dimC_CustomerId,
				-----------------------------
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0
			FROM tmp_cros_join_dimD_dimC TDC 
			WHERE not exists (select 1 from DatawareHouse.dbo.tmp_Periodic_fact_discount x where TDC.dimC_CustomerId =x.CustomerID and TDC.DimD_DiscountTypeId=x.DiscountTypeID)

		


			INSERT INTO DatawareHouse.dbo.Periodic_fact_discount(
				DiscountTypeID,
				DateID,
				customerID,
				-----------------------------
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT 
				DiscountTypeID,
				DateID,
				customerID,
				-----------------------------
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			FROM DatawareHouse.dbo.tmp_Periodic_fact_discount;

			TRUNCATE TABLE DatawareHouse.dbo.tmp_periodic_fact_discount;
			SET @current_day = DATEADD(DAY, 1, @current_day);
		END;

	end;
   insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_Periodic_fact_discount'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
GO



GO
CREATE OR ALTER PROCEDURE FILL_ACC_Fact_discount
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_ACC_Fact_discount'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	if (exists(select 1 from Acc_fact_discount))
	begin
		TRUNCATE TABLE tmp_acc_fact_discount;

		

		DECLARE @end_date DATE;
		DECLARE @current_day DATE;

		SELECT @current_day = MIN(CONVERT(DATE, DateID, 120)), 
			   @end_date = MAX(CONVERT(DATE, DateID, 120))
		FROM [DatawareHouse].dbo.Periodic_fact_discount;


		select @current_day = ISNULL((SELECT DATEADD(DAY, 1, [date]) 
							   FROM DataWarehouse.dbo.time_acc_fact_discount) , 
							  @current_day);



		WHILE @current_day <= @end_date
		BEGIN
			TRUNCATE TABLE tmp1_acc_fact_discount;

			INSERT INTO tmp1_acc_fact_discount (
				DiscountTypeID,
				customerID,
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT
				DiscountTypeID,
				customerID,
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			FROM tmp_acc_fact_discount;

			TRUNCATE TABLE tmp2_acc_fact_discount;

			INSERT INTO tmp2_acc_fact_discount (
				DiscountTypeID,
				customerID,
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT
				DiscountTypeID,
				customerID,
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			FROM DatawareHouse.dbo.periodic_fact_discount
			WHERE DateID = CONVERT(VARCHAR(10), @current_day, 120);

			TRUNCATE TABLE tmp_acc_fact_discount;

			INSERT INTO tmp_acc_fact_discount (
				DiscountTypeID,
				customerID,
				TotalSalesAmount,
				AvgDiscountPercentage,
				TotalDiscountAmount,
				AvgDiscountAmount,
				MaximumDiscountPercentage,
				AvgQuantitySold,
				TotalQuantitySold,
				MaxTimeTaken,
				NumberOfUses
			)
			SELECT
				tmp2.DiscountTypeID,
				tmp2.customerID,
				ISNULL(tmp1.TotalSalesAmount, 0) + tmp2.TotalSalesAmount,
				CASE 
					WHEN (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) = 0 THEN 0 
					ELSE (ISNULL(tmp1.AvgDiscountPercentage * tmp1.NumberOfUses, 0) + tmp2.AvgDiscountPercentage * tmp2.NumberOfUses) / 
						 (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) 
				END,
				ISNULL(tmp1.TotalDiscountAmount, 0) + tmp2.TotalDiscountAmount,
				CASE 
					WHEN (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) = 0 THEN 0 
					ELSE (ISNULL(tmp1.TotalDiscountAmount, 0) + tmp2.TotalDiscountAmount) / 
						 (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) 
				END,
				CASE 
					WHEN ISNULL(tmp1.MaximumDiscountPercentage, 0) > tmp2.MaximumDiscountPercentage THEN tmp1.MaximumDiscountPercentage 
					ELSE tmp2.MaximumDiscountPercentage 
				END,
				CASE 
					WHEN (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) = 0 THEN 0 
					ELSE (ISNULL(tmp1.TotalQuantitySold, 0) + tmp2.TotalQuantitySold) / 
						 (ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses) 
				END,
				ISNULL(tmp1.TotalQuantitySold, 0) + tmp2.TotalQuantitySold,
				CASE 
					WHEN ISNULL(tmp1.MaxTimeTaken, 0) > tmp2.MaxTimeTaken THEN tmp1.MaxTimeTaken 
					ELSE tmp2.MaxTimeTaken 
				END,
				ISNULL(tmp1.NumberOfUses, 0) + tmp2.NumberOfUses
			FROM tmp1_acc_fact_discount tmp1
			RIGHT JOIN tmp2_acc_fact_discount tmp2
			ON tmp1.DiscountTypeID = tmp2.DiscountTypeID AND tmp1.customerID = tmp2.customerID;

			SET @current_day = DATEADD(DAY, 1, @current_day);
		END;

		truncate table acc_fact_discount;
		INSERT INTO DatawareHouse.dbo.acc_fact_discount (
			DiscountTypeID,
			customerID,
			TotalSalesAmount,
			AvgDiscountPercentage,
			TotalDiscountAmount,
			AvgDiscountAmount,
			MaximumDiscountPercentage,
			AvgQuantitySold,
			TotalQuantitySold,
			MaxTimeTaken,
			NumberOfUses
		)
		SELECT
			DiscountTypeID,
			customerID,
			TotalSalesAmount,
			AvgDiscountPercentage,
			TotalDiscountAmount,
			AvgDiscountAmount,
			MaximumDiscountPercentage,
			AvgQuantitySold,
			TotalQuantitySold,
			MaxTimeTaken,
			NumberOfUses
		FROM tmp_acc_fact_discount;

		TRUNCATE TABLE DataWarehouse.dbo.time_acc_fact_discount;

		INSERT INTO DataWarehouse.dbo.time_acc_fact_discount ([date])
		VALUES (@end_date);
	END;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_ACC_Fact_discount'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;



GO

CREATE OR ALTER PROCEDURE Fill_trn_fact_HR
AS
BEGIN
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'Fill_trn_fact_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)


	if (exists (select 1 from DatawareHouse.dbo.trn_fact_HR))
	begin
		DECLARE @end_date DATETIME;
		DECLARE @current_day DATETIME;

		SELECT @current_day = DATEADD(day , 1 , MAX(dateID)) FROM DatawareHouse.dbo.trn_fact_HR 

		SELECT @end_date =
			CASE
			WHEN (SELECT MAX(date) FROM [SA].[dbo].SA_Rollcall) > (SELECT MAX(date) FROM [SA].[dbo].SA_Commuting_time)
			THEN (SELECT MAX(date) FROM [SA].[dbo].SA_Rollcall)
			ELSE (SELECT MAX(date) FROM [SA].[dbo].SA_Commuting_time)
		END;

		WHILE @current_day <= @end_date
			BEGIN
			INSERT INTO DatawareHouse.dbo.trn_fact_HR(
				dateID,
				EmployeeId,
				PositionID,
				work_leave,
				hours_of_work_leave,
				overtime,
				work_time
				)
			SELECT
					ISNULL(ro.date, co.date) AS dateID,
					ISNULL(ro.employee_id, co.employee_id) AS EmployeeId,
					ISNULL(em.CurrentPositionID, em.OriginalPositionID) AS PositionID,
					----------------------------------------------------------
					ISNULL(MIN(case when ro.work_leave = 1 then 1 else 0 end), 0) AS work_leave,
					ISNULL(MIN(ro.hours_of_work_leave), 0) AS hours_of_work_leave,
					ISNULL(MIN(ro.overtime), 0) AS overtime,
					ISNULL(
					MAX(CASE WHEN co.commuting = 1 THEN DATEPART(hour, co.time) END) -
					MIN(CASE WHEN co.commuting = 0 THEN DATEPART(hour, co.time) END),
					0) AS work_time
				FROM sa.dbo.SA_Rollcall AS ro
				FULL OUTER JOIN sa.dbo.SA_Commuting_time AS co
				ON ro.employee_id = co.employee_id AND ro.date = co.date
				INNER JOIN DatawareHouse.dbo.dim_employee AS em
				ON ro.employee_id = em.Employee_id OR co.employee_id = em.Employee_id
				Where isnull(ro.date , co.date) = @current_day
				GROUP BY
				ISNULL(ro.date, co.date),
				ISNULL(ro.employee_id, co.employee_id),
				ISNULL(em.CurrentPositionID, em.OriginalPositionID);

			SET @current_day = DATEADD(DAY, 1, @current_day);
		END;
	end;
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'Fill_trn_fact_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;



GO 
CREATE OR ALTER PROCEDURE FILL_Periodic_fact_HR
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_Periodic_fact_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)


	if (exists(select 1 from monthly_fact_HR))
	begin

		DECLARE @min_date DATE;
		DECLARE @max_date DATE;

		select DATEADD(MONTH,1,max(dateid)) from DatawareHouse.dbo.monthly_fact_HR

		SELECT @max_date = MAX(DateID) 
		FROM [DatawareHouse].dbo.trn_fact_HR;

		WHILE @min_date <= @max_date
		BEGIN
			insert into DatawareHouse.dbo.monthly_fact_HR (
			dateID,
			EmployeeId,
			PositionID,
			monthly_DaysPresent,
			monthly_DaysAbsent,
			monthly_hours_of_work_leave,
			monthly_OverTime,
			monthly_MaximumOverTime,
			tmonthly_work_time )
			select
			@min_date ,
			isnull(tr.EmployeeId , em.Employee_id)  ,
			isnull(tr.PositionID , isnull(em.CurrentPositionID,em.OriginalPositionID)) ,
			isnull(30 - sum( case when tr.work_leave = 1 then 1 else 0 end),0),
			isnull(sum(case when tr.work_leave = 1 then 1 else 0 end),0),
			isnull(sum(tr.hours_of_work_leave),0),
			isnull(sum(tr.overtime),0),
			isnull(max(tr.overtime),0),
			ABS(isnull(sum(tr.work_time),0))
			from DatawareHouse.dbo.trn_fact_HR as tr right join DatawareHouse.dbo.dim_employee as em 
			on ( tr.EmployeeId = em.Employee_id )
			where year(tr.dateID) = year(@min_date) and  month(tr.dateID) = month(@min_date)
			group by 
			isnull(tr.EmployeeId , em.Employee_id),
			isnull(tr.PositionID , isnull(em.CurrentPositionID,em.OriginalPositionID))


			SET @min_date = DATEADD(month, 1, @min_date);
		END;
	end
    insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_Periodic_fact_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;
GO



GO
CREATE OR ALTER PROCEDURE FILL_ACC_Fact_HR
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_ACC_Fact_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)


	if (exists  (select 1 from DatawareHouse.dbo.acc_fact_HR))
	begin 

	TRUNCATE TABLE tmp_acc_fact_HR;
	

	DECLARE @end_date DATE;
    DECLARE @current_day DATE;

    SELECT @current_day = MIN(CONVERT(DATE, DateID, 120)), 
           @end_date = MAX(CONVERT(DATE, DateID, 120))
    FROM [DatawareHouse].dbo.monthly_fact_HR;

	select @current_day = ISNULL((SELECT DATEADD(DAY, 1, [date]) 
                           FROM DataWarehouse.dbo.time_acc_fact_HR) , 
                          @current_day);

    WHILE @current_day <= @end_date
    BEGIN
        TRUNCATE TABLE tmp1_acc_fact_HR;

        INSERT INTO tmp1_acc_fact_HR (
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        )
        SELECT
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        FROM tmp_acc_fact_HR;

        TRUNCATE TABLE tmp2_acc_fact_HR;

        INSERT INTO tmp2_acc_fact_HR (
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        )
        SELECT
            EmployeeId,
			PositionID,
            monthly_DaysPresent,
			monthly_DaysAbsent,
			monthly_hours_of_work_leave,
			monthly_OverTime,
			monthly_MaximumOverTime,
			tmonthly_work_time
        FROM DatawareHouse.dbo.monthly_fact_HR tr
        WHERE year(tr.dateID) = year(@current_day) and  month(tr.dateID) = month(@current_day);

        TRUNCATE TABLE tmp_acc_fact_HR;

        INSERT INTO tmp_acc_fact_HR (
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        )
        SELECT
            tmp2.EmployeeId,
			tmp2.PositionID,

            ISNULL(tmp1.TotalDaysPresent, 0) + tmp2.TotalDaysPresent,
			ISNULL(tmp1.TotalDaysAbsent, 0) + tmp2.TotalDaysAbsent,
			ISNULL(tmp1.total_hours_of_work_leave, 0) + tmp2.total_hours_of_work_leave,
			ISNULL(tmp1.total_OverTime, 0) + tmp2.total_OverTime,          
			CASE 
                WHEN ISNULL(tmp1.total_MaximumOverTime, 0) > tmp2.total_MaximumOverTime THEN tmp1.total_MaximumOverTime 
                ELSE tmp2.total_MaximumOverTime 
            END,
            ABS(ISNULL(tmp1.total_work_time, 0) + tmp2.total_work_time)
        FROM tmp1_acc_fact_HR tmp1
        RIGHT JOIN tmp2_acc_fact_HR tmp2
        ON tmp1.EmployeeId = tmp2.EmployeeId;

        SET @current_day = DATEADD(month, 1, @current_day);
    END;

	Truncate Table acc_fact_HR;
    INSERT INTO acc_fact_HR (
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        )
        SELECT
            EmployeeId,
			PositionID,
			---------------
			TotalDaysPresent,
			TotalDaysAbsent,
			total_hours_of_work_leave,
			total_OverTime,
			total_MaximumOverTime,
			total_work_time 
        FROM tmp1_acc_fact_HR;

    TRUNCATE TABLE DataWarehouse.dbo.time_acc_fact_HR;

    INSERT INTO DataWarehouse.dbo.time_acc_fact_HR ([date])
    VALUES (@end_date);


	end
	insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_ACC_Fact_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;