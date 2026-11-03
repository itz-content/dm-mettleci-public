# ElectroMart Infrastructure

Parent Page: ([Deployment Environment for MettleCI](DeploymentEnvironmentforMettleCI.md))

# **Application Description**

The ElectroMart ETL application is created for use as a demonstration platform to help showcase the capabilities of MettleCI,  focusing on compliiance rule implementation, unit testing and Git Integration in support of an automated software delivery process. 

The application organizes and processes data related to consumer electronics products, such as smartphones, laptops, televisions, tablets, and wearables. It contains key ETL functionalities, including loading raw data from `.csv` files, applying transformations to enrich data, and populating a structured star schema in a PostgreSQL database. The schema includes core dimensions like `DimCustomer`, `DimProduct`, `DimSupplier`, and `DimDate`, along with fact tables such as `FactSales` and `FactFinance` for transaction-level data.

This platform also highlights the use of Slowly Changing Dimension (SCD) logic to handle updates in attributes like customer details and product information.  Summary tables such as `DailySalesSummary`, `ProductPerformance`, and `QuarterlyFinancials` are also included.

ElectroMart is a non-production application with data and processes designed to simulate realistic ETL scenarios, providing a practical but simplified context for showcasing MettleCI's features.

# **Overall Process Flow**

1. **Utility and Maintenance**:
    - Load reference data and update surrogate keys.
2. **Staging**:
    - Load raw data from source `.csv` files into staging tables.
    - Key staging tables: `StgCustomer`, `StgSupplier`, `StgProduct`, `StgSales`, `StgFinance`.
3. **Transformation**:
    - Enrich and transform raw data to align with business rules.
    - Key transformed tables: `TransformedCustomer`, `TransformedSales`.
4. **Dimensional Loading**:
    - Populate slowly changing dimensions (SCD) with clean and enriched data.
    - Key dimension tables: `DimCustomer`, `DimSupplier`, `DimProduct`, `DimDate`.
5. **Fact Loading**:
    - Aggregate and load transactional data into fact tables.
    - Key fact tables: `FactSales`, `FactFinance`.
6. **Summary Tables**:
    - Aggregate data for reporting and analytics.
    - Key summary tables: `DailySalesSummary`, `ProductPerformance`, `QuarterlyFinancials`, `RegionSalesSummary`.

# **POSTGRESQL Electromart Entity Relationship Diagram**

PostgeSQL - WW2\_117 ERD

# **Database File Descriptions**

| **Table Name** | **Natural Key** | **Primary Key** | **Related Tables** | **Description** |
| --- | --- | --- | --- | --- |
| **StgCustomer** | CustomerID |  | DimCustomer, FactSales | Stores raw customer data extracted from the source system for staging. |
| **StgSupplier** | SupplierID |  | DimSupplier, DimProduct | Contains raw supplier data for staging, linked to product and supplier dimensions. |
| **StgProduct** | ProductCode |  | DimProduct, FactSales | Stores raw product information, including cost and inventory, for staging. |
| **StgSales** | SalesID |  | FactSales, FactFinance | Captures raw sales transaction details, including customer and product data. |
| **StgFinance** | TransactionID |  | FactFinance, FactSales | Contains financial transaction details, such as revenue and cost, for staging. |
| **TransformedCustomer** | CustomerID |  | DimCustomer, FactSales | Intermediate table with enriched customer data, including calculated segments. |
| **TransformedSales** | SalesID |  | FactSales, DimDate, DimCustomer, DimProduct | Intermediate table with transformed sales data, enriched with calculated fields like SalesTotal. |
| **RefUSStates** | StateAbbrv |  | DimCustomer, TransformedSales, RegionSalesSummary | Reference table for mapping U.S. states to regions, used for regional sales aggregation. |
| **DimCustomer** | CustomerID | CustomerKey | FactSales, TransformedCustomer | Stores enriched customer data with surrogate keys for analytics. |
| **DimProduct** | ProductCode | ProductKey | FactSales, ProductPerformance | Contains detailed product information, including cost and supplier relationships. |
| **DimSupplier** | SupplierID | SupplierKey | DimProduct, FactSales | Stores supplier details linked to products and sales. |
| **DimDate** | Date | DateKey | FactSales, FactFinance, DailySalesSummary, QuarterlyFinancials | Time dimension used for grouping and filtering data by date, quarter, or year. |
| **FactSales** |  | SalesKey | DimCustomer, DimProduct, DimDate, DimSupplier | Transactional fact table storing detailed sales data linked to dimensions. |
| **FactFinance** |  | FinanceKey | DimDate, FactSales, DimProduct | Transactional fact table capturing financial data like revenue, cost, and profit linked to sales. |
| **DailySalesSummary** |  | DateKey, ProductKey | FactSales, DimDate, DimProduct | Summary table aggregating daily sales metrics like total sales amount and quantities sold. |
| **RegionSalesSummary** |  | DateKey, RegionName | FactSales, DimDate, RefUSStates | Aggregates sales data by region and date for regional performance analysis. |
| **ProductPerformance** |  | DateKey, ProductKey | FactSales, FactFinance, DimProduct, DimDate | Summary table with metrics like revenue, cost, profit, and quantities sold per product over time. |
| **QuarterlyFinancials** |  | Year, Quarter | FactFinance, DimDate | Summary table aggregating financial metrics like total revenue, cost, and profit for each quarter. |

