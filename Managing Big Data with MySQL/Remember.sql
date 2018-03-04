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

-- subquery 1) "On the fly calculations"
SELECT *
FROM exam_answers 
-- same with WHERE TIMESTAMPDIFF(minute,start_time,end_time) >  9934
WHERE TIMESTAMPDIFF(minute,start_time,end_time) > 
(SELECT AVG(TIMESTAMPDIFF(minute, start_time, end_time)) AS durations
FROM exam_answers
WHERE TIMESTAMPDIFF(minute, start_time, end_time) > 0 AND test_name = "Yawn Warm-Up")

--2) Testing membership
-- EXISTS
SELECT DISTINCT u.user_guid AS uUserID
FROM users u
WHERE EXISTS (SELECT d.user_guid
              FROM dogs d 
              WHERE u.user_guid =d.user_guid);
-- same as 
SELECT DISTINCT u.user_guid AS uUserID
FROM users u
WHERE EXISTS (SELECT *
              FROM dogs d 
              WHERE u.user_guid =d.user_guid);
-- same as an inner join with GROUP BY query

--3) Accurate logical representations of desired output and Derived Tables
--"exploding rows" phenomenon due to duplicate rows
SELECT u.user_guid AS uUserID, d.user_guid AS dUserID, count(*) AS numrows
FROM users u LEFT JOIN dogs d
   ON u.user_guid=d.user_guid
GROUP BY u.user_guid
ORDER BY numrows DESC


--Queries that include subqueries always run the innermost subquery first, 
--and then run subsequent queries sequentially in order from the innermost query to the outermost query.
--Remember to reference the temporary table alias in the ON, GROUP BY, and SELECT clauses.
SELECT DistinctUUsersID.user_guid AS uUserID, d.user_guid AS dUserID, count(*) AS numrows
FROM (SELECT DISTINCT u.user_guid 
      FROM users u) AS DistinctUUsersID 
LEFT JOIN dogs d
   ON DistinctUUsersID.user_guid=d.user_guid
GROUP BY DistinctUUsersID.user_guid
ORDER BY numrows DESC

%%sql
SELECT DISTINCT d.dog_guid, d.breed_group, u.state, u.zip
FROM dogs d, users u
WHERE d.breed_group IN ('Working', 'Sporting', 'Herding') AND d.user_guid = u.user_guid

--Use a NOT EXISTS clause to examine all the users in the dogs table that are not in the users table
%%sql
SELECT d.user_guid, d.dog_guid
FROM dogs d
WHERE NOT EXISTS (SELECT DISTINCT u.user_guid
                 FROM users u
                 WHERE u.user_guid = d.user_guid)
                 
SELECT DistinctUUsersID.user_guid AS uUserID, d.user_guid AS dUserID, count(*) AS numrows
FROM (SELECT DISTINCT u.user_guid 
      FROM users u) AS DistinctUUsersID 
LEFT JOIN dogs d
  ON DistinctUUsersID.user_guid=d.user_guid
  WHERE u.user_guid='ce7b75bc-7144-11e5-ba71-058fbc01cf0b'
GROUP BY DistinctUUsersID.user_guid
ORDER BY numrows DESC;

--IF expressions
--IF([your conditions],[value outputted if conditions are met],[value outputted if conditions are NOT met])
SELECT created_at, IF(created_at<'2014-06-01','early_user','late_user') AS user_type
FROM users

--
SELECT IF(cleaned_users.first_account<'2014-06-01','early_user','late_user') AS user_type,
       COUNT(cleaned_users.first_account)
FROM (SELECT user_guid, MIN(created_at) AS first_account 
      FROM users
      GROUP BY user_guid) AS cleaned_users
GROUP BY user_type

-- this is wrong, need to put group by at last
SELECT IF(cleaned_users.country = 'US', 'In US', 'Outside US')AS user_loacation, COUNT(cleaned_users.user_guid) AS num_guids
FROM 
(SELECT DISTINCT user_guid, country
FROM users
WHERE country IS NOT NULL AND user_guid IS NOT NULL) AS cleaned_users
GROUP BY user_loacation

-- nested IF
IF (cleaned_users.country = 'US', 'In US', IF(cleaned_users.country = 'N/A', 'Not Applicable', 'Outside US'))

