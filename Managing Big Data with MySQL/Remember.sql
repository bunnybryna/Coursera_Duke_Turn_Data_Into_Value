-- review basic information for table( field, type, ...) 
%sql SHOW columns FROM dogs

%sql DESCRIBE exam_answers

-- 10 rows will be returned, starting at Row 6
SELECT breed
FROM dogs LIMIT 10 OFFSET 5;

-- same as, note offet first, limit second
SELECT breed
FROM dogs LIMIT 5, 10

-- DATE - format YYYY-MM-DD
-- DATETIME - format: YYYY-MM-DD HH:MI:SS
-- TIMESTAMP - format: YYYY-MM-DD HH:MI:SS
-- YEAR - format YYYY or YY
SELECT dog_guid, created_at
FROM complete_tests
WHERE DAYNAME(created_at)="Tuesday"

SELECT dog_guid, created_at
FROM complete_tests
WHERE DAY(created_at) > 15

-- after Feb 4, 2014
SELECT dog_guid, created_at
FROM complete_tests
WHERE created_at > '2014-02-04'

-- get the 5 customer-dog pairs who spent the greatest median amount of time between their Dognition tests in seconds
SELECT DISTINCT user_guid, (median_ITI_minutes * 60) AS median_ITI_sec
FROM dogs 
ORDER BY median_ITI_sec DESC
LIMIT 5

-- export query results to a text file
breed_list = %sql SELECT DISTINCT breed FROM dogs ORDER BY breed
breed_list.csv('breed_list.csv')

SELECT DISTINCT breed,
REPLACE(breed,'-','') AS breed_fixed
FROM dogs
ORDER BY breed_fixed

--https://www.w3resource.com/mysql/string-functions/mysql-trim-function.php
SELECT DISTINCT breed, TRIM(LEADING '-' FROM breed) AS breed_fixed
FROM dogs
ORDER BY breed_fixed

--How would you query how much time it took to complete each test provided in the exam_answers table, in minutes? 
--Title the column that represents this data "Duration." 
%%sql
SELECT TIMESTAMPDIFF(minute, start_time, end_time) AS Duration
FROM exam_answers
LIMIT 200

--difference between these two queries
%%sql
SELECT test_name, MONTH(created_at) AS Month, COUNT(created_at) AS Num_Completed_Tests
FROM complete_tests
GROUP BY MONTH(created_at), test_name

%%sql
SELECT test_name, MONTH(created_at) AS Month, COUNT(created_at) AS Num_Completed_Tests
FROM complete_tests
GROUP BY test_name, MONTH(created_at)

--Question 4: Write a query that outputs the average number of tests completed and average mean inter-test-interval for every breed type, sorted by the average number of completed tests in descending order (popular hybrid should be the first row in your output).
%%sql
SELECT breed_type, AVG(total_tests_completed) AS AvgTotal, AVG(mean_iti_minutes) AS AvgMeanITI
FROM dogs
GROUP BY breed_type
ORDER BY AVG(total_tests_completed) DESC;

--"every non-aggregated field that is listed in the SELECT list must be listed in the GROUP BY list"
-- the query below is wrong
SELECT breed_type, COUNT(DISTINCT dog_guid) AS NumDogs, weight
FROM dogs
GROUP BY breed_type;