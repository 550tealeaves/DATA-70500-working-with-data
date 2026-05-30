/*This is like head in Python - helps see the col */
SELECT *
FROM tx_deathrow
LIMIT 3;

/*SELECT block specifies which col to output. Separate cols w/ comma*/
SELECT First_Name, Last_Name
FROM tx_deathrow
LIMIT 4;

SELECT Age_at_Execution
FROM tx_deathrow
LIMIT 10;

/*Arithmetic operations - don't need FROM block if not referencing dataset*/
/*-Produces crosstab w/ the math statements as headers & results as rows*/
SELECT 50+2, 51*2, 52/2, 53-2;

/*Returns 0. 1=True, 0=False*/
SELECT 0 AND (0 OR 1);

/*WHERE block - filters based on condition*/
SELECT First_Name, Last_Name, Age_at_Execution
FROM tx_deathrow
WHERE Age_at_Execution <= 25;

/*returns 1 result - Karla Tucker*/
SELECT First_Name, Last_Name
FROM tx_deathrow
WHERE Execution = 145;

/*Find the first and last names and ages (ex_age) of inmates 25 or younger at time of execution.*/
/*Returns 6 rows*/
SELECT First_Name, Last_Name
FROM tx_deathrow
WHERE Age_at_Execution <= 25;

/*LIKE - string operator that uses % & _ to match diff characters*/
/*Find Raymond Landry without having to spell either name exactly*/
SELECT First_Name, Last_Name
FROM tx_deathrow
WHERE First_Name LIKE '%mond%' /*name contains mond*/
AND Last_Name LIKE '%ndr%'; /*name contains andr*/


/*Find Napoleon Beazley's last statement.*/
/*Correct answer*/
SELECT Last_Statement
FROM tx_deathrow
WHERE First_Name = 'Napoleon'
AND Last_Name = 'Beazley';

/*Also correct using Like*/
SELECT First_Name, Last_Name, Last_Statement
from tx_deathrow
WHERE First_Name LIKE '%leon%'
AND Last_Name LIKE '%az%';

/*Just the last statement w/ LIKE*/
SELECT Last_Statement
from tx_deathrow
WHERE First_Name = 'Napoleon'
AND Last_Name LIKE '%az%';

/*2 #s needed to calculate proportion*/
/*Numerator - # of executions w/ claims of innocence
Denominator - Total executions
Since numerator and denominator need info from multiple rows  = need aggregate function
Aggregate - Combine multiple elements into a whole
Aggregate functions - Combines multiple rows of data into 1 number*/

/*COUNT function - Returns # of non-null rows in col
*/
/*Provide # of innmates w/ a last name*/
SELECT COUNT(Last_Statement)
FROM tx_deathrow;

/*NULL - intriniscally tied to COUNT function
Empty entry - NOT an empty string '' OR 0
Use IS NULL or IS NOT NULL to check for nulls*/
SELECT (0 IS NOT NULL) AND (' ' IS NOT NULL); /*returns 1= True*/

/*Total # of executions that are not null*/
SELECT COUNT(Execution)
FROM tx_deathrow
WHERE Execution IS NOT NULL;

/*Variations on COUNT
USE COUNT(*) to find length of table if none of the columns are null free
This works b/c tables shouldn't have rows that are completely null
Returns 553*/
SELECT COUNT(*)
FROM tx_deathrow;

/*SUBSETS*/
/*Count # of executions from Harris County - answer is 128*/
SELECT COUNT(*)
FROM tx_deathrow
WHERE County = 'Harris';

/*To find total in multiple counties, use CASE WHEN block, which acts like IF/ELSE*/
/*Total executions in Harris and Bexar county - Harris=128, Bexar=46*/
/*CASE WHEN County='Harris' THEN 1 ELSE 0 END - If county is Harris, then set to 1.
If county is NOT Harris - then 0 - add all the 1s at the end to get sum */
SELECT 
	SUM(CASE WHEN County = 'Harris' THEN 1 
		ELSE 0 END),
	SUM(CASE WHEN County = 'Bexar' THEN 1
		ELSE 0 END)
FROM tx_deathrow;

/*Find # of innmates >50y/o at time of execution - Answer is 68*/
SELECT COUNT(*)
FROM tx_deathrow
WHERE Age_at_Execution > 50;

/*Find # of innmates >50y/0 at time of execution. Find total executions who were not white */
SELECT
	SUM(CASE WHEN Age_at_Execution > 50 THEN 1
		ELSE 0 END),
	SUM (CASE WHEN Race != 'White' THEN 1
		ELSE 0 END)
FROM tx_deathrow;

/*Find the number of inmates who have declined to give a last statement. - Answer = 110*/
/*With a WHERE block*/
SELECT COUNT(*)
FROM tx_deathrow
WHERE Last_Statement IS NULL;

/*With a COUNT and CASE WHEN block*/
SELECT
	COUNT(CASE WHEN Last_Statement IS NULL THEN 1
			ELSE NULL END)
FROM tx_deathrow;


/*With a SUM and CASE WHEN block*/
SELECT
	SUM(CASE WHEN Last_Statement IS NULL THEN 1
			ELSE 0 END)
FROM tx_deathrow;


/*With two COUNT functions*/
SELECT
	COUNT(*) - COUNT(Last_Statement)
FROM tx_deathrow;

/*MIN, MAX, & AVG*/
/*Find min, max, & avg age of inmates at execution*/
/* Min=24, Max=67, Avg= 39.5*/
SELECT
	MIN(Age_at_Execution),
	MAX(Age_at_Execution),
	AVG(Age_at_Execution)
FROM tx_deathrow;

/*round avg age to 1 decimal place*/
SELECT
	MIN(Age_at_Execution),
	MAX(Age_at_Execution),
	ROUND(AVG(Age_at_Execution),1)
