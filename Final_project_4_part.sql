/* 
QUESTION 4:
Is there a year when the year-over-year (YoY) increase in food prices
was significantly higher than the YoY increase in wages
(by more than 10 percentage points)?

Condition tested per year:
(food_yoy_pct - wage_yoy_pct) > 10

Time period:
- 2006–2018 (common period with wages and prices)
Note:
- YoY starts from 2007 because 2006 has no previous year.
*/

WITH cte_yearly_index AS (
    /*
    STEP 1: Build one row per year
    ------------------------------
    Goal:
    - Year-level wage value (single number per year)
    - "Overall food price index" per year:
      average of category-level average prices in that year

    Why MAX(avg_wage):
    - In the primary final table, avg_wage is typically repeated
      for each category in the same year.
    - MAX (or AVG) collapses it safely to one value per year.
    */

    SELECT
        pf.year,
        MAX(pf.avg_wage) AS avg_wage_year,
        AVG(pf.avg_food_price) AS food_price_index_year
    FROM t_stanislav_patlakha_project_SQL_primary_final pf
    GROUP BY pf.year
),

cte_yoy AS (
    /*
    STEP 2: Attach previous year's values and compute YoY %
    -------------------------------------------------------
    YoY % formula:
    (this_year - last_year) / last_year * 100
    */

    SELECT
        yi.year,
        yi.avg_wage_year,
        yi.food_price_index_year,

        LAG(yi.avg_wage_year) OVER (ORDER BY yi.year) AS wage_last_year,
        LAG(yi.food_price_index_year) OVER (ORDER BY yi.year) AS food_last_year
    FROM cte_yearly_index yi
),

cte_compare AS (
    /*
    STEP 3: Compute YoY % for wages and food + difference in percentage points
    -------------------------------------------------------------------------
    diff_pct_points = food_yoy_pct - wage_yoy_pct
    */

    SELECT
        y.year,
        y.avg_wage_year,
        y.food_price_index_year,

        ((y.avg_wage_year - y.wage_last_year) / NULLIF(y.wage_last_year, 0)) * 100.0 AS wage_yoy_pct,
        ((y.food_price_index_year - y.food_last_year) / NULLIF(y.food_last_year, 0)) * 100.0 AS food_yoy_pct,

        (
          ((y.food_price_index_year - y.food_last_year) / NULLIF(y.food_last_year, 0)) * 100.0
          - ((y.avg_wage_year - y.wage_last_year) / NULLIF(y.wage_last_year, 0)) * 100.0
        ) AS diff_pct_points
    FROM cte_yoy y
    WHERE y.wage_last_year IS NOT NULL
      AND y.food_last_year IS NOT NULL
)

SELECT *
FROM cte_compare
WHERE diff_pct_points > 10
ORDER BY year;
