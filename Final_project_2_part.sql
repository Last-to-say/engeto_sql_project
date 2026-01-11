/* 
QUESTION 2:
How many liters of milk and kilograms of bread could an average person buy:
- in the FIRST comparable year (2006)
- in the LAST comparable year (2018)

Data source:
- t_stanislav_patlakha_project_sql_primary_final

This table already contains:
- avg_wage (national average wage per year)
- avg_food_price (average yearly price per food category)
- common years only (2006–2018)
*/

WITH cte_wage_and_two_products AS (
    /*
    STEP 1: Get wages and prices for milk + bread (only years 2006 and 2018)
    -----------------------------------------------------------------------
    Goal:
    - One row per year
    - Keep avg_wage
    - Turn milk and bread prices into two columns

    Why MAX(CASE ...)?
    - In primary_final, each year contains many categories (many rows).
    - We "pick" the correct category price into its own column.
    */

    SELECT 
        pf.year,
        MAX(pf.avg_wage) AS avg_wage, -- wage repeats across categories → MAX is safe

        /* Milk price (category_code 114201) */
        MAX(CASE WHEN pf.category_code = 114201 THEN pf.avg_food_price END) AS avg_milk_price,

        /* Bread price (category_code 111301) */
        MAX(CASE WHEN pf.category_code = 111301 THEN pf.avg_food_price END) AS avg_bread_price

    FROM t_stanislav_patlakha_project_sql_primary_final AS pf
    WHERE pf.year IN (2006, 2018)
    GROUP BY pf.year
),

cte_affordability AS (
    /*
    STEP 2: Calculate affordability (how many units can be bought)
    --------------------------------------------------------------
    Formulas:
    - milk_liters  = avg_wage / avg_milk_price
    - bread_kg     = avg_wage / avg_bread_price

    Note:
    - We ROUND to 1 decimal place for nice readable output.
    */

    SELECT 
        wp.year,
        wp.avg_wage,
        wp.avg_milk_price,
        wp.avg_bread_price,

        ROUND((wp.avg_wage / wp.avg_milk_price)::numeric, 1) AS milk_could_be_bought,
        ROUND((wp.avg_wage / wp.avg_bread_price)::numeric, 1) AS bread_could_be_bought

    FROM cte_wage_and_two_products AS wp
)

/*
FINAL OUTPUT:
-------------
Two rows only: 2006 and 2018

Shows:
- average wage
- average milk price
- average bread price
- how many liters of milk could be bought
- how many kilograms of bread could be bought
*/
SELECT *
FROM cte_affordability
ORDER BY year;
