-- Clean data(duplicates,null values)
 -- Check for null values
 SELECT *
 FROM combined_table
 WHERE ride_id IS NULL OR
       started_at IS NULL OR
	   ended_at IS NULL OR
	   start_station_name IS NULL OR
	   end_station_name IS NULL OR
	   member_casual IS NULL;
 --Remove rows with null values in specific columns (IF ANY)
 DELETE FROM combined_table
 WHERE ride_id IS NULL OR
       started_at IS NULL OR
	   ended_at IS NULL OR
	   start_station_name IS NULL OR
	   end_station_name IS NULL OR
	   member_casual IS NULL;
-- Check for duplicates
SELECT ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id,
       end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual,
       COUNT(*)
FROM combined_table
GROUP BY ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id,
         end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
HAVING COUNT(*) > 1;

-- Add new colum by extracting diff components from started_at/ended_at column
ALTER TABLE combined_table
ADD COLUMN start_time TIME,
ADD COLUMN start_date DATE,
ADD COLUMN week_day VARCHAR(20),
ADD COLUMN month VARCHAR(20);

-- check for the newly created columns
select 
  start_date,
  start_time,
  week_day,
  month
 from combined_table;
 
 -- Populate new columns
 UPDATE combined_table
 SET start_time = CAST(started_at as TIME),
     start_date = CAST(started_at as DATE),
	 week_day = EXTRACT(DOW FROM started_at) + 1,--add +1to make it compatible with 1-7 (Monday-Sunday)
	 month = TO_CHAR(started_at, 'Month');
	  
-- Add Duration column(calculate datediff)
ALTER TABLE combined_table
ADD COLUMN duration INTERVAL;

--populate duration column (calculate the time diff-sec)
UPDATE combined_table
SET duration = ended_at - started_at;
--Check duration column
SELECT duration
FROM combined_table;

-- select relevant columns for your analyses (cleaned_Cyclstic)
SELECT * FROM combined_table;
  
 SELECT
   ride_id,rideable_type,started_at,ended_at,start_lat,start_lng,end_lat,end_lng,
   member_casual,start_time,start_date,week_day,month,duration
 FROM combined_table
 AS cleaned_cyclistic ;
 
SELECT
   ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng,
   member_casual, start_time, start_date, week_day, month, duration
FROM combined_table
AS cleaned_cyclistic;

-- Create a new table based on the SELECT query result
CREATE TABLE Yearly_bikeshare AS
SELECT
   ride_id, rideable_type, started_at, ended_at, start_lat, start_lng, end_lat, end_lng,
   member_casual, start_time, start_date, week_day, month, duration
FROM combined_table
AS clened_cyclistic;

SELECT * 
FROM yearly_bikeshare;

--After cleaning, analyze the data
--Count number of riders as Total riders()
SELECT
  COUNT(ride_id) AS total_riders
FROM yearly_bikeshare;
--total_riders = 4332069

--count of riders by members
SELECT
  member_casual,
  COUNT(*) AS count_of_riders
FROM yearly_bikeshare
GROUP BY member_casual;

--total users of each rideable type
SELECT
  rideable_type,
  COUNT(*) AS total_users
FROM yearly_bikeshare
GROUP BY rideable_type;

--total monthly riders
SELECT
  month,
  COUNT(ride_id)AS total_riders
FROM yearly_bikeshare
GROUP BY month
ORDER BY total_riders DESC;

--Total user type by day of the week
SELECT
   week_day,
   member_casual,
   COUNT(DISTINCT ride_id) AS total_trips
FROM yearly_bikeshare
GROUP BY week_day,member_casual
ORDER BY total_trips;

-- Alternate syntex
SELECT  
    week_day,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS MemberTrips,
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS CasualTrips,
    COUNT(DISTINCT ride_id) AS totaltrips
FROM 
    yearly_bikeshare
GROUP BY 
    week_day
ORDER BY 
    totaltrips DESC;

