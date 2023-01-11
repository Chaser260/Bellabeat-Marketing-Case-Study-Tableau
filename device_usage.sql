USE bellabeat;

/* 
Because I noticed a difference of 77 observations when I filtered out users with 0 activity, 
I want to see how often people actually used their device during the 1 month period. I will
use this script to classify users by their usage time.
*/

-- Classify users by Low use (1-10 days), Moderate use (11-20 days), and High use (21-31 days)
SELECT
	Id,
    days_used,
    CASE 
		WHEN days_used BETWEEN 21 AND 31 THEN 'High Use - 21-31 days'
        WHEN days_used BETWEEN 11 AND 20 THEN 'Moderate Use - 11-20 days'
        ELSE 'Low Use - < 10 days'
	END AS use_category
FROM (
	SELECT
		DISTINCT(Id),
		COUNT(Id) OVER(PARTITION BY Id) as days_used
	FROM 
		daily_activity
	WHERE 
		TotalSteps > 0 
	ORDER BY days_used DESC, Id
) a;

-- Setup table for bubble chart
SELECT
	use_category,
    num_of_users,
    num_of_users/SUM(num_of_users) OVER () as percent_of_users
FROM (
	SELECT
		use_category,
		COUNT(Id) as num_of_users
	FROM device_use_percentage
	GROUP BY use_category
    ) a;

