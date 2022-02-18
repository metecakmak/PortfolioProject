--Google Data Analytics Certificate - Capstone Project
--data analysis process: ask, prepare, process, analyze, share
--Business task: How do annual members and casual riders use Cyclistic bikes differently?

-- Upload 6 months data into SQL server and looking at user type numbers
WITH all_trip as (
SELECT * FROM dbo.['202101-divvy-tripdata$']
UNION 
SELECT * FROM dbo.['202102-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202103-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202104-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202105-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202106-divvy-tripdata$']
) 
SELECT 
	member_casual,
	count(*) as Count_of_UserType
FROM all_trip 
	GROUP BY member_casual
---casual--> 876.475, member-->1.096.919


-- Let's create a table to store 6-month data and also to be able to make readable codes  
CREATE TABLE all_trips (
ride_id nvarchar(255),
rideable_type nvarchar(255),
started_at datetime,
ended_at datetime,
start_station_name nvarchar(255),
start_station_id nvarchar(255),
end_station_name nvarchar(255),
end_station_id nvarchar(255),
start_lat float,
start_lng float,
end_lat nvarchar(255),
end_lng nvarchar(255),
member_casual nvarchar(255),
F14 datetime )

INSERT INTO all_trips (ride_id, rideable_type, started_at, ended_at, start_station_name,
 start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual, F14 )
SELECT * FROM dbo.['202101-divvy-tripdata$']
UNION 
SELECT * FROM dbo.['202102-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202103-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202104-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202105-divvy-tripdata$']
UNION
SELECT * FROM dbo.['202106-divvy-tripdata$']


--  Before importing sql server we had some datas where start time was greater than finish time we removed those datas in ms excel 
-- Let's check Null values
SELECT ride_id 
FROM all_trips
	WHERE ride_id is NULL or
	member_casual is NULL


-- Checking for duplicated records
SELECT COUNT(DISTINCT (ride_id)) as unique_,
COUNT(ride_id) as count
FROM all_trips 
--1973025 unique
--1973394 count


-- We have found some duplicated records. To be able to clean them let's use ROW_NUMBER()
SELECT * 
	FROM
		(SELECT *, 
				ROW_NUMBER() OVER(PARTITION BY started_at, ended_at, start_station_name,
				start_station_id, end_station_name, end_station_id  ORDER BY ride_id) as Row_Number_
		FROM all_trips
		) TMP 
			WHERE Row_Number_ >1


-- DELETE duplicated rows
WITH ROW_NUM_ AS
		(SELECT *, 
				ROW_NUMBER() OVER(PARTITION BY started_at, ended_at, start_station_name,
				start_station_id, end_station_name, end_station_id  ORDER BY ride_id) as Row_Number_
		FROM all_trips
		) 
		DELETE FROM ROW_NUM_
							WHERE Row_Number_ >1
 


--Let's calculate the sum of ride length by each day
SELECT 
		DATENAME(weekday, started_at) AS day_name,
				SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour				
FROM all_trips 
	GROUP BY 
		DATENAME(weekday, started_at)
	ORDER BY 2 DESC
-- As we excepted saturday and sunday are top 2 days 



-- Let's break things down by user type
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips 
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual, weekday_num
	Order by 1,2,3

-- Ýn all days casual members has more ride hours than members

-- Create View For Viz
Create View ride_hour_byUser AS
SELECT 
    weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips 
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual,weekday_num


-- Let's look at the total ride hours difference closely 
SELECT 
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	--WHERE member_casual = 'member'
	WHERE member_casual  in ('casual','member')
	GROUP BY 
		member_casual
-- member customers total ride = 252930
-- casual customers total ride = 508987


-- Creating View for Viz
CREATE View total_ride_hour_byUser AS
SELECT 
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	--WHERE member_casual = 'member'
	WHERE member_casual  in ('casual','member')
	GROUP BY 
		member_casual




-- Another question that we going to ask is that what is the total hours differece in each member type by weekdays and weekend
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	
	WHERE member_casual in ('casual','member') and
		DATENAME(weekday, started_at) in ('Saturday', 'Sunday')
	
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual,weekday_num

-- Create View for Viz

CREATE View Weekend_Total_tide_byUser AS
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	
	WHERE member_casual in ('casual','member') and
		DATENAME(weekday, started_at) in ('Saturday', 'Sunday')
	
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual,weekday_num


-- Let's look at the total ride hours in weekdays by user type
SELECT
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	
	WHERE member_casual in ('member','casual') and
		DATENAME(weekday, started_at) not in ('Saturday', 'Sunday')
	
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual, weekday_num
	Order by 1

-- Create View for Viz
Create View Weekdays_Total_ride_byUser  AS
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			SUM(DATEDIFF(HOUR, started_at, ended_at)) as ride_length_hour
FROM all_trips
	
	WHERE member_casual in ('member','casual') and
		DATENAME(weekday, started_at) not in ('Saturday', 'Sunday')
	
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual, weekday_num
	
