# BMW Car Sales Data Set SQL + Tableau Project

/*
Goal of the project
This SQL analysis provides comprehensive insights into BMW car sales patterns. 
Key findings include:
	Which BMW models and model years have the highest demand
	The most popular car specifications among buyers
	Regional variations in sales performance
	Price points with the best conversion rates*/
    
use bmw_car_sales; 
-- Project Setup

-- Creating Database and Importing data
-- 1
	create database bmw_car_sales;
-- 2    
	select * from `bmw_car_sales_classification`;

/* Explanation
1 We have created database called bmw_car_sales.
2 Import the data table called 'bmw_car_sales_classification' to the database
*/

/* ---------------------------------------------------------------------------------------------------------------------------------*/

# Intial data exploration and Cleaning Process
 
-- Checking the total records
-- 1
	select count(*) from bmw_car_sales_classification;
    
-- Checking incorrect data types
-- 2
	alter table bmw_car_sales_classification
	add column years date 
	after year;

	update bmw_car_sales_classification
	set years = date(year);
    
    alter table bmw_car_sales_classification
    drop column year;
    
-- Checking missing values-Checking missing values
-- 3
	select 
		 sum(case when model is null then 1 else 0 end) as missing_car_model,
		 sum(case when year is null then 1 else 0 end) as missing_year,
		 sum(case when price_usd is null then 1 else 0 end) as missing_price,
		 sum(case when region is null then 1 else 0 end) as missing_region
	from `bmw_car_sales_classification`;
    
-- Checking for unsual values in key fields
-- 4
	select min(years), max(years) from bmw_car_sales_classification;
    
-- 5 
	select min(price_usd), max(price_usd) from bmw_car_sales_classification;
    
-- 6    
	select distinct fuel_type from bmw_car_sales_classification;
    
/* Findings:
1 	The data set have total of (9739) records in the table. 
2	The column 'Year' datetime_format converted from (2016-01-01 00:00:00) to (2016-01-01) date_format
	and drop the year column.
3	Each column have no missing value (0% of missing values) .
4	Check for unrealistic years
5	Check for unrealistic prices
6	Check for inconsistent fuel types
*/

/* ---------------------------------------------------------------------------------------------------------------------------------*/


# Exploratory Data Analysis

-- Overall Sales Performance
-- 1
	select 
		count(*) as total_listing,
		sum(sales_volume) as car_sold,
		round(sum(sales_volume) * 100 / count(*), 2) as conversion_rate
	from bmw_car_sales_classification;

-- Sales by year
-- 2
	select 
		years,
        count(*) as total_listing,
        sum(sales_volume) as car_sold,
        round(sum(sales_volume) * 100 / count(*), 2) as converstion_rate
	from bmw_car_sales_classification
    group by years
    order by car_sold desc;
    
-- Sales by fuel type
-- 3
	select
		fuel_type,
        count(*) as total_listing,
        sum(sales_volume) as car_sold,
        round(sum(sales_volume) * 100 / count(*), 2) as conversion_rate
    from bmw_car_sales_classification 
    group by fuel_type
    order by fuel_type;
    
-- Sales by Transmission
-- 4
	select
		Transmission,
        count(*) as total_listing,
        sum(sales_volume) as car_sold,
        round(sum(sales_volume) * 100 / count(*), 2) as conversion_rate
	from bmw_car_sales_classification
    group by Transmission
    order by conversion_rate desc;
    
-- Sales by engine size category
-- 5
	select
		case
			when Engine_Size_L < 2.0 then 'small (<2.0L)'
            when Engine_Size_L between 2.0 and 3.0 then 'medium (2.0 - 3.0L)'
            else 'large(<3.0L)' 
		end as engine_catagory,
        count(*) as total_listing,
        sum(sales_volume) as car_sold,
        round(sum(sales_volume) * 100 / count(*), 2) as conversion_rate
	from bmw_car_sales_classification
    group by engine_catagory
    order by total_listing;
    
/* Findings
1	Tells us overall conversion rate from listings to sales
		total_listing = 9739, car_sold = 4,981,832, coversion_rate = 511,539.50.
2	Shows how sales performance varies by model year, 
	helping identify if newer or older models sell better
		2022 is the hishest sales performing year with 3,503,994 car_sold
        2020 is the lowest sales performing year with 3,204,293 car sold.
3	Reveal which car specifications are most popular in the market.
		Electric BMW models are the most popular 2501 total_listing and 12,842,988 car_sold
        Diesel BMW models are the least popular 2351 total_listing and 12,030,645 car_sold.
4	Shows BMW cars sales performance by different transmission
		manual: transmission cars have 25,150,600 units sold
		automatic: transmission cars have 24,668,232 unit sold
5	Shows BMW car sales performance by engine catagory
		cars with large size engines are most sold with 27,287,983 units
        cars with medium size engines are the seconde most sold with 16,104,246 units
*/


