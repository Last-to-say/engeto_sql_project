/* 
QUESTION 1:
Do wages grow over time in all industries,
or do some industries experience wage declines?

Data source:
- t_stanislav_patlakha_project_sql_primary_final
(only rows where industry_name IS NOT NULL)
*/

WITH cte_payroll_year_comparison AS (
    /*
    STEP 1: Attach previous year's wage within each industry (YoY base)
    ------------------------------------------------------------------
    We use LAG() to compare each industry's wage with the previous year.
    */

    SELECT
        pf.industry_branch_code,
        pf.industry_name,
        pf.year,
        pf.avg_wage,
        LAG(pf.avg_wage) OVER (
            PARTITION BY pf.industry_branch_code
            ORDER BY pf.year
        ) AS avg_wage_last_year
    FROM t_stanislav_patlakha_project_sql_primary_final pf
    WHERE pf.industry_name IS NOT NULL
),

cte_payroll_summary AS (
    /*
    STEP 2: Summarize wage development per industry
    -----------------------------------------------
    We count how many times wages increased/decreased year-over-year.
    */

    SELECT
        industry_branch_code,
        industry_name,

        COUNT(*) FILTER (
            WHERE avg_wage_last_year IS NOT NULL
              AND avg_wage > avg_wage_last_year
        ) AS years_wage_increased,

        COUNT(*) FILTER (
            WHERE avg_wage_last_year IS NOT NULL
              AND avg_wage < avg_wage_last_year
        ) AS years_wage_decreased,

        CASE
            WHEN COUNT(*) FILTER (
                WHERE avg_wage_last_year IS NOT NULL
                  AND avg_wage < avg_wage_last_year
            ) > 0
            THEN 'In some years it decreased'
            ELSE 'It never decreased (only increased or stayed the same)'
        END AS q1_answer

    FROM cte_payroll_year_comparison
    GROUP BY industry_branch_code, industry_name
)

SELECT *
FROM cte_payroll_summary
ORDER BY industry_name;
