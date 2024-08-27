use DatawareHouse
Go 
CREATE OR ALTER PROCEDURE FILL_SA
AS BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_SA'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	EXEC SA.dbo.Fill_SA_City
	EXEC SA.dbo.Fill_SA_Location
	exec sa.dbo.Fill_SA_Customer
	EXEC SA.DBO.Fill_SA_Category
	EXEC SA.DBO.Fill_SA_Company
	EXEC SA.DBO.Fill_SA_Product
	EXEC SA.DBO.Fill_SA_Warehouse
	EXEC SA.DBO.Fill_SA_Contract_type
	EXEC SA.DBO.Fill_SA_Discount_Code_Type
	EXEC SA.DBO.Fill_SA_Discount_Code
	EXEC SA.DBO.Fill_SA_Position
	EXEC SA.DBO.Fill_SA_Employee
	exec sa.dbo.Fill_SA_Representative
	EXEC sa.dbo.Fill_SA_Warehouse_Entrance
	exec sa.dbo.Fill_SA_Warehouse_Outlet
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_SA'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

Go 
CREATE OR ALTER PROCEDURE FIRST_FILL_DIM
AS BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FIRST_FILL_DIM'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	EXEC DatawareHouse.dbo.first_fill_dim_company
	EXEC DatawareHouse.dbo.first_fill_dim_customer
	EXEC DatawareHouse.dbo.first_fill_dim_discountType
	EXEC DatawareHouse.dbo.first_fill_dim_employee
	EXEC DatawareHouse.dbo.first_fill_dim_Location
	EXEC DatawareHouse.dbo.first_fill_dim_position
	EXEC DatawareHouse.dbo.first_fill_dim_product
	EXEC DatawareHouse.dbo.first_fill_dim_warehouse
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FIRST_FILL_DIM'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

Go 
CREATE OR ALTER PROCEDURE FIRST_FILL_DIM
AS BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FIRST_FILL_DIM'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	EXEC DatawareHouse.dbo.first_fill_dim_company
	EXEC DatawareHouse.dbo.first_fill_dim_customer
	EXEC DatawareHouse.dbo.first_fill_dim_discountType
	EXEC DatawareHouse.dbo.first_fill_dim_employee
	EXEC DatawareHouse.dbo.first_fill_dim_Location
	EXEC DatawareHouse.dbo.first_fill_dim_position
	EXEC DatawareHouse.dbo.first_fill_dim_product
	EXEC DatawareHouse.dbo.first_fill_dim_warehouse

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FIRST_FILL_DIM'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

Go 
CREATE OR ALTER PROCEDURE FILL_DIM
AS BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_DIM'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	EXEC DatawareHouse.dbo.fill_dim_company
	EXEC DatawareHouse.dbo.fill_dim_customer
	EXEC DatawareHouse.dbo.fill_dim_discountType
	EXEC DatawareHouse.dbo.fill_dim_employee
	EXEC DatawareHouse.dbo.fill_dim_Location
	EXEC DatawareHouse.dbo.fill_dim_position
	EXEC DatawareHouse.dbo.fill_dim_product
	EXEC DatawareHouse.dbo.fill_dim_warehouse

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_DIM'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

GO
CREATE OR ALTER PROCEDURE FIRST_FILL_DATAMART_inventory
AS 
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FIRST_FILL_DATAMART_inventory'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	exec DatawareHouse.dbo.First_Fill_trn_fact_inventory
	exec DatawareHouse.dbo.FIRST_FILL_Periodic_Fact_inventory
	Exec DatawareHouse.dbo.FIRST_FILL_ACC_Fact_inventory
	EXEC DatawareHouse.DBO.FIRST_FILL_FACT_INVENTORY

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FIRST_FILL_DATAMART_inventory'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;

GO
CREATE OR ALTER PROCEDURE FILL_DATAMART_inventory
AS 
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_DATAMART_inventory'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	exec DatawareHouse.dbo.Fill_trn_fact_inventory
	exec DatawareHouse.dbo.FILL_Periodic_Fact_inventory
	Exec DatawareHouse.dbo.FILL_ACC_Fact_inventory
	EXEC DatawareHouse.DBO.FILL_FACT_INVENTORY

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_DATAMART_inventory'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE FIRST_FILL_DATAMART_DISCOUNT
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FIRST_FILL_DATAMART_DISCOUNT'  , GETDATE() , 'start run procedure'   , ' ' , 0)


	exec DatawareHouse.dbo.FIRST_FILL_trn_fact_discount
	exec DatawareHouse.dbo.FIRST_FILL_Periodic_fact_discount
	exec DatawareHouse.dbo.FIRST_FILL_ACC_Fact_discount
	exec DatawareHouse.dbo.FIRST_FILL_FACTLESS_FACT_discount

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FIRST_FILL_DATAMART_DISCOUNT'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE FILL_DATAMART_DISCOUNT
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_DATAMART_DISCOUNT'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	exec DatawareHouse.dbo.FILL_trn_fact_discount
	exec DatawareHouse.dbo.FILL_Periodic_fact_discount
	exec DatawareHouse.dbo.FILL_ACC_Fact_discount
	exec DatawareHouse.dbo.FILL_FACTLESS_FACT_discount

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_DATAMART_DISCOUNT'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE FIRST_FILL_DATAMART_HR
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FIRST_FILL_DATAMART_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	exec DatawareHouse.dbo.FIRST_Fill_trn_fact_HR
	EXEC DatawareHouse.dbo.FIRST_FILL_Periodic_fact_HR
	EXEC DatawareHouse.dbo.FIRST_FILL_ACC_Fact_HR
	EXEC DatawareHouse.dbo.FIRST_FILL_Factless_fact_HR

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FIRST_FILL_DATAMART_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


GO
CREATE OR ALTER PROCEDURE FILL_DATAMART_HR
AS
BEGIN
insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
(  'FILL_DATAMART_HR'  , GETDATE() , 'start run procedure'   , ' ' , 0)

	exec DatawareHouse.dbo.Fill_trn_fact_HR
	EXEC DatawareHouse.dbo.FILL_Periodic_fact_HR
	EXEC DatawareHouse.dbo.FILL_ACC_Fact_HR
	EXEC DatawareHouse.dbo.FILL_Factless_fact_HR

insert into DatawareHouse.dbo.Log (procedure_name,date,description , table_name ,number_of_row_inserted) values
( 'FILL_DATAMART_HR'  , GETDATE() , 'end run procedure'   , ' ' , 0)
END;


