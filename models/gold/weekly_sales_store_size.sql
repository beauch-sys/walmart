
{{ config(
    materialized='view',
    schema='GOLD'
) }}

SELECT
    s.STORE_SIZE,
    COUNT(DISTINCT f.STORE_ID) AS STORE_COUNT,
    COUNT(*) AS SALES_RECORD_COUNT,
    SUM(f.STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES,
    AVG(f.STORE_WEEKLY_SALES) AS AVG_WEEKLY_SALES

FROM {{ ref('walmart_fact_table') }} f

INNER JOIN {{ ref('walmart_store_dim') }} s
    ON f.STORE_ID = s.STORE_ID
   AND f.DEPT_ID = s.DEPT_ID

WHERE f.VRSN_END_DATE IS NULL

GROUP BY
    s.STORE_SIZE
