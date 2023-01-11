USE bellabeat;

SELECT * FROM sleep_day;

/*
This script will import and clean the sleep_day table, as well as analyze basic statistics, sleep distribution throughout the week, 
individual sleep patterns, and correlations between time spent sleeping vs. activity levels
*/

-- Table imported using import wizard
-- Remove the timestamp from date since records are not tracked by hour.
ALTER TABLE sleep_day
CHANGE SleepDay SleepDay DATE
;

# Check for duplicates
SELECT
	*, COUNT(*) as duplicates
FROM sleep_day
GROUP BY 
	Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
HAVING
	duplicates > 1
# 3 duplicate rows
;

# Create new table without duplicate records
CREATE TABLE sleep_day_clean SELECT DISTINCT * FROM sleep_day
;

# Verify duplicates have been removed
SELECT
	*, COUNT(*) as duplicates
FROM sleep_day_clean
GROUP BY 
	Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
HAVING
	duplicates > 1
# No duplicates returned
;

# Drop original table and rename 'sleep_day_clean' to 'sleep_day'
ALTER TABLE sleep_day RENAME sleep_day_dirty;
DROP TABLE sleep_day_dirty;
ALTER TABLE sleep_day_clean RENAME sleep_day
# changed name prior to dropping table so that the final table doesn't get dropped if script is run again
;

# Find start date, end date and duration of data in sleep_day table
SELECT 
	MIN(SleepDay) as start_date,
    MAX(SleepDay) as end_date,
    FLOOR(DATEDIFF(DATE(20160512), DATE(20160412))/7) as duration_weeks
FROM 
	sleep_day
# Start date 2016-04-12, end date 2016-05-12, duration 4 weeks
;
    
# Finding number of unique participants
SELECT 
	COUNT(DISTINCT Id) as num_of_participants
FROM 
	sleep_day
    -- There were 24 Id's that logged sleep records
;

/* 
The following queries will investigate how the sleep time corresponds with the times recorded in the daily activity table. 
Based on my observations cleaning the daily activity table, not all data added up to 24hrs of recorded data, leading me to believe 
sleep time is the missing factor.  
I will take a look at the possible combinations of how participants' total time is calculated.
*/

-- Inspecting how many records add up to a total of 24hrs (1440 minutes) excluding sleep records...
SELECT 
	*
FROM daily_activity
WHERE 
	SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes = 1440 
# 404 out of 862 rows returned. Less than half of total observations.
;

-- Check how many participants recorded at least one day with 24hr participation excluding sleep
SELECT COUNT(DISTINCT Id)
FROM (
	SELECT *
	FROM daily_activity
	WHERE SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes = 1440
	) a
# 27 participants recorded at least one day with 24hr participation excluding sleep. 
;

-- Check if sedentary time is included with sleep by finding records where all activity adds up to 1440
SELECT 
	da.Id, da.ActivityDate, da.TotalSteps, da.SedentaryMinutes, da.LightlyActiveMinutes, da.FairlyActiveMinutes, da.VeryActiveMinutes,
	sd.TotalSleepRecords, sd.TotalMinutesAsleep, sd.TotalTimeInBed AS TimeInBed, sd.TotalTimeInBed - sd.TotalMinutesAsleep AS InBedNotSleeping
FROM 
	daily_activity da
		LEFT JOIN
	sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
WHERE SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed = 1440
# Returns 126 rows
;

-- How many distinct users?
SELECT COUNT(DISTINCT a.Id)
FROM (
		SELECT 
	da.Id, da.ActivityDate, da.TotalSteps, da.SedentaryMinutes, da.LightlyActiveMinutes, da.FairlyActiveMinutes, da.VeryActiveMinutes,
	sd.TotalSleepRecords, sd.TotalMinutesAsleep, sd.TotalTimeInBed AS TimeInBed, sd.TotalTimeInBed - sd.TotalMinutesAsleep AS InBedNotSleeping
FROM 
	daily_activity da
		LEFT JOIN
	sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
WHERE SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalMinutesAsleep + (TotalTimeInBed-TotalMinutesAsleep) = 1440
	) a
# Returns 19 distinct participants
;

# Check all records where total use time adds up to 24hrs, whether it includes sleep or not
# COALESCE will return 0 in place of NULL values
SELECT # using window function to see sum of total time
	a.*,
    SUM(SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed) OVER(PARTITION BY Id, ActivityDate) AS TotalTime
