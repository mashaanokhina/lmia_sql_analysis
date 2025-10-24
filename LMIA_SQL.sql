-- Check our data 
SELECT * FROM lmia.lmia;

-- LMIA Approvals: Jan 2023 – Mar 2025
select count(*) from lmia;

-- Approved LMIA Positions: Jan 2023 – Mar 2025
SELECT SUM(Approved_Positions) FROM lmia;

-- Approved LMIA Positions by Quarters: Jan 2023 – Mar 2025
SELECT _Year, _Quarter, SUM(Approved_Positions) 
FROM lmia
GROUP BY _Year, _Quarter
ORDER BY _Year, _Quarter;


-- Annual LMIA-approved positions, with 2025 data available only for Q1
SELECT _Year, SUM(Approved_Positions) 
FROM lmia
GROUP BY _Year
ORDER BY _Year;

-- Number of temporary foreign workers approved through the LMIA program, by province and year

SELECT _Year, Province_Territory, SUM(Approved_Positions) as Total
FROM lmia
GROUP BY _Year, Province_Territory
ORDER BY _Year, Total Desc;

-- Cleaning data 
SET SQL_SAFE_UPDATES = 0;
UPDATE lmia
SET Program_Stream = TRIM(Program_Stream);
SET SQL_SAFE_UPDATES = 1;

-- Distribution of temporary foreign workers approved through the LMIA program, by program stream and year
SELECT _Year, Program_Stream, SUM(Approved_Positions) AS Total
FROM lmia
GROUP BY _Year, Program_Stream
ORDER BY _Year, Total desc;

-- Top occupations by program stream, province, and year

WITH RankedOccupations AS (
  SELECT
    Program_Stream,
    Occupation,
    _Year,
    SUM(Approved_Positions) AS TotalPositions,
    ROW_NUMBER() OVER (
      PARTITION BY Program_Stream, _Year
      ORDER BY SUM(Approved_Positions) DESC
    ) AS _rank
  FROM lmia
  GROUP BY Program_Stream, Occupation, _Year
)
SELECT *
FROM RankedOccupations
WHERE _rank <= 10
ORDER BY Program_Stream, _Year, _rank;

-- To remove duplicated occupations, create a new column by extracting the numeric code from the Occupation field. Use this code to group and consolidate entries.
SET SQL_SAFE_UPDATES = 0;
alter table lmia
add column Occupation_Clean varchar (255);

UPDATE lmia
SET Occupation_Clean = Occupation;

UPDATE lmia
SET Occupation_clean = REGEXP_SUBSTR(Occupation, '^[0-9]+');

UPDATE lmia
SET SQL_SAFE_UPDATES = 1;

-- Run Query with update data to receive the top of positions in each province by year

WITH RankedOccupations AS (
  SELECT
    Program_Stream,
    Occupation_Clean,
    MIN(Occupation) AS Full_Occupation,
    _Year,
    SUM(Approved_Positions) AS TotalPositions,
    ROW_NUMBER() OVER (
      PARTITION BY Program_Stream, _Year
      ORDER BY SUM(Approved_Positions) DESC
    ) AS _rank
  FROM lmia
  GROUP BY Program_Stream, Occupation_Clean, _Year
)
SELECT *
FROM RankedOccupations
WHERE _rank <= 10
ORDER BY Program_Stream, _Year, _rank;

-- Top Occupations Approved Under the LMIA Program
Select Occupation_Clean, MIN(Occupation) as Full_Occupation, sum(Approved_Positions) as Total
from lmia
Group by Occupation_Clean
order by Total Desc
limit 20;

-- Top Occupations Approved Under the LMIA Program by Program_Stream
SELECT 
  Occupation_Clean, 
  Program_Stream, 
  MIN(Occupation) AS Full_Occupation, 
  SUM(Approved_Positions) AS Total,
  ROW_NUMBER() OVER (ORDER BY SUM(Approved_Positions) DESC) AS Popularity
FROM lmia
GROUP BY Occupation_Clean, Program_Stream
ORDER BY Popularity
limit 20;

-- Top positions in the Program_Stream
select *
from 
(SELECT  
  Occupation_Clean as NOC, 
  Program_Stream, 
  MIN(Occupation) AS Full_Occupation, 
  SUM(Approved_Positions) AS Total,
  ROW_NUMBER() OVER (PARTITION BY Program_Stream ORDER BY SUM(Approved_Positions) DESC) AS Popularity
FROM lmia
GROUP BY Occupation_Clean, Program_Stream
ORDER BY Program_Stream, Popularity) as TOP
where Popularity <=5; 