-- I would be analyzing data on temperatures in Cities for the period of 1995 to 2020. 1 million rows. 
--I had removed duplicates in Excel before importing the data

--next I want to clean data before using
--the years recorded are 1995 to 2020. so anything outside of that would be removed

Select Year
from PortfolioProject.dbo.city_temperature$
where Year  < 1995 

Select Year
from PortfolioProject.dbo.city_temperature$
where Year >2020

-- there are 266 rows with wrong years and they need to be deleted. the years are 200 and 201, we will delete rows with such years

Delete From PortfolioProject.dbo.city_temperature$
Where Year <= 201

-- the state column is empty, we can remove it

ALTER TABLE PortfolioProject.dbo.city_temperature$
DROP COLUMN State;

-- there are also 2 empty columns named F9 and F10, we can delete them as well

ALTER TABLE PortfolioProject.dbo.city_temperature$
DROP COLUMN F9,F10;

-- next we can create a new column that joins Month, Day and Year 


SELECT CONCAT([Year],'-',[Month],'-',[Day]) as Date
From PortfolioProject.dbo.city_temperature$

-- next we would create a new column on the table for the date

ALTER TABLE PortfolioProject.dbo.city_temperature$
ADD Date Varchar (255)

Update PortfolioProject.dbo.city_temperature$
SET Date= CONCAT([Year],'-',[Month],'-',[Day])


ALTER TABLE PortfolioProject.dbo.city_temperature$
DROP COLUMN Date

-- the date was in varchar, So I will convert it to date format

SELECT TRY_CAST(Date as date) 
from PortfolioProject.dbo.city_temperature$

ALTER TABLE PortfolioProject.dbo.city_temperature$
ADD DateUpdated Date

Update PortfolioProject.dbo.city_temperature$
SET DateUpdated= TRY_CAST(Date as date)

ALTER TABLE PortfolioProject.dbo.city_temperature$
DROP COLUMN Date
--lastly, we would check for null values
SELECT *
from PortfolioProject.dbo.city_temperature$
where dateUpdated is null

-- the dateupdated is null because the days were zero, there are 6 rows we can delete them

Delete From PortfolioProject.dbo.city_temperature$
Where DateUpdated is null

Select *
from PortfolioProject.dbo.city_temperature$

-- we could alse see that some temperatures were recorded as -99. this would give wrong information when trying at analyze, so we will to remove the affected rows
-- we can check Region by Region

--To view temperature in Asia Region:
Select*
from PortfolioProject.dbo.city_temperature$
where Region ='Asia' 
and AvgTemperature =-99

--10500 out of 316,663 rows in Asia are affected

Select*
from PortfolioProject.dbo.city_temperature$
where Region ='Africa' 
and AvgTemperature =-99

--30,077 out of 250,996rows in Africa are affected by this

Select*
from PortfolioProject.dbo.city_temperature$
where Region ='Middle East' 
and AvgTemperature =-99
--2111 out of 43208 rows in Middle East are affected

Select*
from PortfolioProject.dbo.city_temperature$
where Region ='Australia/South Pacific' 
and AvgTemperature =-99

--387 out of 55596 rows in Australia/ SOuth Pacific are affected

Select*
from PortfolioProject.dbo.city_temperature$
where Region ='Europe' 
and AvgTemperature =-99

--12742 out of 379,656 rows are in Europe are affected

--this error in temperature accounts for 5% of total rows, we will need to delete it, in order to get more accurate figures 

DELETE FROM PortfolioProject.dbo.city_temperature$
WHERE AvgTemperature= -99
--next we could convert the temperatures from Fahrenheit to Celsius with the formula : (°F - 32) / 1.8 = °C

Select (AvgTemperature-32)/1.8 as NewTemperature
from PortfolioProject.dbo.city_temperature$

--add the NewTemperature to the table

ALTER TABLE PortfolioProject.dbo.city_temperature$
ADD NewTemperature float

UPDATE PortfolioProject.dbo.city_temperature$
SET NewTemperature = (AvgTemperature-32)/1.8

--The NewTemperature figures are in many decimal places, let's bring it down to just 2 decimal places


SELECT ROUND (NewTemperature,2)
from PortfolioProject.dbo.city_temperature$

