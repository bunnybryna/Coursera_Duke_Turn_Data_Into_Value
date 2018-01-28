HELP TABLE skuinfo;
HELP COLUMN sku FROM skuinfo;

-- give the actual code written to create the table
SHOW TABLE skuinfo;

--Terdata uses TOP instead of LIMIT to restrict the length of a query output.
SELECT TOP 10 * FROM strinfo

SELECT TOP 10 * 
FROM strinfo
ORDER BY city ASC

-- retrieve 10 random
SELECT * 
FROM strinfo
SAMPLE 10

-- retrieve a random 10% of the rows
SELECT *
FROM strinfo
SAMPLE .10

--DISTINCT and TOP cannot be used together in Teradata
--Teradata will only accept single quotation marks
--Teradata will only accept “<>”
-- 48 rows
SELECT DISTINCT(PACKSIZE)
FROM skuinfo;

SELECT TOP 200 *
FROM SKSTINFO
WHERE COST > RETAIL;

-- use a date in the format of “YYYY-MM-DD”
SELECT TOP 200 *
FROM TRNSACT
WHERE SALEDATE > '2000-01-01' AND SALEDATE < '2005-12-31'

--What was the highest original price in the Dillard’s database of the item with SKU 3631365?
SELECT * 
FROM SKSTINFO_FIX
WHERE SKU = 3631365
ORDER BY RETAIL DESC;

--What is the color of the Liz Claiborne brand item with the highest SKU # in the Dillard’s database (the Liz Claiborne brand is abbreviated “LIZ CLAI” in the Dillard’s database)?
SELECT *
FROM SKUINFO
WHERE BRAND = 'LIZ CLAI'
ORDER BY SKU DESC

--What is the sku number of the item in the Dillard’s database that had the highest original sales price?
SELECT TOP 10 *
FROM SKSTINFO_FIX
ORDER BY RETAIL DESC;

--How many Dillard’s departments start with the letter “e”
SELECT *
FROM DEPTINFO
WHERE DEPTDESC LIKE 'E%';

--What was the date of the earliest sale in the database where the sale price of the item did not equal the original price of the item, and what was the largest margin (original price minus sale price) of an item sold on that earliest date?
SELECT TOP 5 *
FROM TRNSACT 
WHERE ORGPRICE <> SPRICE
ORDER BY SALEDATE; 

SELECT TOP 5 *
FROM TRNSACT
WHERE SALEDATE = '2004/08/01'
ORDER BY (ORGPRICE - SPRICE) DESC;

--What register number made the sale with the highest original price and highest sale price between the dates of August 1, 2004 and August 10, 2004? Make sure to sort by original price first and sale price second.

SELECT TOP 5 *
FROM TRNSACT
WHERE SALEDATE > '2004-08-01' AND SALEDATE < '2004-08-10'
ORDER BY ORGPRICE DESC, SPRICE DESC

--Which of the following brand names with the word/letters “liz” in them exist in the Dillard’s database? Select all that apply. Note that you will need more than a single correct selection to answer the question correctly.
SELECT BRAND
FROM SKUINFO
WHERE BRAND = 'CIVILIZE'

--What is the lowest store number of all the stores in the STORE_MSA table that are in the city of “little rock”,”memphis”, or “tulsa”?
SELECT *
FROM STRINFO
WHERE CITY = 'LITTLE ROCK' OR CITY ='MEMPHIS' OR CITY = 'TULSA'
ORDER BY STORE

-- error code 3504
SELECT sku, retail, cost, COUNT(sku)
FROM skstinfo
GROUP BY sku, retail, cost

-- or 
SELECT sku, COUNT(sku), AVG(retail), AVG(cost)
FROM skstinfo
GROUP BY sku

SELECT COUNT(DISTINCT st.sku)
FROM SKSTINFO st
JOIN SKUINFO sk
ON st.sku = sk.sku

--1564178
Database ua_dillards;
SELECT COUNT(DISTINCT sku)
FROM skuinfo

--760212
Database ua_dillards;
SELECT COUNT(DISTINCT sku)
FROM skstinfo

--714499
Database ua_dillards;
SELECT COUNT(DISTINCT sku)
FROM trnsact

Database ua_dillards;
SELECT COUNT(DISTINCT st.sku)
FROM SKSTINFO st 
JOIN SKUINFO sk
ON st.sku = sk.sku

--714499
Database ua_dillards;
SELECT COUNT(DISTINCT sk.sku)
FROM SKUINFO sk 
JOIN TRNSACT t
ON sk.sku = t.sku

--542513
Database ua_dillards;
SELECT COUNT(DISTINCT st.sku)
FROM SKSTINFO st 
JOIN TRNSACT t
ON st.sku = t.sku

--Use COUNT to determine how many instances there are of each sku associated with each store in theskstinfo table and the trnsact table?
SELECT SKSTINFO.sku, SKSTINFO.store
FROM SKSTINFO
JOIN TRNSACT
ON SKSTINFO.sku = TRNSACT.sku AND SKSTINFO.store = TRNSACT.store

