# Data-Warehouse-for-Inventory

📦 Data Warehouse for Inventory Management
Welcome to the Data Warehouse project for Inventory Management! This project is designed to handle data related to inventory, HR, and discount management in a warehouse environment. The data warehouse integrates data from various operational sources to provide insightful reporting and analysis capabilities.

📊 Project Overview
This project consists of three primary data marts:

Discount Management Data Mart: Handles data related to various discount types, their descriptions, validity periods, and applicable categories.
HR Management Data Mart: Manages employee data including personal details, employment information, warehouse assignments, and job positions.
Inventory Data Mart: Tracks inventory transactions such as product entries and exits in the warehouse, including product details and warehouse locations.
🗂️ Data Marts
1. Discount Management Data Mart
The Discount Management Data Mart is responsible for managing all information related to discounts. This includes:

Discount Types: Different types of discounts available, including conditions and eligibility.
Customer Discounts: Links between customers and discounts they have used or are eligible for.
Key Tables:

dim_discountType: Contains details about discount types, including ID, description, minimum purchase requirements, and active dates.
dim_discount_code: Maps discount codes to customers and discount types.
2. HR Management Data Mart
The HR Management Data Mart deals with employee-related data. This data mart helps in tracking employee details and their job-related information.

Key Tables:

dim_employee: Contains detailed information about employees such as name, gender, contact information, hire date, and current job position.
dim_position: Information about various job positions, including work hours, leave entitlements, and overtime policies.
3. Inventory Data Mart
The Inventory Data Mart monitors inventory transactions, including product movements in and out of the warehouse.