---- The result here: while MEMBER TOTAL RÝDE HOURS doubled in weekdays compared to Weekend, we are not able to observe a significant change for CASUAL riders


-- The result above brings a new question. We have calculated total ride hours in weekdays and weekend by usertypes. What about daily average ride by user type?
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			AVG(DATEDIFF(minute, started_at, ended_at)) as ride_length_hour
FROM all_trips 
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual,weekday_num
	Order by 1,2,3


-- Create View for Viz
Create View Avg_Total_ride_minute_byUser AS
SELECT 
	weekday_num,
	DATENAME(weekday, started_at) AS day_name,
		member_casual as user_type,
			AVG(DATEDIFF(minute, started_at, ended_at)) as ride_length_hour
FROM all_trips 
	GROUP BY 
		DATENAME(weekday, started_at),
		member_casual,weekday_num


-- We didn't create weekday, month and year columns so far. Let's create them and add our table
SELECT * FROM all_trips

ALTER TABLE all_trips
ADD 
	day_of_week nvarchar(50),
	month_ nvarchar(50),
	year_ nvarchar(50)

UPDATE all_trips
SET  day_of_week = DATENAME(weekday, started_at),
	month_ = DATENAME(MONTH, started_at),
	year_ = YEAR(started_at)


-- Forgot to add month_num and weekday_num
ALTER TABLE all_trips
ADD 
	month_num nvarchar(10),
	weekday_num nvarchar(10)

UPDATE  all_trips
SET 
	month_num = MONTH(started_at),
	weekday_num = DATEPART(WEEKDAY,started_at)


-- DEFAULT FÝRST DAY came with Sunday we need to change it to Monday as the first day of the week
SET DATEFIRST 1;
UPDATE  all_trips
SET 
	month_num = MONTH(started_at),
	weekday_num = DATEPART(WEEKDAY,started_at)


-- Also we have an empty column. Let's delete it 
ALTER TABLE all_trips
DROP COLUMN F14;


-- Loking at total total user numbers by month
SELECT  
month_num, month_ as month_name, year_,
	COUNT(CASE WHEN member_casual = 'member' THEN 1 ELSE null END) num_of_member_user,
		COUNT(CASE WHEN member_casual = 'casual' THEN 1 ELSE null END) num_of_casual_user,
			COUNT(member_casual) total_num_of_user
FROM all_trips
GROUP BY 
		month_num, month_,year_
ORDER BY 1

--CREATE VÝEW for VÝZ
CREATE View total_num_by_month AS
SELECT  
month_num, month_ as month_name, year_,
	COUNT(CASE WHEN member_casual = 'member' THEN 1 ELSE null END) num_of_member_user,
		COUNT(CASE WHEN member_casual = 'casual' THEN 1 ELSE null END) num_of_casual_user,
			COUNT(member_casual) total_num_of_user
FROM all_trips
GROUP BY 
		month_num, month_,year_



-- To be able to examine deeply user behaviors we can examine daily hour activities. Let's create a time column for this.
Select * from all_trips

ALTER TABLE all_trips
ADD hour_of_day int

UPDATE all_trips
SET hour_of_day = DATEPART(HOUR,started_at)


-- Breaking things down by hours
SELECT 
	hour_of_day,
	COUNT(
		CASE 
			WHEN member_casual = 'member' THEN 1 
		ELSE NULL
		END) AS num_of_member_user,
	COUNT(
		CASE 
			WHEN member_casual = 'casual' THEN 1 
		ELSE NULL
		END) AS num_of_casual_user

FROM all_trips
GROUP BY hour_of_day
ORDER BY 1

CREATE View Member_vs_Casual_Hour AS
SELECT 
	hour_of_day,
	COUNT(
		CASE 
			WHEN member_casual = 'member' THEN 1 
		ELSE NULL
		END) AS num_of_member_user,
	COUNT(
		CASE 
			WHEN member_casual = 'casual' THEN 1 
		ELSE NULL
		END) AS num_of_casual_user

FROM all_trips
GROUP BY hour_of_day


-- Calculating most popular statation for casual users
SELECT  
	Top 10 start_station_name,
	COUNT(
		CASE
			WHEN member_casual = 'casual' THEN 1
			ELSE null 
		END) AS num_of_casual_user

FROM all_trips
WHERE start_station_name is not null
GROUP BY start_station_name
ORDER BY 2 DESC

-- Create View for Viz
CREATE View Casual_users_top10_station AS
SELECT  
	Top 10 start_station_name,
	COUNT(
		CASE
			WHEN member_casual = 'casual' THEN 1
			ELSE null 
		END) AS num_of_casual_user

FROM all_trips
WHERE start_station_name is not null
GROUP BY start_station_name