-- CASE
--Make sure to include the word END at the end of the expression
--CASE expressions do not require parentheses
--ELSE expressions are optional
--If an ELSE expression is omitted, NULL values will be outputted for all rows that do not meet any of the conditions stated explicitly in the expression
--CASE expressions can be used anywhere in a SQL statement, including in GROUP BY, HAVING, and ORDER BY clauses or the SELECT column list.
SELECT CASE WHEN cleaned_users.country="US" THEN "In US"
            WHEN cleaned_users.country="N/A" THEN "Not Applicable"
            ELSE "Outside US"
            END AS US_user, 
      count(cleaned_users.user_guid)   
FROM (SELECT DISTINCT user_guid, country 
      FROM users
      WHERE country IS NOT NULL) AS cleaned_users
GROUP BY US_user

%%sql
SELECT CASE cleaned_users.country 
        WHEN 'US' THEN 'In US'
        WHEN 'N/A' THEN 'Not Applicable'
        ELSE 'Outside US'
        END AS US_user,
        COUNT(cleaned_users.user_guid)
FROM (SELECT DISTINCT user_guid, country
      FROM users
      WHERE country IS NOT NULL) AS cleaned_users
GROUP BY US_user

--Question 3: Write a query using a CASE statement that outputs 3 columns: dog_guid, dog_fixed, and a third column that reads "neutered" every time there is a 1 in the "dog_fixed" column of dogs, "not neutered" every time there is a value of 0 in the "dog_fixed" column of dogs, and "NULL" every time there is a value of anything else in the "dog_fixed" column. Limit your results for troubleshooting purposes.

SELECT cleaned_dogs.dog_guid, cleaned_dogs.dog_fixed , 
        CASE cleaned_dogs.dog_fixed 
        WHEN 1 THEN 'neutered'
        WHEN 0 THEN 'not neutered'
        ELSE 'NULL'
        END AS 'if fixed'
FROM (SELECT DISTINCT dog_guid, dog_fixed
        FROM dogs 
        WHERE dog_guid IS NOT NULL) AS cleaned_dogs

SELECT cleaned_dogs.dog_guid, cleaned_dogs.exclude, 
        CASE cleaned_dogs.exclude 
        WHEN 1 THEN 'exclude'
        ELSE 'keep'
        END AS 'if excluded'
FROM (SELECT DISTINCT dog_guid, exclude
        FROM dogs 
        WHERE dog_guid IS NOT NULL) AS cleaned_dogs
-- or 
SELECT cleaned_dogs.dog_guid, cleaned_dogs.exclude, 
        IF (cleaned_dogs.exclude = 1, 'exclude', 'keep') AS 'if excluded'
FROM (SELECT DISTINCT dog_guid, exclude
        FROM dogs 
        WHERE dog_guid IS NOT NULL) AS cleaned_dogs

%%sql
SELECT dog_guid, weight, 
        CASE WHEN (weight >= 1 AND weight <= 10) THEN 'very small' 
             WHEN (weight > 10 AND weight <= 30) THEN 'small'
             WHEN (weight > 30 AND weight <= 50) THEN 'medium'
             WHEN (weight > 50 AND weight <= 85) THEN 'large'
             WHEN (weight > 85 ) THEN 'very large'
        ELSE 'NULL'
        END AS weight_grouped
FROM dogs 
LIMIT 20

-- Evaluation order NOT > AND > OR

--1,2,3 generate different results 
--1
%%sql
SELECT COUNT(DISTINCT dog_guid), 
CASE WHEN breed_group = 'Sporting' OR breed_group = 'Herding' AND exclude != 1 THEN "group 1"
ELSE "everything else"
END AS groups
FROM dogs
GROUP BY groups

--2
%%sql
SELECT COUNT(DISTINCT dog_guid),
CASE WHEN exclude != 1 AND breed_group = 'Sporting' OR breed_group = 'Herding' THEN "group 1"
ELSE "everything else"
END AS group_name
FROM dogs
GROUP BY group_name

--3
SELECT COUNT(DISTINCT dog_guid), 
CASE WHEN exclude!='1' AND (breed_group='Sporting' OR breed_group='Herding') THEN "group 1"
     ELSE "everything else"
     END AS group_name
FROM dogs
GROUP BY group_name

-- Question 10: For each dog_guid, output its dog_guid, breed_type, number of completed tests, and use an IF statement to include an extra column that reads "Pure_Breed" whenever breed_type equals 'Pure Breed" and "Not_Pure_Breed" whenever breed_type equals anything else. LIMIT your output to 50 rows for troubleshooting. HINT: you will need to use a join to complete this query.
SELECT dog_guid, breed_type, total_tests_completed, IF (breed_type = 'Pure_Breed', 'Pure Breed', 'Not_Pure_Breed') AS pure
FROM dogs