FROM (
SELECT 
	da.Id, da.ActivityDate, da.TotalSteps, da.SedentaryMinutes, da.LightlyActiveMinutes, da.FairlyActiveMinutes, da.VeryActiveMinutes,
	COALESCE(sd.TotalMinutesAsleep, 0) AS TotalMinutesAsleep, COALESCE(sd.TotalTimeInBed, 0) AS TotalTimeInBed, COALESCE(sd.TotalTimeInBed - sd.TotalMinutesAsleep, 0) AS InBedNotSleeping
FROM 
	daily_activity da
		LEFT JOIN
	sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
WHERE 
	SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes  = 1440 OR
    SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed = 1440) a
# Returns 530 records
# Some devices appeared to either not record sleep data, or participants chose not to use it for tracking sleep regularly.  
# Sleep appears to be included in sedentary time on days where sleep was not recorded, however, I am unable to distinguish 
# accurate sleep data and will omit these records from sleep correlations. 
;
    
-- Inspect records that add up to greater than 24hrs
SELECT # using window function to see sum of total time
	a.*,
    SUM(SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed) OVER(PARTITION BY Id, ActivityDate) AS TotalTime
FROM (
SELECT 
	da.Id, da.ActivityDate, da.TotalSteps, da.SedentaryMinutes, 
    da.LightlyActiveMinutes, da.FairlyActiveMinutes, da.VeryActiveMinutes,
	COALESCE(sd.TotalMinutesAsleep, 0) AS TotalMinutesAsleep, COALESCE(sd.TotalTimeInBed, 0) AS TotalTimeInBed, 
    COALESCE(sd.TotalTimeInBed - sd.TotalMinutesAsleep, 0) AS InBedNotSleeping
FROM 
	daily_activity da
		LEFT JOIN
	sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
WHERE 
    SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed > 1440
ORDER BY da.Id, da.ActivityDate) a
# 155 records contain data that adds up to greater than 1440 minutes. 
# Devices that recorded sleep appear to track overlap between sedentary time and sleep, causing the device to log over 1440 minutes of total activity.
# These records will remain in further sleep analysis since they seem to track reasonable sleep data.
;
    
-- Inspect records that add up to less than than 24hrs
SELECT # using window function to see sum of total time
	a.*,
    SUM(SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed) OVER(PARTITION BY Id, ActivityDate) AS TotalTime
FROM (
SELECT 
	da.Id, da.ActivityDate, da.TotalSteps, da.SedentaryMinutes, 
    da.LightlyActiveMinutes, da.FairlyActiveMinutes, da.VeryActiveMinutes,
	COALESCE(sd.TotalMinutesAsleep, 0) AS TotalMinutesAsleep, COALESCE(sd.TotalTimeInBed, 0) AS TotalTimeInBed, 
    COALESCE(sd.TotalTimeInBed - sd.TotalMinutesAsleep, 0) AS InBedNotSleeping
FROM 
	daily_activity da
		LEFT JOIN
	sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
WHERE 
    SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed < 1440
ORDER BY da.Id, da.ActivityDate) a
# 129 records contain data that adds up to less than 1440 minutes. 
;
/*
Since approximately 20% of the records include days where total use time is less than 24hrs, 
Bellabeat should focus on battery performance as a key metric and how that can impact the customer 
experience when marketing its products. When customers charge their devices, they most likely are 
going to leave it on the charger much longer than needed, and possibly even forget to put it back
on for the day, causing them to lose out on valuable health data that they should be collecting
instead.
*/

-- Inspect individual records
SELECT 
	da.Id,
    da.ActivityDate,
    sd.SleepDay,
    VeryActiveMinutes,
    FairlyActiveMinutes,
    LightlyActiveMinutes,
    SedentaryMinutes,
    COALESCE(TotalMinutesAsleep, 0) AS TotalMinutesAsleep,
    COALESCE(TotalTimeInBed, 0) AS TotalTimeInBed,
    SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes + 
		COALESCE(TotalMinutesAsleep, 0) + (COALESCE(TotalTimeInBed, 0)-COALESCE(TotalMinutesAsleep, 0))) 
		OVER(PARTITION BY ID, ActivityDate) AS TotalMinutes
FROM 
	daily_activity da
    LEFT JOIN
    sleep_day sd ON da.Id = sd.Id AND da.ActivityDate = sd.SleepDay
ORDER BY 
	TotalMinutes DESC
# This query provides visibility into how each user's total time was calculated and easily see when sleep data was recorded.
;

