-- Data Cleaning of the Data Set

-- Data Set: https://www.kaggle.com/datasets/swaptr/layoffs-2022

USE layoffs_world;

SELECT *
FROM layoffs_world.layoffs;

-- First we want to do is create a staging table. 
-- This is the one we will work in and clean the data. 
-- We want a table with the raw data in case something goes wrong

CREATE TABLE layoffs_world.layoffs_staging 
LIKE layoffs_world.layoffs;

INSERT layoffs_staging 
SELECT * FROM layoffs_world.layoffs;

-- Now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- 1. Remove Duplicates
SELECT *
FROM layoffs_world.layoffs_staging;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		layoffs_world.layoffs_staging;
        
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		layoffs_world.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


-- let's just look at oda to confirm
SELECT *
FROM layoffs_world.layoffs_staging
WHERE company = 'Oda';

-- It looks like these are all legitimate entries and shouldn't be deleted. 
-- We need to really look at every single row to be accurate

-- These are our real duplicates 
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_world.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


-- These are the ones we want to delete where the row number is > 1 or 2or greater essentially
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_world.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE;
-- Getting error as we cannot delete the data from the CTE

WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_world.layoffs_staging
)
DELETE FROM layoffs_world.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;

-- Still the same
-- One solution, which I think is a good one is to create a new column and add those row numbers in. 
-- Then delete where row numbers are over 2, then delete that column
-- so let's do it!!

ALTER TABLE layoffs_world.layoffs_staging ADD row_num INT;

SELECT *
FROM layoffs_world.layoffs_staging
;

CREATE TABLE `layoffs_world`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `layoffs_world`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_world.layoffs_staging;

-- Now that we have this we can delete rows were row_num is greater than 2
DELETE FROM layoffs_world.layoffs_staging2
WHERE row_num >= 2;

-- 2. Standardize Data

SELECT * 
FROM layoffs_world.layoffs_staging2;

-- If we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM layoffs_world.layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_world.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE company LIKE 'Bally%';

-- nothing wrong here
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- It looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- Write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- Makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_world.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Now if we check those are all null
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Now we need to populate those nulls if possible
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- And if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------
-- I also noticed the Crypto has multiple different variations. 
-- We need to standardize that - let's say all to Crypto
SELECT DISTINCT industry
FROM layoffs_world.layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Now that's taken care of:
SELECT DISTINCT industry
FROM layoffs_world.layoffs_staging2
ORDER BY industry;
-- --------------------------------------------------

-- We also need to look at 
SELECT *
FROM layoffs_world.layoffs_staging2;

-- Everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM layoffs_world.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Now if we run this again it is fixed
SELECT DISTINCT country
FROM layoffs_world.layoffs_staging2
ORDER BY country;

-- Let's also fix the date columns:
SELECT *
FROM layoffs_world.layoffs_staging2;

-- we can use str to date to update this field
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_world.layoffs_staging2;

-- 3. Look at Null Values
-- The null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. 
-- I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
-- So there isn't anything I want to change with the null values

-- 4. remove any columns and rows we need to
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_world.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM layoffs_world.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_world.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_world.layoffs_staging2;


-- Here the cleaning of the data is completed.
-- EDA of the Data Set.
-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers
-- Normally when you start the EDA process you have some idea of what you're looking for
-- With this info we are just going to look around and see what we find!

SELECT * 
FROM layoffs_world.layoffs_staging2;

-- EASIER QUERIES
SELECT MAX(total_laid_off)
FROM layoffs_world.layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM layoffs_world.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_world.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- These are mostly startups it looks like who all went out of business during this time
-- If we order by funcs_raised_millions we can see how big some of these companies were

SELECT *
FROM layoffs_world.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- BritishVolt looks like an EV company, raised like 2 billion dollars and went under

-- TOUGHER AND MOSTLY USING GROUP BY
-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM layoffs_world.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- Now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- By location
SELECT location, SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- This it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_world.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- TOUGHER QUERIES
-- Earlier we looked at Companies with the most Layoffs. 
-- Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
