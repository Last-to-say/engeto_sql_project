/* 
PRIMARY FINAL TABLE
===================
Table name:
t_stanislav_patlakha_project_sql_primary_final

Purpose:
--------
Unified analytical table for the Czech Republic combining:
- average national wages
- average food prices by category
- common comparable years only

Grain of the final table:
-------------------------
(year, food category)

Time period:
------------
2006–2018 (intersection of wage and food price data)

Important notes:
----------------
- Wages are taken as NATIONAL AVERAGE wages
  (industry_branch_code IS NULL).
- Food prices are averaged per category per year
  (simple mean, not CPI-weighted).
*/

CREATE TABLE t_stanislav_patlakha_project_sql_primary_final AS

WITH cte_yearly_wage AS (
    /*
    STEP 1: Compute national average wage per year
    ----------------------------------------------
    Source table: czechia_payroll

    Wage definition:
    - value_type_code = 5958  → average gross wage per employee
    - unit_code = 200         → valid unit for wage values
    - calculation_code = 100  → physical persons
    - industry_branch_code IS NULL → national total (NOT industry averages)

    Result:
    - One row per year
    - Column: avg_wage = national average wage in CZK
    */

	SELECT
	    payroll_year AS year,
	    AVG(value) AS avg_wage
	FROM czechia_payroll
	WHERE
	    value_type_code = 5958
	    AND unit_code = 200
	    AND calculation_code = 100
	    AND industry_branch_code IS NULL
	    AND payroll_year BETWEEN 2006 AND 2018
	GROUP BY payroll_year
),

cte_yearly_food_price AS (
    /*
    STEP 2: Compute average food price per category per year
    --------------------------------------------------------
    Source table: czechia_price

    Approach:
    - Extract year from date_from
    - Average all price observations for:
        (food category, year)

    Result:
    - One row per (year, category_code)
    - Column: avg_food_price = average yearly price
      for that food category

    Note:
    - This is a simple average (equal weights),
      not a CPI basket.
    */

	SELECT
	    EXTRACT(YEAR FROM date_from)::int AS year,
	    category_code,
	    AVG(value) AS avg_food_price
	FROM czechia_price
	WHERE EXTRACT(YEAR FROM date_from)::int BETWEEN 2006 AND 2018
	GROUP BY
	    category_code,
	    EXTRACT(YEAR FROM date_from)::int
)

 /*
 STEP 3: Combine wages and food prices into a single table
 ---------------------------------------------------------
 Join logic:
 - Join food prices with wages by YEAR
 - Join food category code with its human-readable name

 Result:
 - Final analytical table with:
     year
     category_code
     category_name
     avg_food_price
     avg_wage

 This table is used as the base for Questions 2–5.
 */
SELECT
    fp.year,
    fp.category_code,
    pc.name AS category_name,
    fp.avg_food_price,
    yw.avg_wage
FROM cte_yearly_food_price AS fp
JOIN cte_yearly_wage AS yw
    ON fp.year = yw.year
JOIN czechia_price_category AS pc
    ON fp.category_code = pc.code;

 
/* 
SECONDARY FINAL TABLE
====================
Table name:
t_stanislav_patlakha_project_sql_secondary_final

Purpose:
--------
Supplementary dataset with macroeconomic indicators
for European countries.

Used mainly for:
---------------
- Question 5 (GDP vs wages and food prices)

Time period:
------------
2006–2018 (same as primary table for comparability)

Grain of the table:
------------------
(country, year)
*/

CREATE TABLE t_stanislav_patlakha_project_sql_secondary_final AS 

SELECT 
	e.country,
	e.year,
	e.gdp,
	e.gini,
	e.population
FROM countries AS c
JOIN economies AS e 
	ON c.country = e.country
WHERE c.continent = 'Europe'
	AND e.year BETWEEN 2006 AND 2018;

