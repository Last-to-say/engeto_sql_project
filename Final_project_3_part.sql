/*
QUESTION 3:
Which food category increases in price the slowest?

Definition of "slowest":
- lowest AVERAGE year-over-year (YoY) percentage price increase

Time period:
- 2006–2018 (common years enforced by primary_final)

Data source:
- t_stanislav_patlakha_project_sql_primary_final (food rows only)
*/

WITH cte_price_previous_year AS (
    /*
    STEP 1: Attach previous year's price (and previous year) to each food row
    */

    SELECT 
        pf.year,
        pf.category_code,
        pf.category_name,
        pf.avg_food_price,

        LAG(pf.avg_food_price) OVER (
            PARTITION BY pf.category_code
            ORDER BY pf.year
        ) AS avg_food_price_previous_year,

        LAG(pf.year) OVER (
            PARTITION BY pf.category_code
            ORDER BY pf.year
        ) AS prev_year
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.category_name IS NOT NULL
),

cte_price_yoy_percentage AS (
    /*
    STEP 2: Calculate YoY % price change (only consecutive years)
    */

    SELECT 
        py.year,
        py.category_code,
        py.category_name,
        py.avg_food_price,
        py.avg_food_price_previous_year,
        ((py.avg_food_price - py.avg_food_price_previous_year)
         / NULLIF(py.avg_food_price_previous_year, 0)) * 100.0 AS price_percentage_change
    FROM cte_price_previous_year py
    WHERE py.avg_food_price_previous_year IS NOT NULL
      AND py.year = py.prev_year + 1
),

cte_price_category_summary AS (
    /*
    STEP 3: Average YoY growth per category
    */

    SELECT
        pyp.category_name,
        pyp.category_code,
        ROUND(AVG(pyp.price_percentage_change)::numeric, 2) AS avg_yoy_pct_change,
        COUNT(*) AS info_through_years
    FROM cte_price_yoy_percentage pyp
    GROUP BY pyp.category_name, pyp.category_code
)

SELECT *
FROM cte_price_category_summary
ORDER BY avg_yoy_pct_change;