FROM tx_deathrow;

/*Find avg length of last statements*/
/*Answer - 537,487584650113 */
SELECT AVG(length(Last_Statement))
FROM tx_deathrow;

/*List all unique counties sans duplication*/
/*92 unique counties*/
SELECT DISTINCT County
FROM tx_deathrow;

/*STRANGE QUERY*/
/*select first name - returns multiple rows*/
SELECT First_Name
FROM tx_deathrow;

/*Returns 1 entry about length of table*/
SELECT COUNT(*)
FROM tx_deathrow;

/*Seems contradictory - does it return multiple rows or 1 entry*/
/*Answer - returns 1st name of last entry in table*/
SELECT First_Name, COUNT(*)
FROM tx_deathrow;

/*Find the proportion of inmates with claims of innocence in their last statements.*/
/*To do decimal division, ensure that one of the numbers is a decimal by multiplying it by 1.0. 
Use LIKE '%innocent%' to find claims of innocence.
Answer is 0.056*/
/*CASE WHEN Last_Statement LIKE '%innocent%' THEN 1 ELSE NULL END
IF last statement contains "innocent" at any position, then set to 1. if not then set to NULL
COUNT all of that and divide it by the total count of 553 & multiply by 1.0*/

SELECT 
	1.0 * COUNT(CASE WHEN Last_Statement LIKE '%innocent%'
				THEN 1 ELSE NULL END) / COUNT(*)
FROM tx_deathrow;

/*Ch 3 THE LONG TAIL
Small # of samples that occur many times
Plot them results in arch with curve right of center of mass, resembling a tail
Tail shows outliers that you might investigate
For this dataset, long tail = few counties that perform lots of executions
Shape of tables reveals what operations must be performed
Can't use the aggregations from chap 2 because they would result in only 1 row 
when we want 1 row per county

GROUP BY
- Comes after WHERE block
- Splits data and applies aggregate functions w/in each group = 1 row per group

Find execution counts per county - ANSWER returns 92 rows*/
SELECT
	county,
	COUNT(*) AS county_executions
FROM tx_deathrow
GROUP BY county;

/*Count executions w/ & w/o last statements. Organize by county. 1=TRUE, 0=FALSE
ANSWER - 110 have no last statement, 443 have last statement*/
SELECT
	Last_Statement IS NOT NULL AS has_last_statement,
	COUNT(*)
FROM tx_deathrow
GROUP BY has_last_statement;

/*The HAVING block
- Used if you want to filter on the result of the grouping and aggregation*/

/*Count the number of inmates aged 50 or older that were executed in each county*/
/*Using WHERE block*/
SELECT
	County, COUNT(*)
FROM tx_deathrow
WHERE Age_at_Execution >= 50
GROUP BY County;

SELECT
	COUNT(CASE WHEN Age_at_Execution >= 50 THEN 1
		ELSE 0 END)
FROM tx_deathrow;

/*List the counties in which more than 2 inmates aged 50 or older have been executed.
This builds on the previous exercise. 
We need an additional filter—one that uses the result of the aggregation. 
This means it cannot exist in the WHERE block because those filters are run before aggregation. 
Look up the HAVING block. You can think of it as a post-aggregation WHERE block.*/
SELECT
	County
FROM tx_deathrow
WHERE Age_at_Execution >= 50
GROUP BY County
HAVING COUNT(*) > 2;

/*List the counties & totals of those w/ more than 2 executions*/
SELECT
	County, COUNT(*)
FROM tx_deathrow
WHERE Age_at_Execution >= 50
GROUP BY County
HAVING COUNT(*) > 2;

/*query finds the number of inmates from each county and 10 year age range.*/
SELECT
	County,
  Age_at_Execution/10 AS decade_age,
  COUNT(*)
FROM tx_deathrow
GROUP BY County, decade_age

/*List all the distinct counties in the dataset.
We did this in the previous chapter using the SELECT DISTINCT command. 
This time, stick with vanilla SELECT and use GROUP BY.*/
SELECT DISTINCT(County)
FROM tx_deathrow
GROUP BY County;

/*NESTED QUERIES*/
-- SELECT 
-- 	County, PERCENT_COUNT(*)
-- FROM tx_deathrow
-- GROUP BY County;
/*Percentage doesn't exist as a metric b/c function needs to aggregate both w/in groups (for numerator)
and throughout dataset (to get denominator)
Require 2 diff queries - 1st that aggregates w/ GROUP BY & 2nd that aggregates w/o = NESTING*/

/*Find the first and last name of the inmate with the longest last statement (by character count).
Write in a suitable query to nest in <length-of-longest-last-statement>.*/
SELECT first_name, last_name
FROM tx_deathrow
WHERE LENGTH(last_statement) =
    (SELECT MAX(LENGTH(Last_Statement))  /*2nd query must have SELECT & FROM*/
	FROM tx_deathrow)
	
/*Nesting is needed b/c for WHERE clause, while computer inspects a row to decide if its last 
statement, it can't look outside to determine max length across full dataset.
Must find the max length separately and feed it into clause*/

/*Insert the <count-of-all-rows> query to find the percentage of executions from each county.
100.0 is a decimal so we can get decimal percentages.*/
/*The second query must have SELECT & FROM with dataset - list dataset 2x here*/
SELECT 
	County,
	100.0 * COUNT(*) / (SELECT COUNT(*) FROM tx_deathrow)
	AS percentage
FROM tx_deathrow
GROUP BY County
ORDER BY percentage DESC;

/*Round above to nearest hundredths place - add ROUND and 2*/
SELECT 
	County,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM tx_deathrow), 2)
	AS percentage
FROM tx_deathrow
GROUP BY County
ORDER BY percentage DESC;
