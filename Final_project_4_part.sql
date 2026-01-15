/* 
QUESTION 4:
Is there a year when the year-over-year (YoY) increase in food prices
was significantly higher than the YoY increase in wages
(by more than 10 percentage points)?

Condition:
(food_yoy_pct - wage_yoy_pct) > 10

Time period:
- 2006–2018 (common period with wages and prices)
Note:
- YoY starts from 2007 because 2006 has no previous year.
*/

WITH cte_yearly_wage AS (
    /*
    STEP 1A: Build one wage value per year (from wage rows only)
    -----------------------------------------------------------
    We average wages across industries to get a single yearly wage indicator.
    */

    SELECT
        pf.year,
        AVG(pf.avg_wage) AS avg_wage_year
    FROM t_stanislav_patlakha_project_SQL_primary_final pf
    WHERE pf.industry_name IS NOT NULL
    GROUP BY pf.year
),

cte_yearly_food_index AS (
    /*
    STEP 1B: Build one food price index per year (from food rows only)
    -----------------------------------------------------------------
    Food price index = average of category-level average prices in that year.
    */

    SELECT 
        pf.year,
        AVG(pf.avg_food_price) AS food_price_index_year
    FROM t_stanislav_patlakha_project_SQL_primary_final pf
    WHERE pf.category_name IS NOT NULL
    GROUP BY pf.year
),

cte_yoy AS (
    /*
    STEP 2: Attach previous year's values (for YoY calculations)
    -----------------------------------------------------------
    YoY % formula:
    (this_year - last_year) / last_year * 100
    */

    SELECT
        y.year,
        y.avg_wage_year,
        f.food_price_index_year,

        LAG(y.avg_wage_year) OVER (ORDER BY y.year) AS wage_last_year,
        LAG(f.food_price_index_year) OVER (ORDER BY y.year) AS food_last_year
    FROM cte_yearly_wage y
    JOIN cte_yearly_food_index f
        ON y.year = f.year
),

cte_compare AS (
    /*
    STEP 3: Compute YoY % and compare food vs wage growth
    -----------------------------------------------------
    diff_pct_points = food_yoy_pct - wage_yoy_pct
    */

    SELECT
        year,
        avg_wage_year,
        food_price_index_year,

        ((avg_wage_year - wage_last_year) / NULLIF(wage_last_year, 0)) * 100.0 AS wage_yoy_pct,
        ((food_price_index_year - food_last_year) / NULLIF(food_last_year, 0)) * 100.0 AS food_yoy_pct,

        (
          ((food_price_index_year - food_last_year) / NULLIF(food_last_year, 0)) * 100.0
          - ((avg_wage_year - wage_last_year) / NULLIF(wage_last_year, 0)) * 100.0
        ) AS diff_pct_points
    FROM cte_yoy
    WHERE wage_last_year IS NOT NULL
      AND food_last_year IS NOT NULL
)

SELECT *
FROM cte_compare
WHERE diff_pct_points > 10
ORDER BY year;
