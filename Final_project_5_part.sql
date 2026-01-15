/* 
QUESTION 5:
Does GDP influence changes in wages and food prices?

Time period:
- 2006–2018 (common period)
Note:
- YoY % can be computed only from 2007 onward (2006 has no previous year).
*/

WITH cte_cz_yearly_wage AS (
    /* STEP 1A: One wage value per year (from wage rows only) */
    SELECT 
        pf.year,
        AVG(pf.avg_wage) AS avg_wage
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.industry_name IS NOT NULL 
    GROUP BY pf.year
),

cte_cz_yearly_food_price AS (
    /* STEP 1B: One food price index per year (from food rows only) */
    SELECT 
        pf.year,
        AVG(pf.avg_food_price) AS avg_food_price
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.category_name IS NOT NULL 
    GROUP BY pf.year
),

cte_cz_with_previous_year AS (
    /* STEP 2: Attach previous-year values for YoY calculations */
    SELECT 
        w.year,
        w.avg_wage,
        LAG(w.avg_wage) OVER (ORDER BY w.year) AS avg_wage_last_year,

        f.avg_food_price,
        LAG(f.avg_food_price) OVER (ORDER BY w.year) AS avg_food_price_last_year
    FROM cte_cz_yearly_wage w
    JOIN cte_cz_yearly_food_price f
        ON w.year = f.year 
), 

cte_cz_yoy_changes AS (
    /* STEP 3: Compute YoY % changes */
    SELECT 
        cly.year,

        cly.avg_wage,
        cly.avg_wage_last_year,
        (cly.avg_wage - cly.avg_wage_last_year) / NULLIF(cly.avg_wage_last_year, 0) * 100.0 AS wage_yoy_pct,

        cly.avg_food_price,
        cly.avg_food_price_last_year,
        (cly.avg_food_price - cly.avg_food_price_last_year) / NULLIF(cly.avg_food_price_last_year, 0) * 100.0 AS food_yoy_pct
    FROM cte_cz_with_previous_year cly 
    WHERE cly.avg_wage_last_year IS NOT NULL 
      AND cly.avg_food_price_last_year IS NOT NULL 
),

cte_cz_gdp AS (
    /* STEP 4: Czech Republic GDP (2006–2018) from secondary_final */
    SELECT 
        sf.year,
        sf.gdp
    FROM t_stanislav_patlakha_project_sql_secondary_final sf 
    WHERE sf.country = 'Czech Republic'
      AND sf.year BETWEEN 2006 AND 2018
),

cte_gdp_with_previous_year AS (
    /* STEP 5: Attach previous-year GDP */
    SELECT 
        cg.year,
        cg.gdp,
        LAG(cg.gdp) OVER (ORDER BY cg.year) AS gdp_last_year
    FROM cte_cz_gdp cg
),

cte_gdp_yoy_changes AS (
    /* STEP 6: GDP YoY % change */
    SELECT 
        gly.year,
        gly.gdp,
        gly.gdp_last_year,
        (gly.gdp - gly.gdp_last_year) / NULLIF(gly.gdp_last_year, 0) * 100.0 AS gdp_yoy_pct
    FROM cte_gdp_with_previous_year gly
    WHERE gly.gdp_last_year IS NOT NULL 
),

cte_final_q5_table AS (
    /* STEP 7: Combine YoY metrics + next-year (lag) columns */
    SELECT 
        ccy.year,

        ccy.avg_wage,
        ccy.avg_wage_last_year,
        ccy.wage_yoy_pct,
        LEAD(ccy.wage_yoy_pct) OVER (ORDER BY ccy.year) AS wage_yoy_next_year,

        ccy.avg_food_price,
        ccy.avg_food_price_last_year,
        ccy.food_yoy_pct,
        LEAD(ccy.food_yoy_pct) OVER (ORDER BY ccy.year) AS food_yoy_next_year,

        cgy.gdp,
        cgy.gdp_last_year,
        cgy.gdp_yoy_pct
    FROM cte_cz_yoy_changes ccy
    JOIN cte_gdp_yoy_changes cgy
        ON ccy.year = cgy.year 
)

SELECT * 
FROM cte_final_q5_table
ORDER BY year;
