/* 
QUESTION 1:
Do wages grow over time in all industries,
or do some industries experience wage declines?

Time period: 2006–2018 (common years with price data)
Wage definition:
- value_type_code = 5958  → average gross wage per employee
- unit_code = 200         → valid unit for wage values (verified empirically)
- calculation_code = 100  → physical persons
*/

WITH cte_czechia_payroll AS (
    /* 
    STEP 1: Build a clean yearly wage dataset
    ---------------------------------------
    Goal:
    - One row per (industry, year)
    - Average wage for that industry in that year

    Why:
    This creates a stable time series that can be compared year-to-year.
    */

    SELECT 
        cpib.name AS industry_name,          -- human-readable industry name
        cp.payroll_year,                     -- year of the payroll data
        AVG(cp.value) AS avg_salary_per_year -- average wage for that industry and year
    FROM czechia_payroll AS cp
    JOIN czechia_payroll_industry_branch AS cpib
        ON cp.industry_branch_code = cpib.code
    WHERE 
        cp.value_type_code = 5958             -- average gross wage per employee
        AND cp.unit_code = 200                -- correct unit for wage values
        AND cp.calculation_code = 100          -- physical persons calculation
        AND cp.payroll_year BETWEEN 2006 AND 2018 -- comparable years with price data
        AND cp.industry_branch_code IS NOT NULL -- exclude national totals
    GROUP BY 
        cpib.name,
        cp.payroll_year
),

cte_payroll_year_comparison AS (
    /*
    STEP 2: Compare each year with the previous year
    ------------------------------------------------
    Goal:
    - For each industry, attach the previous year's wage
    - Enable year-over-year comparison

    LAG() explanation:
    - PARTITION BY industry_name → each industry handled separately
    - ORDER BY payroll_year      → ensures correct time order
    */

    SELECT
        industry_name,
        payroll_year,
        avg_salary_per_year,
        LAG(avg_salary_per_year) OVER (
            PARTITION BY industry_name
            ORDER BY payroll_year
        ) AS avg_salary_last_year  -- wage from the previous year (NULL for first year)
    FROM cte_czechia_payroll
),

cte_payroll_summary AS (
    /*
    STEP 3: Summarize wage development per industry
    -----------------------------------------------
    Goal:
    - Count how many times wages increased
    - Count how many times wages decreased
    - Answer the research question directly:
      Did wages ever decrease in this industry?
    */

    SELECT
        industry_name,

        /* 
        Count years where:
        - a previous year exists
        - current year's wage is higher than last year's wage

        FILTER limits COUNT(*) only to rows that meet the condition.
        */
        COUNT(*) FILTER (
            WHERE avg_salary_last_year IS NOT NULL
              AND avg_salary_per_year > avg_salary_last_year
        ) AS years_salary_increased,

        /* 
        Count years where:
        - a previous year exists
        - current year's wage is lower than last year's wage

        This tells us how many wage declines occurred.
        */
        COUNT(*) FILTER (
            WHERE avg_salary_last_year IS NOT NULL
              AND avg_salary_per_year < avg_salary_last_year
        ) AS years_salary_decreased,

        /*
        FINAL ANSWER FOR QUESTION 1 (per industry):

        If there is at least one year where wage decreased,
        then wages did NOT grow continuously in this industry.
        */
        CASE
            WHEN COUNT(*) FILTER (
                WHERE avg_salary_last_year IS NOT NULL
                  AND avg_salary_per_year < avg_salary_last_year
            ) > 0
            THEN 'In some years it decreased'
            ELSE 'It never decreased (only increased or stayed the same)'
        END AS q1_answer

    FROM cte_payroll_year_comparison
    GROUP BY industry_name
)

/*
FINAL OUTPUT:
-------------
One row per industry showing:
- how many years wages increased
- how many years wages decreased
- a clear textual conclusion answering Question 1
*/
SELECT *
FROM cte_payroll_summary
ORDER BY industry_name;



