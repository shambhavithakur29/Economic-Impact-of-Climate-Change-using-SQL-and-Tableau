-- ------------------
-- 1.	DATA CLEANING:
-- -------------------

-- Create a combined Table

create table "Climate Change"."Combined Data" as
select * from "Climate Change"."Australia"
union
select * from "Climate Change"."Brazil"
union
select * from "Climate Change"."Canada"
union
select * from "Climate Change"."Germany"
union
select * from "Climate Change"."India"
union
select * from "Climate Change"."South Africa"
union
select * from "Climate Change"."USA"

-- Showing the table

select * from "Climate Change"."Combined Data"

-- Check for Duplicates

Select  "Record ID"
from "Climate Change"."Combined Data"
group by "Record ID"
having count(*) > 1;

-- Showing just the country column the dataset

select distinct "Country"
from "Climate Change"."Combined Data"

-- Update the country name

update "Climate Change"."Combined Data"
set "Country" = 'India'
where "Country" = 'Inda'

-- Check for the null values

select * from "Climate Change"."Combined Data"
where "Record ID" is null
	or "Country" is null
	or "Date" is null
	or "City" is null
	or "Humidity" is null
	or "Precipitation" is null
	or "AQI" is null
	or "Extreme Weather Events" is null
	or "Climate Classification" is null
	or "Climate Zone" is null
	or "Biome Type" is null
	or "Heat Index" is null
	or "Wind Speed" is null
	or "Wind Direction" is null
	or "Season" is null
	or "Population Exposure" is null
	or "Economic Impact Estimate" is null
	or "Infrastructure Vulnerability Score" is null;

-- Update pop exposure to fill in the null value with average 

update"Climate Change"."Combined Data"
set"Population Exposure" = (
    SELECT AVG("Population Exposure")
    FROM "Climate Change"."Combined Data"
    WHERE "Country" = 'Australia' AND "Population Exposure" IS NOT NULL
)
WHERE "Record ID" = 'aus_1338';

**update city to fill in the null value with the previous/after city

update"Climate Change"."Combined Data"
set"City" = 'Toronto'
WHERE "Record ID" = 'cnd_227';


-- -----------------
-- 2.	DATA ANALYSIS
-- -----------------

-- Monthly Temperature Trends

select TO_CHAR ("Date",'Month') as Month_Name, 
	avg("Temperature") as Avg_Temperature
from "Climate Change"."Combined Data"
group by TO_CHAR ("Date",'Month'), extract (month from "Date")
order by extract (Month from "Date");


-- Average the temp by country

select "Country",
	avg("Temperature") as Avg_Temperature
from "Climate Change"."Combined Data"
group by "Country"
Order by Avg_Temperature desc;

-- Extreme weather events over time

select to_char("Date", 'Month') as Month_Name,
	count(*) as Event_count
from "Climate Change"."Combined Data"
where "Extreme Weather Events" <> 'None'
Group by to_char("Date", 'Month')
order by min("Date");

-- Country wise extreme events

select "Country",
	count(*) as Event_Count
from "Climate Change"."Combined Data"
where "Extreme Weather Events" <> 'None'
group by "Country"
order by Event_count desc;

-- Relationship between temperature and extreme weather events

SELECT  
	CASE  
		WHEN "Temperature" < 10 THEN 'Very Cold (<10°C)' 
		WHEN "Temperature" BETWEEN 10 AND 15 THEN 'Cold (10-15°C)' 
		WHEN "Temperature" BETWEEN 15 AND 20 THEN 'Moderate (15-20°C)' 
		WHEN "Temperature" BETWEEN 20 AND 25 THEN 'Warm (20-25°C)' 
		ELSE 'Hot (>25°C)' 
		END AS Temperature_Range, 
		"Extreme Weather Events", 
		COUNT(*) AS Event_Count 
FROM "Climate Change"."Combined Data" 
WHERE "Extreme Weather Events" <> 'None' 
GROUP BY Temperature_Range, "Extreme Weather Events" 
ORDER BY Temperature_Range, Event_Count DESC;

-- Which cities are experiencing extreme weather events are what are the economic and population impacts?

select  "Country", "City", "Extreme Weather Events", 
	count(*) as "Event Type", 
	Round(avg("Temperature"), 1) as "Average Temperature", 
	sum("Population Exposure") as "Total Population Exposure", 
	sum("Economic Impact Estimate") as "Total Economic Impact", 
	round(avg("Infrastructure Vulnerability Score"), 0) as "Average Vulnerability" 
from "Climate Change"."Combined Data" 
where "Date" between '2025-03-03' and '2025-03-07' 
and "Extreme Weather Events" != 'None' 
group by "Country", "City", "Extreme Weather Events" 
order by "Total Economic Impact" desc; 

-- What are the top 5 cities with the highest air quality concerns and their associate risks? 

select  "Country", "City", 
	round(avg("AQI"), 0) as "Average AQI", 
	count(*) as "Days above 200 AQI", 
	SUM("Population Exposure") as "Total Population Exposure", 
	round(avg("Temperature"), 1) as "Average Temperature" 
from "Climate Change"."Combined Data" 
where "Date" between '2025-03-03' and '2025-03-07' 
group by "Country", "City" 
having avg("AQI") > 100 
order by "Average AQI" 
limit 5;

-- Which biome types are most risk from extreme weather events this week? 

select "Biome Type", 
	count(*) as "Total Records", 
	count(distinct concat("Country", "City")) as "Locations Affected", 
	count(case when "Extreme Weather Events" != 'None' then 1 end) as "Extreme Weather Count", 
	STRING_AGG(DISTINCT "Extreme Weather Events", ', ') as "Event Types", 
	Round(avg("Temperature"), 1) as "Average Temperature", 
	sum("Economic Impact Estimate") as "Total Economic Impact Estimate", 
	Round(Avg("Infrastructure Vulnerability Score"), 0) as "Average Vulnerability" 
from "Climate Change"."Combined Data" 
where "Date" between '2025-03-03' and '2025-03-07' 
group by "Biome Type"