-- or JOIN dogs and completed_tests 
SELECT d.dog_guid, d.breed_type, COUNT(c.created_at) AS numtests,
IF (d.breed_type = 'Pure Breed', 'pure_breed', 'not_pure_breed') AS pure_breed
FROM dogs d, complete_tests c 
WHERE d.dog_guid = c.dog_guid 
GROUP BY d.dog_guid, d.breed_type, pure_breed

--Write a query that uses a CASE statement to report the number of unique user_guids associated with customers who live in the United States and who are in the following groups of states:
Group 1: New York (abbreviated "NY") or New Jersey (abbreviated "NJ")
Group 2: North Carolina (abbreviated "NC") or South Carolina (abbreviated "SC")
Group 3: California (abbreviated "CA")
Group 4: All other states with non-null values
You should find 898 unique user_guids in Group1.

%%sql
SELECT CASE u.state 
        WHEN ('NY' OR 'NJ') THEN 'group 1' 
        WHEN ('NC' OR 'SC') THEN 'group 2'
        WHEN 'CA' THEN 'group 3'
        ELSE 'group 4'
        END AS group_name, COUNT(DISTINCT u.user_guid)
FROM users u 
WHERE country = 'US' AND state IS NOT NULL
GROUP BY group_name
 
 --Question 11
 %%sql
SELECT COUNT(DISTINCT u.user_guid), 
    CASE  
        WHEN (state='NY' OR state='NJ') THEN 'group 1' 
        WHEN (state='NC' OR state='SC') THEN 'group 2'
        WHEN state='CA' THEN 'group 3'
        ELSE 'group 4'
        END AS group_name 
FROM users u 
WHERE country = 'US' AND state IS NOT NULL
GROUP BY group_name

--Question 12: Write a query that allows you to determine how many unique dog_guids are associated with dogs who are DNA tested and have either stargazer or socialite personality dimensions. Your answer should be 70.
%%sql
SELECT COUNT(DISTINCT dog_guid)
FROM dogs
WHERE dna_tested = 1 AND ( dimension = 'stargazer' OR dimension = 'socialite')

--write a query that will output the average number of tests completed by unique dogs in each Dognition personality dimension. Choose either the query in Question 2 or 3 to serve as an inner query in your main query. If you have trouble, make sure you use the appropriate aliases in your GROUP BY and SELECT statements.

%%sql
SELECT dimension, AVG(numtests_per_dog.numtests) AS avg_tests_complete FROM
(
SELECT d.dog_guid, d.dimension, COUNT(c.test_name) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid = c.dog_guid
GROUP BY d.dog_guid) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension

