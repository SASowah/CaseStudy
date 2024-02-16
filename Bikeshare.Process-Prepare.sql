--combine all 12 tables into 1year complete table (combined_1year)
SELECT
  ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
INTO Combined_Table
FROM (
   SELECT
     ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data01
   UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data02 
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data03
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data04
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data05
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data06
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data07
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data08
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data09
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data10
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data11
	UNION ALL
   SELECT
	ride_id, rideable_type, started_at, ended_at,start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual
   FROM bikeshare_data12
   );
 -- Change data type from the combined_table
 ALTER TABLE combined_table
   ALTER COLUMN ride_id TYPE VARCHAR,
   ALTER COLUMN rideable_type TYPE VARCHAR(50),
   ALTER COLUMN started_at TYPE TIMESTAMP USING started_at::timestamp without time zone,
   ALTER COLUMN ended_at TYPE TIMESTAMP USING ended_at::timestamp without time zone,
   ALTER COLUMN start_station_name TYPE VARCHAR(100),
   ALTER COLUMN start_station_id TYPE VARCHAR,
   ALTER COLUMN end_station_name TYPE VARCHAR(100),
   ALTER COLUMN end_station_id TYPE VARCHAR,
   ALTER COLUMN start_lat TYPE NUMERIC USING start_lat::numeric,
   ALTER COLUMN start_lng TYPE NUMERIC USING start_lng::numeric,
   ALTER COLUMN end_lat TYPE NUMERIC USING end_lat::numeric,
   ALTER COLUMN end_lng TYPE NUMERIC USING end_lng::numeric,
   ALTER COLUMN member_casual TYPE VARCHAR(20);
   
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
