/*
QUESTION 2:
How many liters of milk and kilograms of bread could an average person buy:
- in 2006
- in 2018

Source:
t_stanislav_patlakha_project_sql_primary_final

Approach:
1) Get milk and bread yearly prices from FOOD rows.
2) Get one wage value per year from WAGE rows:
   - simple (unweighted) average across industries.
3) Compute affordability = wage / price.
*/

WITH cte_prices AS (
    /* Food prices (only food rows) for milk + bread in 2006 and 2018 */
    SELECT
        pf.year,
        MAX(CASE WHEN pf.category_code = 114201 THEN pf.avg_food_price END) AS avg_milk_price,
        MAX(CASE WHEN pf.category_code = 111301 THEN pf.avg_food_price END) AS avg_bread_price
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.category_name IS NOT NULL
      AND pf.year IN (2006, 2018)
    GROUP BY pf.year
),

cte_wage AS (
    /* One wage per year from wage rows (industry rows) */
    SELECT
        pf.year,
        AVG(pf.avg_wage) AS avg_wage
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.industry_name IS NOT NULL
      AND pf.year IN (2006, 2018)
    GROUP BY pf.year
)

SELECT
    p.year,
    ROUND(w.avg_wage::numeric, 1) AS avg_wage,
    ROUND(p.avg_milk_price::numeric, 1) AS avg_milk_price,
    ROUND(p.avg_bread_price::numeric, 1) AS avg_bread_price,
    ROUND((w.avg_wage / NULLIF(p.avg_milk_price, 0))::numeric, 1) AS milk_could_be_bought,
    ROUND((w.avg_wage / NULLIF(p.avg_bread_price, 0))::numeric, 1) AS bread_could_be_bought
FROM cte_prices p
JOIN cte_wage w
    ON p.year = w.year
WHERE p.avg_milk_price IS NOT NULL
  AND p.avg_bread_price IS NOT NULL
ORDER BY p.year;