# **Row Counts**

The source data is extracted from 2 sets of .csv files.   

Intial Load:  One set of files for refUSStates, customer, supplier and product.  Also sales and finance for January 1, 2023 thru August 31, 2024.

Secondary Run:  Additional sales and finance files for September 1, 2024 thru September 29, 2024.

| **Table Name** | **Inital Load** | **Demostration Run** | **Total** |  |  |
| --- | --- | --- | --- | --- | --- |
| **StgCustomer** | 20,000 | 0 | NA |  |  |
| **StgSupplier** | 5 | 0 | NA |  |  |
| **StgProduct** | 50 | 0 | NA |  |  |
| **StgSales** | 100,000\[Jan 1, 2023 - Aug 31, 2024\] | 2000\[Sep 1, 2024 - Sept 29,2024\] | NA | NA |  |
| **StgFinance** | 100,000\[Jan 1, 2023 - Aug 31, 2024\] | 2,000\[Sep 1, 2024 - Sept 29,2024\] | NA |  |  |
| **RefUSStates** | 51 | 0 | 51 |  |  |
| **DimCustomer** | 20,000 | 0 | 20,000 |  |  |
| **DimProduct** | 50 | 0 | 50 |  |  |
| **DimSupplier** | 5 | 0 | 5 |  |  |
| **DimDate** | 1825 \[Jan 1, 2023 - Dec 31, 2027\] | 0 | 1825 |  |  |
| **FactSales** | 100,000\[Jan 1, 2023 - Aug 30, 2024\] | 2,000\[Sep 1, 2024 - Sept 29,2024\] | 102,000\[Jan 1, 2023 - Sept 29,2024\] | 102,000 |  |
| **FactFinance** | 100,000\[Jan 1, 2023 - Aug 30,2024\] | 2,000\[Sep 1, 2024 - Sept 29,2024\] | 102,000\[Jan 1, 2023 - Sept 29,2024\] |  |  |
| **DailySalesSummary** | 29,595 | \<select date range\> | NA |  |  |
| **RegionSalesSummary** | 5467 | \<select date range\> | NA |  |  |
| **ProductPerformance** | 29,595 | \<select date range\> | NA |  |  |
| **QuarterlyFinancials** | 7 | \<select date range\> | NA |  |  |

