
{{ config(
    materialized='view',
    schema='GOLD'
) }}

SELECT
    f.STORE_ID,
    d.IS_HOLIDAY,
    SUM(f.STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES
FROM {{ ref('walmart_fact_table') }} AS f
INNER JOIN {{ ref('walmart_store_dim') }} AS s
    ON f.STORE_ID = s.STORE_ID
   AND f.DEPT_ID = s.DEPT_ID
LEFT JOIN {{ ref('walmart_date_dim') }} AS d
    ON f.DATE = d.STORE_DATE
WHERE f.VRSN_END_DATE IS NULL
GROUP BY
    f.STORE_ID,
    d.IS_HOLIDAY
