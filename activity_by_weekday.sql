USE bellabeat;

/*
This script will utilize the daily_activity table to visualize how participants' 
activity was distributed throughout the week.
*/

-- What days are people most active?

-- Calculate weekday from date and summarize activities
SELECT 
	WEEKDAY(ActivityDate) as day_num,
    DAYNAME(ActivityDate) as weekday,
    ROUND(AVG(TotalSteps)) as avg_steps,
    ROUND(AVG(Calories)) as avg_calories,
    ROUND(AVG(VeryActiveMinutes), 2) as avg_very_active,
    ROUND(AVG(TotalDistance), 2) as avg_distance
FROM daily_activity
WHERE TotalSteps > 0
GROUP BY day_num, weekday
ORDER BY day_num;

