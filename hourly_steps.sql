USE bellabeat;

/*
This script will import and clean the hourly_steps table, as well as allow me to visualize 
how step activity is distributed throughout the day.
*/

# Import hourly_steps table using import wizard. 
# Alter Id column to BIGINT and ActivityHour column to DATETIME with origin format %m/%d/%Y %I:%M:%S %p (%I denotes 12hr clock, %p denotes AM/PM)

-- Check for duplicates
SELECT 
    Id, COUNT(Id),
    ActivityHour, COUNT(ActivityHour),
    StepTotal, COUNT(StepTotal)
FROM
    hourly_steps
GROUP BY Id, ActivityHour, StepTotal
HAVING 
	COUNT(ActivityHour) > 1 AND
    COUNT(Id) > 1 AND
    COUNT(StepTotal) > 1
ORDER BY Id, ActivityHour
;
    
# What time of day are people most active?
-- Create column chart to show hourly activity
SELECT
	HOUR(TIME(ActivityHour)) as hour,
    ROUND(AVG(StepTotal)) as average_steps
FROM hourly_steps
GROUP BY hour
;

-- Generate Heatmap to show step activity for each user for each hour of the day.
SELECT
	Id,
    TIME(ActivityHour) as hour,
    ROUND(AVG(StepTotal)) as avg_steps
FROM hourly_steps
GROUP BY 
	Id, hour
;
    
-- Identify median value to calibrate heatmap
SET @row_index := -1;

SELECT AVG(subq.StepTotal) as median_value
FROM (
    SELECT @row_index:=@row_index + 1 AS row_index, StepTotal
    FROM hourly_steps
    ORDER BY StepTotal
  ) AS subq
  WHERE subq.row_index 
  IN (FLOOR(@row_index / 2) , CEIL(@row_index / 2))
  # Median value is 40 steps per hour
  ;