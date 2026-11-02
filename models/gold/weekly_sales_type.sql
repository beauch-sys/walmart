{{ config(
    materialized='view',
    schema='GOLD'
) }}

SELECT
    s.STORE_TYPE,
    f.STORE_ID,
    COUNT(*) AS SALES_RECORD_COUNT,
    SUM(f.STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES,
    AVG(f.STORE_WEEKLY_SALES) AS AVG_WEEKLY_SALES
FROM {{ ref('walmart_fact_table') }} AS f
INNER JOIN {{ ref('walmart_store_dim') }} AS s
    ON f.STORE_ID = s.STORE_ID
   AND f.DEPT_ID = s.DEPT_ID
WHERE f.VRSN_END_DATE IS NULL
GROUP BY
    s.STORE_TYPE,
    f.STORE_ID