# **ETL Job Specifications**

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
| ### Grouping | ### Job Name | ### Source | ### Target | ### Job Description |
| Supplier | LdStgSupplier | StgSupplier.csv | stgsupplier | Load data from Supplier source .csv file to staging table on PostgreSQL |
| Supplier | ScdDimSupplierDs | stgsupplier, dimsupplier | scddimsupplier.ds | Process the Supplier slowly changing dimension |
| Supplier | LdDimSupplier | scddimsupplier.ds | dimsupplier | Load Supplier dimension table on PostgreSQL |
| Product | LdStgProduct | StgProduct.csv | stgproduct | Load data from Product source .csv file to staging table on PostgreSQL |
| Product | ScdDimProductDs | stgproduct, dimproduct | scddimproduct.ds | Process the Product slowly changing dimension |
| Product | LdDimProduct | scddimproduct.ds | dimproduct | Load Product dimension table on PostgreSQL |
| Customer | LdStgCustomer | StgCustomer.csv | stgcustomer | Load data from Customer source .csv file to staging table on PostgreSQL |
| Customer | TxTransformedCustomer | stgcustomer | transformedcustomer | Transformation of customer data from staging table |
| Customer | ScdDimCustomerDs | transformedcustomer, dimcustomer | scddimcustomer.ds | Process the Customer slowly changing dimension |
| Customer | LdDimCustomer | scddimcustomer.ds | dimcustomer | Load Customer dimension table on PostgreSQL |
| Sales | LdStgSales | StgSales.csv, factsales | stgsales | Load data from Sales source .csv file to staging table on PostgreSQL |
| Sales | TxTransformedSales | stgsales, dimcustomer, refusstates | transformedsales.ds, transformedsales | Transformation of  Sales data from staging table |
| Sales | TxFactSalesDs | transformedsales, dimproduct, dimsupplier, dimcustomer, dimdate | factsales.ds | Prepare data for load to Sales fact table |
| Sales | LdFactSales | factsales.ds | factsales | Load Sales fact table on PostgreSQL |
| Finance | LdStgFinance | StgFinance.csv, factfinance | stgfinance | Load data from Finance source .csv file to staging table on PostgreSQL |
| Finance | TxFactFinanceDs | stgfinance, factsales | factfinance.ds | Prepare data for load to Finance fact table |
| Finance | LdFactFinance | factfinance.ds | factfinance | Load Finance fact table on PostgreSQL |
| Reporting/Daily Summary | TxDailySalesSummaryDs | factsales | dailysalessummary.ds | Prepare data for load to Daily Sales Summary table |
| Reporting/Daily Summary | LdDailySalesSummary | dailysalessummary.ds | dailysalessummary | Load Daily Sales Summary table on PostgreSQL |
| Reporting/Product Performance | TxProductPerformanceDs | factsales, factfinance | productperformance.ds | Prepare data for load to Product Performance table |
| Reporting/Product Performance | LdProductPerformance | productperformance.ds | productperformance | Load Product Performance table on PostgreSQL |
| Reporting/Quarterly Financials | TxQuarterlyFinancialsDs | factfinance, dimdate | quarterlyfinancials.ds | Prepare data for load to Quarterly Financials table |
| Reporting/Quarterly Financials | LdQuarterlyFinancials | quarterlyfinancials.ds | quarterlyfinancials | Load Quarterly Financials table on PostgreSQL |
| Reporting/Region Summary | TxRegionSalesSummaryDs | factsales, dimcustomer, refusstates | regionsalessummary.ds | Prepare data for load to Region SalesSummary table |
| Reporting/Region Summary | LdRegionSalesSummary | regionsalessummary.ds | regionsalessummary | Load Region Sales Summary table on PostgreSQL |
| Sequence | UpdDimSupplier | LdStgSupplier, ScdDimSupplierDs, LdDimSupplier | Source to target sequence for updating the Supplier dimension table |  |
| Sequence | UpdDimProduct | LdStgProduct, ScdDimProductDs, LdDimProduct | Source to target sequence for updating the Product dimension table |  |
| Sequence | UpdDimCustomer | LdStgCustomer, TxTransformedCustomer, ScdDimCustomerDs, LdDimCustomer | Source to target sequence for updating the Customer dimension table |  |
| Sequence | UpdFactSales | LdStgSales, TxTransformedSales, TxFactSalesDs, LdFactSales | Source to target sequence for updating the Sales fact table |  |
| Sequence | UpdFactFinance | LdStgFinance, TxFactFinanceDs, LdFactFinance | Source to target sequence for updating the Finance fact table |  |
| Sequence | UpdDailySalesSummary | TxDailySalesSummaryDs, TxDailySalesSummaryDs | Source to target sequence for updating the Daily Sales Summary table |  |
| Sequence | UpdProductPerformance | TxProductPerformanceDs, LdProductPerformance | Source to target sequence for updating the Product Performance table |  |
| Sequence | UpdQuarterlyFinancials | TxQuarterlyFinancialsDs, LdQuarterlyFinancials | Source to target sequence for updating the Quarterly Financials table |  |
| Sequence | UpdRegionSalesSummary | TxRegionSalesSummaryDs, LdRegionSalesSummary | Source to target sequence for updating the Region Sales Summary table |  |
| Utility | TxCreateDateSource | NA | dimdate.ds | Create source data for Date dimension table |
| Utility | LdDimDate | dimdate.ds | dimdate | Load Date dimension on PostgreSQL |
| Utility | LdRefUSStates | RefUSStates.csv | refusstates | Load data from US States reference .csv file (RefUSStates) to table on PostgreSQL |
| Utility | UpdateSupplierSurrogateKeys, UpdateProductSurrogateKeys, UpdateCustomerSurrogateKeys, UpdateSalesSurrogateKeys, UpdateFinanceSurrogateKeys | dimsupplier, dimproduct, dimcustomer, factsales, factfinance | skdimsupplier, skdimproduct, skdimcustomer, skfactsales, skfactfinance | Create/Update surrogate key files from PostgreSQL dimension and fact tables |
| Utility | UpdateAllSurrogateKeys | UpdateSupplierSurrogateKeys, UpdateProductSurrogateKeys, UpdateCustomerSurrogateKeys, UpdateSalesSurrogateKeys, UpdateFinanceSurrogateKeys | Sequence for updating all surrogate key files |  |
| Parameter Sets | pDatabaseConnect | DATASRC, USERID, PASSWORD | PostgreSQL, postgres, \*\*\* | Connection parameters for PostgreSQL |
| Parameter Sets | pGlobal | DatasetDir; LandingDir; StateFileDir; ReportDir; RejectDir | /data/electtromar/dataset; /data/electromart/file; /data/electromart/file; /data/electromart/report; /data/electromart2/reject | File path parameters |