-- strinfo 453, skstinfo 357, store_msa 333, trnsact 332
SELECT COUNT(DISTINCT st.store)
FROM SKSTINFO st 

-- of the rows in the trnsact table that are not in the skstinfo table
SELECT *
FROM TRNSACT
LEFT JOIN SKSTINFO
ON SKSTINFO.sku = TRNSACT.sku
WHERE SKSTINFO.sku IS NULL

-- How many skus are in the skstinfo table, but NOT in the skuinfo table?
SELECT COUNT(DISTINCT stsk.sku)
FROM skstinfo skst 
LEFT JOIN skuinfo sk
ON skst.sku = sk.sku 
WHERE sk.sku IS NULL 

--How many skus are in the skuinfo table, but NOT in the skstinfo table?
SELECT COUNT(DISTINCT sk.sku)
FROM skuinfo sk
LEFT JOIN skstinfo skst 
ON sk.sku = skst.sku
WHERE skst.sku IS NULL 

--cost=>skstinfo, average profit per day 1527903.46, AND register = 640=>profit per day from register 640 is $10,779.20
-- profit = (revenue - cost)/COUNT = (purchase - cost)/COUNT = SUM(t.amt - skstinfo.cost * t.quantity)/ COUNT() 

SELECT SUM(amt-(cost*quantity))/ COUNT(DISTINCT saledate) AS avg_sales

FROM trnsact t JOIN skstinfo si

ON t.sku=si.sku AND t.store=si.store

WHERE stype='P';

SELECT (SUM(TRNSACT.amt - SKSTINFOR.cost * TRNSACT.quantity)/COUNT(DISCOUNT TRNSACT.saledate) )AS averageProfit
FROM TRNSACT
JOIN SKSTINFO
ON SKSTINFO.sku = TRNSACT.sku AND SKSTINFO.store = TRNSACT.store
WHERE t.stype <> 'P'

SELECT SUM(t.amt - skst.cost * t.quantity)/COUNT(DISTINCT t.saledate)
FROM TRNSACT t
JOIN SKSTINFO skst
ON skst.sku = t.sku AND skst.store = t.store
WHERE t.stype = 'P' 

--Exercise 5: On what day was the total value (in $) of returned goods the greatest? On what day was the total number of individual returned items the greatest? 1212071.96 04/12/27
SELECT SUM(t.amt), t.saledate
FROM TRNSACT t
JOIN SKSTINFO skst
ON skst.sku = t.sku AND skst.store = t.store
GROUP BY t.saledate
WHERE t.stype = 'R'
ORDER BY 1 DESC

--Exercise 6: What is the maximum price paid for an item in our database? What is the minimum price paid for an item in our database
--6017 vs 0
SELECT MAX(t.amt), MIN(t.amt)
FROM TRNSACT t
WHERE t.stype = 'P'

--Exercise 7: How many departments have more than 100 brands associated with them, and what are their descriptions?
--60
SELECT d.dept, d.deptdesc, COUNT(sk.brand)
FROM DEPTINFO d 
JOIN SKUINFO sk 
ON d.dept = sk.dept
GROUP BY d.dept, d.deptdesc
HAVING COUNT(sk.brand) > 100

--Exercise 8: Write a query that retrieves the department descriptions of each of the skus in the skstinfo table.
--connect skstinfo and skuinfo first, then deptinfo
(DISTINCT)
SELECT skst.sku, d.deptdesc
FROM skstinfo skst
JOIN skuinfo sku
ON skst.sku = sku.sku
JOIN deptinfo d 
ON sku.dept = d.dept
WHERE sku.sku = 5020024

--Exercise 9: What department (with department description), brand, style, and color had the greatest total value of returned items?
--connect trnsact and skuinfo first, then deptinfo
--group by item(sku), dept 
SELECT SUM(t.amt), sk.sku, sk.dept, MAX(d.deptdesc), MAX(sk.brand), MAX(sk.style), MAX(sk.color), MAX(d.deptdesc)
FROM TRNSACT t
JOIN SKUINFO sk
ON t.sku = sk.sku 
JOIN DEPTINFO d 
ON d.dept = sk.dept
GROUP BY sk.dept, sk.sku 
WHERE t.stype = 'R'
ORDER BY SUM(t.amt) DESC

--or 
SELECT SUM(t.amt), sk.sku, sk.dept, d.deptdesc, sk.brand, sk.style, sk.color, d.deptdesc
FROM TRNSACT t
JOIN SKUINFO sk
ON t.sku = sk.sku 
JOIN DEPTINFO d 
ON d.dept = sk.dept
GROUP BY sk.dept, sk.sku, d.deptdesc, sk.brand, sk.style, sk.color, d.deptdesc
WHERE t.stype = 'R'
ORDER BY SUM(t.amt) DESC

