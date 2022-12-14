---Cleaning Data

---Total Records = 541909
---135080 Records have no customerID
---406829 Records have customerID---Total Records = 541909
---135080 Records have no customerID
---406829 Records have customerID
;with online_retail as (
	Select [InvoiceNo]
		  ,[StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
	  FROM [PortpolioProject02].[dbo].['Online Retail']
	  where CustomerID != 0
),
--select * from online_retail
quantity_unit_price as 
(
	---397884 records with quantity and Unit price
	select *
	from online_retail
	where Quantity > 0 and UnitPrice > 0
),
--select * from quantity_unit_price
dup_check as (
	--duplicate Check
	select *, ROW_NUMBER() over (partition by InvoiceNo, StockCode, Quantity order by InvoiceDate)dup_flag
	from quantity_unit_price
)
---select * from dup_check where dup_flag = 1
---select * from dup_check where dup_flag > 1
---3922669 Clean Data
---5215 Duplicate Data

select *
into #online_retail_main
from dup_check
where dup_flag = 1

---clean data
---BEGIN COHORT ANALYSIS
select * from #online_retail_main

---Unique Identifier (CustomerID)
---Intial Start Date (First_Invoice_date)
---Revenue Data

/*select
	CustomerID,
	min(InvoiceDate) first_purchase_date,
	DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) Cohort_Date
into #cohort
from #online_retail_main
group by CustomerID */


select
	CustomerID, InvoiceDate,
	CONVERT(date,InvoiceDate) Cohort_Date
from #online_retail_main
Order by CustomerID asc

-- Add #cohort
select
	CustomerID, InvoiceDate,
	CONVERT(date,InvoiceDate) Cohort_Date
into #cohort
from #online_retail_main
Order by CustomerID asc

--392669 Data
select * 
from #cohort



---#cohort Index
select
	mmm.*,
	cohort_index = year_diff * 12 + month_diff + 1
from (
	select 
		mm.*,
		year_diff = invoice_year - cohort_year,
		month_diff = invoice_month - cohort_month
	from (
		select 
		m.*,
		c.Cohort_Date,
		year(m.InvoiceDate) invoice_year,
		month(m.InvoiceDate) invoice_month,
		year(c.InvoiceDate) cohort_year,
		month(c.InvoiceDate) cohort_month
		from #online_retail_main m
		Left Join #cohort c
		ON m.CustomerID = c.CustomerID
	)mm
)mmm
--where CustomerID = 14733

