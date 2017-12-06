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