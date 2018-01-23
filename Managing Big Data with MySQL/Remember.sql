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

%%sql
SELECT d.dog_guid AS DogID, d.user_guid AS UserID, AVG(r.rating) AS AvgRating, COUNT(r.rating) AS NumRatings, d.breed, d.breed_group, d.breed_group
FROM dogs d, reviews r
WHERE d.dog_guid = r.dog_guid AND d.user_guid = r.user_guid
GROUP BY UserID, DogId, d.breed, d.breed_group, d.breed_type
HAVING NumRatings >= 10
ORDER BY AvgRating DESC
LIMIT 200

--How would you extract the user_guid, dog_guid, breed, breed_type, and breed_group for all animals who completed the "Yawn Warm-up" game (you should get 20,845 rows if you join on dog_guid only)?
-- no need to GROUP BY UserID, DogID, d.breed, d.breed_group, d.breed_type
-- since it's not asking for COUNT aggregated function
%%sql
SELECT d.dog_guid AS DogID, d.user_guid AS UserID, d.breed, d.breed_group, d.breed_type
FROM dogs d, complete_tests c
WHERE d.dog_guid=c.dog_guid AND test_name = "Yawn Warm-up"

SELECT d.dog_guid AS DogID, d.user_guid AS UserID, d.breed, d.breed_group, d.breed_type
FROM dogs d
JOIN complete_tests c
ON d.dog_guid=c.dog_guid 
WHERE test_name = "Yawn Warm-up"

--Question 5: How would you extract the user_guid, dog_guid, breed, breed_type, and breed_group for all animals who completed the "Yawn Warm-up" game
--use the dogs table to link the complete_tests and users table
--instead of WHERE d.dog_guid=c.dog_guid AND c.user_guid=u.user_guid
SELECT d.user_guid AS UserID, u.state, u.zip, d.dog_guid AS DogID, d.breed, d.breed_type, d.breed_group
FROM dogs d, complete_tests c, users u
WHERE d.dog_guid=c.dog_guid 
   AND d.user_guid=u.user_guid
   AND c.test_name="Yawn Warm-up";
   
--Question 6: How would you extract the user_guid, membership_type, and dog_guid of all the golden retrievers who completed at least 1 Dognition test (you should get 711 rows)?**   
%%sql
SELECT DISTINCT d.user_guid AS UserID, u.membership_type, d.dog_guid AS DogID, d.breed, d.total_tests_completed
FROM dogs d, complete_tests c, users u
WHERE d.dog_guid = c.dog_guid
AND d.user_guid = u.user_guid
AND d.breed = "Golden Retriever"
AND d.total_tests_completed >= 1


--Question 7: How many unique Golden Retrievers who live in North Carolina are there in the Dognition database (you should get 30)?
%%sql
SELECT DISTINCT d.dog_guid AS DogID, u.state, d.user_guid AS UserID, d.breed
FROM dogs d, users u
WHERE d.user_guid = u.user_guid
AND d.breed = "Golden Retriever"
AND u.state = "NC"

-- or
%%sql
SELECT u.state AS state, d.breed AS breed, COUNT(DISTINCT d.dog_guid)
FROM users u, dogs d
WHERE d.user_guid=u.user_guid AND breed="Golden Retriever"
GROUP BY state
HAVING state="NC";

--or, but try to minimize the group by items, time-consuming
%%sql
SELECT COUNT(DISTINCT d.dog_guid), u.state, d.breed
FROM dogs d, users u
WHERE d.user_guid = u.user_guid
GROUP BY u.state, d.breed
HAVING u.state = "NC" AND d.breed = "Golden Retriever"

--Question 8: How many unique customers within each membership type provided reviews
%%sql
SELECT COUNT(DISTINCT d.user_guid), u.membership_type, 
FROM users, reviews r
WHERE u.user_guid = r.user_guid
AND r.rating IS NOT NULL
GROUP BY u.membership_type

--Question 9: For which 3 dog breeds do we have the greatest amount of site_activity data, (as defined by non-NULL values in script_detail_id)(your answers should be "Mixed", "Labrador Retriever", and "Labrador Retriever-Golden Retriever Mix"?
SELECT COUNT(DISTINCT script_detail_id) activity, d.breed
FROM dogs d, site_activities s
WHERE d.dog_guid = s.dog_guid
AND s.script_detail_id IS NOT NULL
GROUP BY d.breed 
ORDER BY activity DESC
LIMIT 3

--note that LEFT JOIN  should GROUP BY d.dog_guid
--this way, all of the dog_guids that were in the dogs table but not in the completed_tests table got rolled up into one row of your output where completed_tests.dogs_guid = NULL
%%sql
SELECT COUNT(DISTINCT c.test_name), d.dog_guid AS DogID, d.user_guid AS UserID
FROM dogs d
LEFT JOIN complete_tests c
ON d.dog_guid = c.dog_guid 
GROUP BY c.dog_guid

--The result of your COUNT DISTINCT clause should be 17,986 which is one row less than the number of rows you retrieved from your query in Question 4. That's because COUNT DISTINCT does NOT count NULL values, while SELECT/GROUP BY clauses roll up NULL values into one group. 
%%sql
SELECT COUNT(DISTINCT dog_guid)
FROM complete_tests
--If you want to infer the number of distinct entries from the results of a query using joins and GROUP BY clauses, remember to include an "IS NOT NULL" clause to ensure you are not counting NULL values.


-- full outer join https://www.xaprb.com/blog/2006/05/26/how-to-write-full-outer-join-in-mysql/

%%sql
SELECT COUNT(DISTINCT u.user_guid)
FROM users u
LEFT JOIN dogs d
ON u.user_guid = d.user_guid
WHERE u.user_guid IS NOT NULL

%%sql
SELECT s.dog_guid, COUNT(*) AS NumEntries
FROM site_activities s
LEFT JOIN dogs d
ON d.dog_guid = s.dog_guid
WHERE d.dog_guid IS NULL AND s.dog_guid IS NOT NULL
GROUP BY s.dog_guid