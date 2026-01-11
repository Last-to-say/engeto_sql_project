/*
QUESTION 3:
Which food category increases in price the slowest?

Definition of "slowest":
- lowest AVERAGE year-over-year (YoY) percentage price increase

Time period:
- 2006–2018 (assumed already enforced in the final table)

Data source:
- t_Stanislav_Patlakha_project_SQL_primary_final
  (built from czechia_price + wage-common years)

Approach:
1) For each food category, attach previous year's average price (LAG).
2) Compute YoY % change only for TRUE consecutive years (year = prev_year + 1).
3) Average those YoY % changes per category.
4) Sort ascending → the smallest average is the slowest price growth.
*/

WITH cte_price_previous_year AS (
    /*
    STEP 1: Attach previous year's price (and previous year) to each row
    -------------------------------------------------------------------
    Goal:
    - Prepare data for year-over-year comparison within each food category.

    Why LAG:
    - LAG returns the value from the previous row in the ordered partition.
    - We partition by category_code so comparisons happen only inside a category.
    - We also LAG(year) so we can verify that the years are consecutive.

    Note:
    - If a year is missing for a category (gap in time series),
      LAG would otherwise compare non-consecutive years.
      We'll filter those cases in the next CTE.
    */

    SELECT 
        pf.year,
        pf.category_code,
        pf.category_name,
        pf.avg_food_price,

        /* previous year's average price (previous row in the category timeline) */
        LAG(pf.avg_food_price) OVER (
            PARTITION BY pf.category_code
            ORDER BY pf.year
        ) AS avg_food_price_previous_year,

        /* previous row's year (used to ensure true YoY = consecutive years only) */
        LAG(pf.year) OVER (
            PARTITION BY pf.category_code
            ORDER BY pf.year
        ) AS prev_year

    FROM t_stanislav_patlakha_project_SQL_primary_final pf
),

cte_price_yoy_percentage AS (
    /*
    STEP 2: Calculate year-over-year (YoY) percentage price change
    --------------------------------------------------------------
    Formula:
    (price_this_year - price_last_year) / price_last_year * 100

    Key filters:
    - Exclude first year per category (previous year price is NULL).
    - Include ONLY consecutive years:
        year = prev_year + 1
      This prevents treating multi-year jumps as "YoY".

    Safety:
    - NULLIF(price_last_year, 0) prevents division-by-zero errors.
    */

    SELECT 
        py.year,
        py.category_code,
        py.category_name,
        py.avg_food_price,
        py.avg_food_price_previous_year,

        /* YoY % change; returns NULL if previous year's price is 0 */
        ((py.avg_food_price - py.avg_food_price_previous_year)
         / NULLIF(py.avg_food_price_previous_year, 0)) * 100.0 AS price_percentage_change

    FROM cte_price_previous_year py
    WHERE py.avg_food_price_previous_year IS NOT NULL
      AND py.year = py.prev_year + 1
),

cte_price_category_summary AS (
    /*
    STEP 3: Summarize price growth per food category
    ------------------------------------------------
    Goal:
    - Compute the average YoY % price change per category.

    Why average:
    - Represents typical yearly growth over the period.
    - Smooths out single-year volatility.

    info_through_years:
    - Number of valid YoY comparisons used (i.e., consecutive-year pairs).
    - Useful as a quality indicator (more comparisons = more reliable average).
    */

    SELECT
        pyp.category_name,                               -- human-readable food name
        pyp.category_code,
        AVG(pyp.price_percentage_change) AS avg_yoy_pct_change,
        COUNT(*) AS info_through_years                   -- count of YoY comparisons
    FROM cte_price_yoy_percentage pyp
    GROUP BY pyp.category_name, pyp.category_code
)

/*
FINAL OUTPUT:
-------------
One row per food category showing:
- avg_yoy_pct_change: average YoY % price increase
- info_through_years: number of consecutive-year comparisons used

The category with the LOWEST avg_yoy_pct_change
is the one that increases in price the slowest.
*/
SELECT *
FROM cte_price_category_summary
ORDER BY avg_yoy_pct_change;