UPDATE PortfolioProject.dbo.city_temperature$
SET NewTemperature = ROUND (NewTemperature,2)



-- now let's count how many cities were used in the data 
SELECT City,COUNT (DISTINCT City)
FROM PortfolioProject.dbo.city_temperature$
GROUP BY City

--a total of 121 Cities

--let's see the average temperatures across the cities for that period

SELECT City,Country,AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Group by City,Country
Order by AverageTemperature desc

--this shows that the city of Muscat in Oman has the highest average temperature for the period of 1995-2020

SELECT City,Country,AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Group by City,Country
Order by AverageTemperature asc

-- and Ulan-bator with the lowest Temperature, this confirms the fact that it is the coldest capital on earth

--let's see the average temperatures across the Regions for that period
SELECT Region,AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Group by Region
Order by AverageTemperature desc

--this shows Africa as the Region with the highest temperature, and Europe with the lowest

--let's check the trend in temperature in some cities over the years

SELECT City,Country,Year, AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Where City = 'Nairobi'
GROUP BY City,Country,Year
order by 3



--to view which country had the highest temperature in 1997 and the month, we will use SUBQUERY


Select City,MAX(NewTemperature) as Temperature,Month
from PortfolioProject.dbo.city_temperature$
where NewTemperature IN (select 
MAX(NewTemperature) 
from PortfolioProject.dbo.city_temperature$
where Year = 1997)
Group By City,Month

 
--This shows that in 1997, Kuwait had the highest temperature and it was in the months of June, July and August


--to view which city had the lowest temperature in 1997

Select City,MIN(NewTemperature) as Temperature,Month
from PortfolioProject.dbo.city_temperature$
where NewTemperature IN (select 
MIN(NewTemperature) 
from PortfolioProject.dbo.city_temperature$
where Year = 1997)
Group By City,Month

--This shows that in 1997, Ulan-bator had the lowest temperature and it was in the months of January and December



-- to view average temperatures per region per year

Select Region, Year,AVG(NewTemperature) as RegionTemperature
from PortfolioProject.dbo.city_temperature$
Group by Region,Year
Order by 2 asc

--Let's see monthly temperature variations in a city: Cairo
 
Select AVG(NewTemperature),Year,Month
from PortfolioProject.dbo.city_temperature$
Where City ='Cairo'
Group by Year,Month
Order by 1

-- this shows that in Cairo,the months with the highest temperatures are from May to September and lowest from December to March


--Lastly, To check the the average annual temperature across cities for the periods 1995,2005 and 2015, we would CREATE 3 TEMP TABLES and JOIN


Create Table #Temperature1995
(City nvarchar(255),
Year1995 float)

Insert into #Temperature1995
Select City,MAX(NewTemperature) as 'Year1995'
from PortfolioProject.dbo.city_temperature$
where Year =1995
Group by City

Create Table #Temperature2005
(City nvarchar(255),
Year2005 float)

Insert into #Temperature2005
Select City,MAX(NewTemperature) as 'Year2005'
from PortfolioProject.dbo.city_temperature$
where Year =2005
Group by City

Create Table #Temperature2015
(City nvarchar(255),
Year2015 float
Insert into #Temperature2015
select City,MAX(NewTemperature) as 'Year2015'
from PortfolioProject.dbo.city_temperature$
where Year =2015
Group by City



Select a.City, a.Year1995, b.Year2005,c.Year2015
from #Temperature1995 a
join #Temperature2005 b
on a.City= b.City
join #Temperature2015 c
on b.City=c.City

-- 3 queries (listed below) were later transferred to Tableau for visualization:

1.
-- average temperature per city for the period
SELECT City,Country,AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Group by City,Country
Order by AverageTemperature desc
2.
--average temperature per region for the period
SELECT City,Country,AVG(NewTemperature)as AverageTemperature
FROM PortfolioProject.dbo.city_temperature$
Group by City,Country
Order by AverageTemperature desc
3.
-- Temperature variations per city in 10 year gaps: 1995,2005 and 2015
Select a.City, a.Year1995, b.Year2005,c.Year2015
from #Temperature1995 a
join #Temperature2005 b
on a.City= b.City
join #Temperature2015 c
on b.City=c.City