# **Detailed Process Flow**

Should the need arise to recreate the ElectroMart Application, these are the required steps.

Create “ElectroMart” Database \[***em***\]

1. Create tables. Run ***electromart\_dev.sql***

Create Datastage project \[**ElectroMart**\]

1. Import Datastage jobs \[**electromart.dsx**\]

Initial Database load  from “**SourceData**”  in the Electromart repository

1. Download “SourceData” from repository
    1. Copy Reference, Dimension, and large Fact files (100K) to engine server directory. \[**/data/electromart/file**\]
    2. Remove metadata from filenames **\[i.e. StgFinance\_20230101-20240831\_100K \>\> StgFinance.csv\]**
2. Create/Load Utility files
    1. Load data from US States reference.csv file (RefUSStates) to table on PostgreSQL \[**LdRefUSStates**\]
    2. Create source data for Date dimension table \[**TxCreateDateSource**\]
    3. Delete existing SK files. Create SK files from PostgreSQL dimension and fact tables \[**UpdateAllSurrogatekeys**\]
3. Load Dimension, Fact and Summary tables in order, using the provided job sequences.  **Note: For Sales and Finance use the large 100K source files for initial load**
    1. **\[LdDimDate\]**
    2. **\[UpdDimSupplier\]**
    3. **\[UpdDimProduct\]**
    4. **\[UpdDimCustomer\]**
    5. **\[UpdFactSales\]**
    6. **\[UpdFactFinance\]**
    7. **\[UpdDailySalesSummary\]**
    8. **\[UpdProductPerformance\]**
    9. **\[UpdQuarterlyFinancials\]**
    10. **\[UpdRegionSalesSummary\]**