--What department (with department description), brand, style, and color brought in the greatest total amount of sales?
--6350866.72 800
--81978.59  4407
--2410574.64  6400
--4992617.69 2200
DATABASE ua_dillards;
SELECT SUM(t.amt), sk.sku, sk.dept, MAX(d.deptdesc), MAX(sk.brand), MAX(sk.style), MAX(sk.color), MAX(d.deptdesc)
FROM TRNSACT t
JOIN SKUINFO sk
ON t.sku = sk.sku 
JOIN DEPTINFO d 
ON d.dept = sk.dept
GROUP BY sk.dept, sk.sku
WHERE t.stype = 'P' AND sk.dept = 6400
ORDER BY SUM(t.amt) DESC


--Exercise 10: In what state and zip code is the store that had the greatest total revenue during the time period monitored in our dataset?
SELECT SUM(t.amt - skst.cost * t.quantity), t.store, str.state, str.zip, str.city
FROM TRNSACT t
JOIN SKSTINFO skst
ON skst.sku = t.sku AND skst.store = t.store
JOIN STRINFO str
ON t.store = str.store
GROUP BY t.store, str.state, str.zip, str.city
WHERE t.stype = 'P' 
ORDER BY 1 DESC

--In what city and state is the store that had the greatest total sum of sales
-- NO need to calculate the cost no need to join skstinfo
SELECT TOP 10 t.store, s.city, s.state, SUM(amt) AS tot_sales

FROM trnsact t JOIN strinfo s

ON t.store=s.store

WHERE stype='P'

GROUP BY t.store, s.state, s.city

ORDER BY tot_sales DESC



--What is the deptdesc of the departments that have the top 3 greatest numbers of skus from the skuinfo table associated with them?
--
SELECT TOP 3 s.dept, d.deptdesc, COUNT(DISTINCT s.sku) AS numskus

FROM skuinfo s JOIN deptinfo d

ON s.dept=d.dept

GROUP BY s.dept, d.deptdesc

ORDER BY numskus DESC

--NO NEED to JOIN skst table
SELECT skst.sku, d.deptdesc
FROM skstinfo skst
JOIN skuinfo sku
ON skst.sku = sku.sku
JOIN deptinfo d 
ON sku.dept = d.dept
GROUP BY skst.sku, d.deptdesc 
ORDER BY skst.sku DESC 

SELECT DISTINCT sku.sku, sku.dept, d.deptdesc
FROM skuinfo sku
LEFT JOIN skstinfo skst
ON skst.sku = sku.sku
JOIN deptinfo d 
ON sku.dept = d.dept
ORDER BY 1 DESC

--9999926LACOSTE
--9999997

--the store_msa table provides population statistics about the geographic location around a store. Using one query to retrieve your answer, how many MSAs are there within the state of North Carolina (abbreviated “NC”), and within these MSAs, what is the lowest population level (msa_pop) and highest income level (msa_income)?

SELECT COUNT(*), MIN(msa_pop), MAX(msa_income) 
FROM STORE_MSA
WHERE STATE = 'NC'

--How many stores have more than 180,000 distinct skus associated with them in the skstinfo table?
--Exercise 7: How many departments have more than 100 brands associated with them, and what are their descriptions?
--60
DATABASE ua_dillards;
SELECT st.store, COUNT(sk.sku)
FROM STRINFO st  
JOIN SKSTINFO sk 
ON st.store = sk.store
GROUP BY st.store
HAVING COUNT(sk.sku) > 180000

--On what day was Dillard’s income based on total sum of purchases the greatest
--1260529.1604/11/01, 
--2724957.5705/02/28
--7010422.8804/12/18
--2577771.6005/02/01
--only use trnsact table
SELECT TOP 10 saledate, SUM(amt) AS tot_sales

FROM trnsact

WHERE stype='P'

GROUP BY saledate

ORDER BY tot_sales DESC

-- NO NEED TO JOIN
SELECT SUM(t.amt), t.saledate
FROM TRNSACT t
JOIN SKSTINFO skst
ON skst.sku = t.sku AND skst.store = t.store
GROUP BY t.saledate
WHERE t.stype = 'P' AND t.saledate = '04/11/01'
ORDER BY 1 DESC

--Look at the data from all the distinct skus in the “cop” department with a “federal” brand and a “rinse wash” color. You'll see that these skus have the same values in some of the columns, meaning that they have some features in common.
SELECT *
FROM skuinfo sku
JOIN deptinfo d 
ON sku.dept = d.dept
WHERE d.deptdesc = 'COP' AND sku.brand = 'federal' AND sku.color = 'rinse wash' 

--What is the suggested retail price of all the skus in the “reebok” department with the “skechers” brand and a “wht/saphire” color?
SELECT *
FROM skuinfo sku
JOIN deptinfo d 
ON sku.dept = d.dept
JOIN skstinfo skst
ON skst.sku = sku.sku
WHERE d.deptdesc = 'REEBOK' AND sku.brand = 'skechers' AND sku.color = 'wht/saphire' 

--How many states have more than 10 Dillards stores in them?
SELECT COUNT(DISTINCT str.store), str.state
FROM STRINFO str
GROUP BY str.state
HAVING COUNT(DISTINCT str.store)>10