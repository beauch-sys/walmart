{{ config(
    materialized='view',
    schema='GOLD'
) }}

SELECT
    f.CPI,
    COUNT(*) AS SALES_RECORD_COUNT,
    SUM(f.STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES,
    AVG(f.STORE_WEEKLY_SALES) AS AVG_WEEKLY_SALES,
    MIN(f.DATE) AS FIRST_SALES_DATE,
    MAX(f.DATE) AS LAST_SALES_DATE
FROM {{ ref('walmart_fact_table') }} AS f
WHERE f.VRSN_END_DATE IS NULL
  AND f.CPI IS NOT NULL
GROUP BY f.CPI