/* ---------------------------------------------------------------------------------------------------------------------------------*/


# Regional sales performance
-- Sales by region
-- 1 
	select 	
		region,
        count(*) as total_listing,
        sum(sales_volume) as car_sold,
        round(sum(sales_volume) * 100 / count(*), 2) as conversion_rate,
        round(avg(price_usd), 2) as avg_price
	from bmw_car_sales_classification
    group by region
    order by avg_price desc;

-- Top 5 best-selling models by region
-- 2
	with ranked_models as (
		select 
			region,
			model,
			sum(sales_volume) as car_sold,
			count(*) as total_listing,
			row_number()over(partition by region order by sum(sales_volume) desc) as 'rank'
		from bmw_car_sales_classification
		group by region, model
        )
    select  
		region,
		model,
		total_listing,
		car_sold,
		round(car_sold * 100.0 / total_listing, 2) AS conversion_rate
	from ranked_models
	where 'rank' <= 5;

/*Findings
1	 Identifies high-sale performing regions
		Europe and Asia leads are leading regions consicutively
        with making more than $75 thousend income in average
2	I dentifies the most selling models by region
		- X1 is the most selling model is Africa and Europe regions
        - i3 is the most selling model is Asia region
        - X8 is the most selling model is Middel east region
        - 3 Series is the most selling model is North America and sounth america region
*/    

# Price Analysis
-- Price distribution by sale outcome
-- 1
	select 
		case
			when price_usd < 30000 then 'under $30k'
            when price_usd between 30000 and 50000 then '$30k-$50k'
            when price_usd between 50000 and 70000 then '$50k-$70k'
            when price_usd between 70000 and 90000 then '$70k-$90k'
            else 'above $90k'
		end as price_range,
		sum(sales_volume) as car_sold,
        sum(case when sales_volume = 0 then 1 else 0 end) as car_not_sold,
        round(sum(sales_volume) * 100.0 / count(*), 2) AS conversion_rate
	from bmw_car_sales_classification
    group by price_range
    order by price_range;

-- Average price difference between sold and unsold cars
-- 2
	select 
		Sales_Classification,
		count(*) as 'count',
        sum(sales_volume) as car_sold,
        round(avg(price_usd), 2) as avg_price,
        round(avg(Mileage_KM), 2) as avg_mileage_km,
        round(avg(Engine_Size_L), 2) as avg_eng_size
	from bmw_car_sales_classification
    group by Sales_Classification
    order by count desc;

/* Findings
1	shows which price ranges have the best conversion rates, helping with pricing strategy.
		- cars with  above $90k pricing rage sold the most but third in conversion rate
        - $30k-$50k pricing range have have the highest conversion rate and second ranked car sold units
2	shows comparession average characteristics of  high vs. low cars to identify what buyers prefer
		- high cars are most consumed with 24 million unit sold
*/   


/* ---------------------------------------------------------------------------------------------------------------------------------*/


# Tableau Preparation
-- Create a view for sales performance by model and year
-- 1
	create view sales_by_model_year as
		select
			model,
			years,
			count(*) as total_listing,
			sum(sales_volume) as cars_sold,
			round(sum(sales_volume) * 100.0 / count(*), 2) as conversion_rate,
			round(avg(price_usd), 2) as avg_price
	from bmw_car_sales_classification
	group by  model, years;

-- Create a view for customer demographic analysis
-- 1
	create view sales_by_demographics as
		select 
			region,
			count(*) as total_listing,
			sum(sales_volume) as cars_sold,
			round(sum(sales_volume) * 100.0 / count(*), 2) as conversion_rate,
			round(avg(price_usd), 2) as avg_price
	from bmw_car_sales_classification
	group by region;


/* Conclusion
These insights can inform business decisions around:
	Inventory management (stocking more of the high-conversion models)
	Marketing strategy (targeting high-conversion customer segments)
	Pricing strategy (emphasizing price points with best sales performance)
	Regional sales approaches (adapting to local preferences)
*/