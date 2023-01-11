USE bellabeat;
SELECT * FROM weight_log_info;

/*
This script will import and clean the weight_log_info table and analyze how manually tracking weight data correlates to 
calorie burn compared to users who did not participate in the weight tracking feature. 
*/

-- Table imported using import wizard. 
-- Update date format and drop Time column since the time the weight was recorded is not relevant to this analysis.
UPDATE weight_log_info
SET Date = DATE(str_to_date(Date, "%m/%d/%y"))
;

ALTER TABLE weight_log_info
CHANGE Date Date DATE
;

ALTER TABLE weight_log_info
DROP COLUMN Time
;

-- Change IsManualReport to VARCHAR
ALTER TABLE weight_log_info
MODIFY IsManualReport varchar(255)
;

-- Confirm updates
SELECT * FROM weight_log_info
;

-- Check for duplicates
SELECT
	*, COUNT(*) as duplicates
FROM weight_log_info
GROUP BY 
	Id, Date, WeightKg, WeightPounds, Fat, BMI, IsManualReport, LogId
HAVING
	duplicates > 1
# Zero duplicate records found
;

-- Check DISTINCT users in weight_log_table
SELECT DISTINCT(Id)
FROM weight_log_info
# There are only 8 users who participated in this feature
;

# Find start date and end date of table
SELECT
	MIN(Date) as StartDate,
    MAX(Date) as EndDate
FROM weight_log_info
# Start date 2016-04-12, end date 2016-05-12. Same as other tables.
;

# What is the calorie burn difference between people who participated in the weight log feature vs. those who did not.

-- Create table for users who logged weight
SELECT 
	da.Id,
    TotalSteps,
    Calories,
    CASE WHEN TotalSteps = TotalSteps THEN "Logged Weight" ELSE NULL END AS LoggedStatus
FROM
	daily_activity da
    INNER JOIN
    weight_log_info wl ON wl.Id = da.Id AND wl.Date = da.ActivityDate
# Returns 67 rows with 8 distinct participants who have weight data recorded
;

-- Create table showing users who did not log their weight
SELECT 
	Id,
    TotalSteps,
    Calories,
    CASE WHEN TotalSteps = TotalSteps THEN "Did Not Log Weight" ELSE NULL END AS LoggedStatus
FROM 
	daily_activity
WHERE 
	Id NOT IN (SELECT Id FROM weight_log_info)
# Returns 632 rows with 25 distinct participants who did not appear in the weight log table
;

-- Create table to use to compare steps and calorie burn for people who logged their weight vs. people who did not
SELECT 
	da.Id,
    TotalSteps,
    Calories,
    CASE WHEN TotalSteps = TotalSteps THEN "Logged Weight" ELSE NULL END AS LoggedStatus
FROM
	daily_activity da
    INNER JOIN
    weight_log_info wl ON wl.Id = da.Id AND wl.Date = da.ActivityDate
UNION
SELECT 
	Id,
    TotalSteps,
    Calories,
    CASE WHEN TotalSteps = TotalSteps THEN "Did Not Log Weight" ELSE NULL END AS LoggedStatus
FROM 
	daily_activity
WHERE 
	Id NOT IN (SELECT Id FROM weight_log_info)
;