%%sql
SELECT d.breed, d.weight, d.exclude, MIN(c.created_at) AS first_test, MAX(c.created_at) AS last_test, COUNT(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid = c.dog_guid 
WHERE d.dimension = ""
GROUP BY d.dog_guid 

SELECT d.breed, d.weight, d.exclude, MIN(c.created_at) AS first_test,
MAX(c.created_at) AS last_test,count(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.dimension=””
GROUP BY d.dog_guid;


%%sql
SELECT dimension, AVG(numtests_per_dog.numtests) AS avg_tests_complete FROM
(
SELECT d.dog_guid, d.dimension, COUNT(c.test_name) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid = c.dog_guid
GROUP BY d.dog_guid
WHERE d.dimension IS NOT NULL AND d.dimension != ""
) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension


--7. Rewrite the query in Question 4 to exclude DogIDs with (1) non-NULL empty strings in the dimension column, (2) NULL values in the dimension column, and (3) values of "1" in the exclude column. NOTES AND HINTS: You cannot use a clause that says d.exclude does not equal 1 to remove rows that have exclude flags, because Dognition clarified that both NULL values and 0 values in the "exclude" column are valid data. 
%%sql
SELECT dimension, COUNT(numtests_per_dog.numtests) AS avg_tests_complete FROM
(
SELECT d.dog_guid, d.dimension, d.exclude, COUNT(c.test_name) AS numtests
FROM dogs d 
JOIN complete_tests c
ON d.dog_guid = c.dog_guid
WHERE d.dimension IS NOT NULL AND d.dimension != "" AND (d.exclude = 0 OR d.exclude IS NULL)
GROUP BY d.dog_guid
) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension

SELECT d.breed, d.weight, d.exclude, MIN(c.created_at) AS first_test,
MAX(c.created_at) AS last_test,count(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.breed_group IS NULL OR d.breed_group = 'None'
GROUP BY d.dog_guid;

--Question 10: Adapt the query in Question 7 to examine the relationship between breed_group and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 1774 DogIDs in the Herding breed group.
%%sql
SELECT breed_group, AVG(numtests_per_dog.numtests) AS avg_tests_completed, COUNT(DISTINCT dogID)
FROM( 
SELECT d.dog_guid AS dogID, d.breed_group, COUNT(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL OR d.exclude = 0
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.breed_group

--Question 13: Adapt the query in Question 7 to examine the relationship between breed_type and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 8865 DogIDs in the Pure Breed group.
%%sql
SELECT breed_group, AVG(numtests_per_dog.numtests) AS avg_tests_completed, COUNT(DISTINCT dogID)
FROM( 
SELECT d.dog_guid AS dogID, d.breed_group, COUNT(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude IS NULL OR d.exclude = 0
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.breed_group

%%sql
SELECT d.dog_guid AS dogID, d.breed_type AS breed_type,
CASE d.breed_type WHEN 'Pure Breed' THEN 'pure_breed'
                  ELSE 'not_pure_breed'
                  END AS if_pure_breed,
COUNT(c.created_at) AS numtests
FROM dogs d, complete_tests c
WHERE d.dog_guid=c.dog_guid 
GROUP BY dogID
LIMIT 20

--Question 15: Adapt your queries from Questions 7 and 14 to examine the relationship between breed_type and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs. Your results should return 8336 DogIDs in the Not_Pure_Breed group.
%%sql
SELECT numtests_per_dog.if_pure_breed, AVG(numtests_per_dog.numtests) AS avg_tests_completed, COUNT(DISTINCT dogID)
FROM( 
SELECT d.dog_guid AS dogID, d.breed_type AS breed_type,
CASE d.breed_type WHEN 'Pure Breed' THEN 'pure_breed'
                  ELSE 'not_pure_breed'
                  END AS if_pure_breed,
COUNT(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude is NULL OR d.exclude = 0 
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.if_pure_breed

--Question 16: Adapt your query from Question 15 to examine the relationship between breed_type, whether or not a dog was neutered (indicated in the dog_fixed field), and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs. There are DogIDs with null values in the dog_fixed column, so your results should have 6 rows, and the average number of tests completed by non-pure-breeds who are neutered is 10.5681.

%%sql
SELECT numtests_per_dog.if_pure_breed AS pure_breed, neutered, AVG(numtests_per_dog.numtests) AS avg_tests_completed, COUNT(DISTINCT dogID)
FROM( 
SELECT d.dog_guid AS dogID, d.breed_type AS breed_type, d.dog_fixed AS neutered, 
CASE d.breed_type WHEN 'Pure Breed' THEN 'pure_breed'
                  ELSE 'not_pure_breed'
                  END AS if_pure_breed,
COUNT(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.exclude is NULL OR d.exclude = 0 
GROUP BY dogID) AS numtests_per_dog
GROUP BY pure_breed, neutered 

--it is good practice to include standard deviation columns with your outputs so that you have an idea whether the average values outputted by your queries are trustworthy

--Question 17: Adapt your query from Question 7 to include a column with the standard deviation for the number of tests completed by each Dognition personality dimension.
%%sql
SELECT dimension, AVG(numtests) AS avg_tests_completed,
COUNT(DISTINCT dogID), STDDEV(numtests)
FROM( SELECT d.dog_guid AS dogID, d.dimension AS dimension, count(c.created_at)
AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE (dimension IS NOT NULL AND dimension!='') AND (d.exclude IS NULL
OR d.exclude=0)
GROUP BY dogID) AS numtests_per_dog
GROUP BY numtests_per_dog.dimension

SELECT d.breed_type AS breed_type, AVG(TIMESTAMPDIFF(minute, e.start_time,e.end_time)) AS AvgDuration, STDDEV(TIMESTAMPDIFF(minute, e.start_time, e.end_time)) AS StdDevDuration
FROM dogs d JOIN exam_answers e
ON d.dog_guid = e.dog_guid
WHERE TIMESTAMPDIFF(minute, e.start_time, e.end_time) > 0
GROUP BY breed_type
