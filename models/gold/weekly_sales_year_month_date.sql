{{ config(
    materialized='view',
    schema='GOLD'
) }}

SELECT
    YEAR(f.DATE) AS SALES_YEAR,
    MONTH(f.DATE) AS SALES_MONTH,
    DAY(f.DATE) AS SALES_DAY,
    f.DATE AS SALES_DATE,
    COUNT(*) AS SALES_RECORD_COUNT,
    SUM(f.STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES,
    AVG(f.STORE_WEEKLY_SALES) AS AVG_WEEKLY_SALES
FROM {{ ref('walmart_fact_table') }} AS f
WHERE f.VRSN_END_DATE IS NULL
GROUP BY
    YEAR(f.DATE),
    MONTH(f.DATE),
    DAY(f.DATE),
    f.DATE