-- Rideable type by total users by membership for each month
SELECT  
    month,
    rideable_type,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS MemberUsers,
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS CasualUsers,
    COUNT(DISTINCT ride_id) AS TotalUsers
FROM 
    yearly_bikeshare
GROUP BY 
    month, rideable_type
ORDER BY 
    month, rideable_type;
	
--Monthly rideable types
SELECT
   month,
   SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS classic,
   SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS docked,
   SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS electric,
   COUNT(DISTINCT ride_id) AS total_users
FROM yearly_bikeshare
GROUP BY
   month,rideable_type
ORDER BY month,total_users;

-- Monthly rideable_types by membership type
SELECT
  member_casual,
  month,
  COUNT(DISTINCT ride_id) AS total_rides,
  SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS classic_bike,
  SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS docked_bike,
  SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS electric_bike
FROM
  yearly_bikeshare
GROUP BY
  member_casual, month
ORDER BY
  month,total_rides DESC;

 SELECT *
 FROM yearly_bikeshare;
 
 select month
 from yearly_bikeshare
 group by month;
 
 
-- Updated weekday to weeknames
UPDATE
  yearly_bikeshare
  SET
  week_day = TO_CHAR(started_at, 'Day');

-- Avg ride duration
SELECT 
  AVG(duration)
From yearly_bikeshare;

--Avg duration by membership type
SELECT
  member_casual,
  AVG(duration) AS avg_duration
FROM
  yearly_bikeshare
GROUP BY
  member_casual;
 --Avg duration by membership 2 
SELECT
  AVG(duration) AS avg_duration,
  AVG(CASE WHEN member_casual = 'member' THEN duration END) AS avgmemberduration,
  AVG(CASE WHEN member_casual = 'casual' THEN duration END) AS avgcasualduration
FROM yearly_bikeshare;

-- Avg duration of membership riders by month
SELECT
  COUNT(ride_id) AS no_of_users,
  month,
  AVG(duration) AS avg_duration,
  AVG(CASE WHEN member_casual = 'member' THEN duration END) AS avg_member_duration,
  AVG(CASE WHEN member_casual = 'casual' THEN duration END) AS avg_casual_duration
FROM yearly_bikeshare
GROUP BY month;
  
-- Avg duration of membership type by day of the week
SELECT
  COUNT(ride_id) AS no_of_users,
  week_day,
  AVG(duration) AS avg_duration,
  AVG(CASE WHEN member_casual = 'member' THEN duration END) AS avg_member_duration,
  AVG(CASE WHEN member_casual = 'casual' THEN duration END) AS avg_casual_duration
FROM yearly_bikeshare
GROUP BY week_day;

--Calculate bussiest time by for membership type
SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(ride_id) AS no_of_users
FROM yearly_bikeshare
GROUP BY
   hour_of_day,
   member_casual
ORDER BY
   no_of_users DESC;
-- Bussiest membership type
SELECT
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member,
  COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual,
  COUNT(ride_id) AS no_of_users
FROM yearly_bikeshare
GROUP BY 
  hour_of_day
ORDER BY
  no_of_users DESC;

--Bussiest weekday
SELECT
  week_day,
  COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member,
  COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual,
  COUNT(ride_id) AS no_of_users
FROM yearly_bikeshare
GROUP BY 
  week_day
ORDER BY
  no_of_users DESC;

--Bussiest Month by membership type
SELECT
   month,
   COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member,
   COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual,
   COUNT(ride_id) AS no_of_users
FROM yearly_bikeshare
GROUP BY
   month
ORDER BY 
   no_of_users DESC;
   
-- Most popular bike by membership type
SELECT
  rideable_type,
  COUNT(ride_id) AS no_of_users,
  COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member,
  COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual
FROM yearly_bikeshare
GROUP BY 
  rideable_type
ORDER BY
  no_of_users DESC;
select * from yearly_bikeshare;
