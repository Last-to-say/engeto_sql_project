/* 
QUESTION 5:
Does GDP influence changes in wages and food prices?

Idea:
- Compare year-over-year (YoY) % change of:
  1) GDP
  2) average wage
  3) overall food price index (average across food categories)

We also add "next year" columns using LEAD() to check:
- same year effect vs. following year effect

Time period:
- 2006–2018 (common period)
Note:
- YoY % can be computed only from 2007 onward (2006 has no previous year).
*/

WITH cte_cz_yearly_summary AS (
    /*
    STEP 1: Build a Czech Republic yearly summary from primary_final
    ---------------------------------------------------------------
    Source table: t_stanislav_patlakha_project_sql_primary_final
    Grain of primary_final: (year, category_code)

    We want one row per YEAR with:
    - avg_wage        (same wage repeated for all categories in a year)
    - avg_food_price  (food price "index": average of category yearly prices)

    Why MAX(avg_wage)?
    - Wage is identical within a year (repeated across categories), so MAX is safe.
    */

    SELECT 
        pf.year,
        MAX(pf.avg_wage) AS avg_wage,
        AVG(pf.avg_food_price) AS avg_food_price
    FROM t_stanislav_patlakha_project_sql_primary_final AS pf
    GROUP BY pf.year
),

cte_cz_with_previous_year AS (
    /*
    STEP 2: Attach previous year values (for YoY calculations)
    ----------------------------------------------------------
    Add:
    - avg_wage_last_year
    - avg_food_price_last_year

    We use LAG() because it returns the value from the PREVIOUS row
    when ordered by year.
    */

    SELECT 
        cy.year,
        cy.avg_wage,

        /* previous year's average wage */
        LAG(cy.avg_wage) OVER (ORDER BY cy.year) AS avg_wage_last_year,

        cy.avg_food_price,

        /* previous year's average food price index */
        LAG(cy.avg_food_price) OVER (ORDER BY cy.year) AS avg_food_price_last_year

    FROM cte_cz_yearly_summary AS cy
), 

cte_cz_yoy_changes AS (
    /*
    STEP 3: Compute YoY % changes for wages and food prices
    ------------------------------------------------------
    YoY formula:
    (this_year - last_year) / last_year * 100

    We filter out rows where last_year is NULL
    because the first year has no previous-year comparison.
    */

    SELECT 
        cly.year,

        cly.avg_wage,
        cly.avg_wage_last_year,

        /* wage year-over-year % change */
        (cly.avg_wage - cly.avg_wage_last_year) / NULLIF(cly.avg_wage_last_year, 0) * 100.0 AS wage_yoy_pct,

        cly.avg_food_price,
        cly.avg_food_price_last_year,

        /* food price index year-over-year % change */
        (cly.avg_food_price - cly.avg_food_price_last_year) / NULLIF(cly.avg_food_price_last_year, 0) * 100.0 AS food_yoy_pct

    FROM cte_cz_with_previous_year AS cly 
    WHERE cly.avg_wage_last_year IS NOT NULL 
      AND cly.avg_food_price_last_year IS NOT NULL 
),

cte_cz_gdp AS (
    /*
    STEP 4: Get Czech Republic GDP from secondary_final
    ---------------------------------------------------
    Source table: t_stanislav_patlakha_project_sql_secondary_final
    Grain: (country, year)

    We only need Czech Republic, 2006–2018.
    */

    SELECT 
        sf.year,
        sf.gdp
    FROM t_stanislav_patlakha_project_sql_secondary_final AS sf 
    WHERE sf.country = 'Czech Republic'
      AND sf.year BETWEEN 2006 AND 2018
),

cte_gdp_with_previous_year AS (
    /*
    STEP 5: Attach previous year GDP (for YoY GDP change)
    -----------------------------------------------------
    Add:
    - gdp_last_year
    */

    SELECT 
        cg.year,
        cg.gdp,

        /* previous year's GDP */
        LAG(cg.gdp) OVER (ORDER BY cg.year) AS gdp_last_year

    FROM cte_cz_gdp AS cg
),

cte_gdp_yoy_changes AS (
    /*
    STEP 6: Compute GDP YoY % change
    -------------------------------
    YoY formula:
    (this_year - last_year) / last_year * 100

    Filter out first year where gdp_last_year is NULL.
    */

    SELECT 
        gly.year,
        gly.gdp,
        gly.gdp_last_year,

        /* GDP year-over-year % change */
        (gly.gdp - gly.gdp_last_year) / NULLIF(gly.gdp_last_year, 0) * 100.0 AS gdp_yoy_pct

    FROM cte_gdp_with_previous_year AS gly
    WHERE gly.gdp_last_year IS NOT NULL 
),

cte_final_q5_table AS (
    /*
    STEP 7: Join wage/food YoY with GDP YoY + add next-year columns
    --------------------------------------------------------------
    Goal:
    - One combined table for analysis
    - Contains same-year GDP vs wage/food changes
    - Also contains next-year wage/food changes to check lag effect

    LEAD() explanation:
    - LEAD(x) returns the value from the NEXT row (next year)
    - This helps test "does GDP in year Y relate to wage/food change in year Y+1?"
    */

    SELECT 
        ccy.year,

        /* wage values + YoY */
        ccy.avg_wage,
        ccy.avg_wage_last_year,
        ccy.wage_yoy_pct,

        /* wage YoY in the next year (for lag effect) */
        LEAD(ccy.wage_yoy_pct) OVER (ORDER BY ccy.year) AS wage_yoy_next_year,

        /* food values + YoY */
        ccy.avg_food_price,
        ccy.avg_food_price_last_year,
        ccy.food_yoy_pct,

        /* food YoY in the next year (for lag effect) */
        LEAD(ccy.food_yoy_pct) OVER (ORDER BY ccy.year) AS food_yoy_next_year,

        /* GDP values + YoY */
        cgy.gdp,
        cgy.gdp_last_year,
        cgy.gdp_yoy_pct

    FROM cte_cz_yoy_changes AS ccy
    LEFT JOIN cte_gdp_yoy_changes AS cgy 
        ON ccy.year = cgy.year 
)

/*
FINAL OUTPUT:
-------------
This table is the analytical base for Question 5.
You can visually compare:
- gdp_yoy_pct vs wage_yoy_pct (same year)
- gdp_yoy_pct vs food_yoy_pct (same year)
- gdp_yoy_pct vs wage_yoy_next_year (next year)
- gdp_yoy_pct vs food_yoy_next_year (next year)
*/
SELECT * 
FROM cte_final_q5_table
ORDER BY year;