/*
To get accurate statistics and correlations using the sleep data, I will join with the updated daily_activity table to include only days where
the participant's total time (including sleep) adds up to 24hrs+. Users who did not wear their device for the full day would create outliers that would skew the 
data. Lack of participation will still be considered when interpreting the overall device usage however, because it is important to understand 
how users actually used their devices (or didn't use them) during the study. For sleep correlations, however, I am only interested in seeing how 
physical activity impacted a user's sleep when we have all of the data for the entire day.
*/

-- Merge the da2 table and the sleep table to perform the rest of the analysis
-- This next code block will serve as the table on which to create a scatterplot to visualize sleep vs. activity
DROP TABLE IF EXISTS SleepCorrelations;
CREATE TEMPORARY TABLE SleepCorrelations
SELECT 
	da2.Id, da2.ActivityDate, da2.TotalSteps, da2.SedentaryMinutes, da2.LightlyActiveMinutes, da2.FairlyActiveMinutes, da2.VeryActiveMinutes,
	sd.TotalSleepRecords, sd.TotalMinutesAsleep, sd.TotalTimeInBed, sd.TotalTimeInBed - sd.TotalMinutesAsleep AS InBedNotSleeping
FROM 
	daily_activity da2
		LEFT JOIN
	sleep_day sd ON da2.Id = sd.Id AND da2.ActivityDate = sd.SleepDay
WHERE SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes + TotalTimeInBed >= 1440
# Returns 281 rows
# On days where all of the activity minutes from the daily_activity table add up to 1440, sleep data was not recorded and will not 
# be included in correlations.
;

-- Check temp table contents
SELECT * FROM SleepCorrelations;

-- How many participants?
SELECT 
	COUNT(DISTINCT Id) 
FROM SleepCorrelations
# All 24 participants recorded activity where total time adds up to 24hrs incluiding sleep data. 
# Some records show over 24 hours total time due to variability in device sleep tracking.
;
    
-- Finding basic statistics
SELECT
	MIN(TotalSleepRecords) as min_sleep_records, MAX(TotalSleepRecords) as max_sleep_records,
    MIN(TotalMinutesAsleep) as min_minutes_asleep, AVG(TotalMinutesAsleep) as average_minutes_asleep, MAX(TotalMinutesAsleep) as max_minutes_asleep,
    MIN(TotalTimeInBed) as min_time_in_bed, AVG(TotalTimeInBed) as average_time_in_bed, MAX(TotalTimeInBed) as max_time_in_bed
FROM 
	SleepCorrelations
# Some users logged more than 1 sleep event per day, with the shortest time asleeep being 58 minutes (possibly a nap).
# The maximum time asleep was recorded at 796 minutes, or over 12 hours.
;

-- Looking at average time in bed not sleeping
SELECT
	ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 2) AS AvgTimeInBedNotSleeping
FROM SleepCorrelations
# People spent about 44 minutes per day in bed while not sleeping
;

-- This next code block will help visualize the average amount of time spent asleep alongside average time in bed not sleeping each day of the week
-- Also looking at deviation from the mean.
SELECT
	a.*,
	ROUND(AvgMinutesAsleep - AVG(AvgMinutesAsleep) OVER (), 2) AS MinutesFromMean,
    ROUND(STDDEV_SAMP(AvgMinutesAsleep) OVER (), 2) AS StdDev
FROM (
SELECT 
	DAYNAME(ActivityDate) AS DayOfWeek, 
    ROUND(AVG(TotalMinutesAsleep),2) AS AvgMinutesAsleep, 
    ROUND(AVG(TotalMinutesAsleep / 60), 2) AS AvgHoursAsleep, 
    ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 2) AS AvgTimeInBedNotSleeping
FROM SleepCorrelations
GROUP BY DayOfWeek
ORDER BY 
	CASE DayOfWeek
		WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
	END 
) a
# It looks like people got the most sleep on Wednesday and the least sleep on Saturday. All within 30 minutes of the mean
;

-- Check individual sleep averages
SELECT
	Id,
    ROUND(AVG(TotalMinutesAsleep/60), 2) as AvgHoursAsleep
FROM sleep_day
GROUP BY Id
# One user averaged over 10hrs of sleep per day. 
# 3 users appear to have only recorded short naps as sleep time for less than 3hrs. 
;

/* 
The insights from this script can help Bellabeat focus on features of the membership and devices that will 
help promote better, more restful sleep. Device battery life and comfort should be top priorities to encourage
customers keep customers keep their devices on as much as possible and spend less time connected to the charger.
