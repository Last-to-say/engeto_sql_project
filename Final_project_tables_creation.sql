/*
PRIMARY FINAL TABLE (revised)
============================
Purpose:
- One unified table for CZ for the common years 2006–2018
- Contains:
  A) food prices by category and year
  B) wages by industry and year

Design:
- Long format (UNION ALL of two datasets)
- Prevents category × industry multiplication
- Enables answering Q1–Q5 using only final tables
*/

CREATE TABLE t_stanislav_patlakha_project_sql_primary_final AS

WITH cte_wages_by_industry AS (
	/*
    PART A: Wages by industry and year
    ---------------------------------
    One row per (year, industry)

    Note:
    - Uses industry_branch_code IS NOT NULL because we need industries.
    */

    SELECT
        cp.payroll_year AS year,
        cp.industry_branch_code AS industry_branch_code,
        cpib.name AS industry_name,
        AVG(cp.value) AS avg_wage
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
      AND cp.unit_code = 200
      AND cp.calculation_code = 100
      AND cp.industry_branch_code IS NOT NULL
      AND cp.payroll_year BETWEEN 2006 AND 2018
    GROUP BY
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name
)
,

cte_food_prices AS (
    /*
    PART B: Food prices by category and year
    ---------------------------------------
    One row per (year, category)
    */

    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        cp.category_code::int AS category_code,
        cpc.name AS category_name,
        AVG(cp.value) AS avg_food_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE EXTRACT(YEAR FROM cp.date_from)::int BETWEEN 2006 AND 2018
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from)::int,
        cp.category_code,
        cpc.name
),

cte_common_years AS (
    /*
    PART C: Keep only common years between wages and prices
    ------------------------------------------------------
    Ensures comparability across both datasets.
    */

    SELECT year FROM cte_wages_by_industry
    INTERSECT
    SELECT year FROM cte_food_prices
)

SELECT
    w.year,
    w.industry_branch_code::text AS industry_branch_code,
    w.industry_name,
    NULL::int AS category_code,
    NULL::text AS category_name,
    NULL::numeric AS avg_food_price,
    w.avg_wage
FROM cte_wages_by_industry w
JOIN cte_common_years y
    ON w.year = y.year

UNION ALL

SELECT
    f.year,
    NULL::text AS industry_branch_code,
    NULL::text AS industry_name,
    f.category_code::int AS category_code,
    f.category_name,
    f.avg_food_price,
    NULL::numeric AS avg_wage
FROM cte_food_prices f
JOIN cte_common_years y
    ON f.year = y.year;


/*
SECONDARY FINAL TABLE
====================
Table name:
t_stanislav_patlakha_project_sql_secondary_final

Purpose:
- Supplementary dataset with macroeconomic indicators for European countries.
Used mainly for:
- Question 5 (GDP vs wages and food prices)

Time period:
- 2006–2018 (same as primary table for comparability)

Grain:
- (country, year)
*/

CREATE TABLE t_stanislav_patlakha_project_sql_secondary_final AS 
SELECT 
    e.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM countries c
JOIN economies e 
    ON c.country = e.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2006 AND 2018;
