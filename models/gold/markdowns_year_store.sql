{{ config(
    materialized='view',
    schema='GOLD'
) }}

WITH store_weekly_markdowns AS (
    SELECT DISTINCT
        STORE_ID,
        DATE,
        MARKDOWN_1,
        MARKDOWN_2,
        MARKDOWN_3,
        MARKDOWN_4,
        MARKDOWN_5
    FROM {{ ref('walmart_fact_table') }}
    WHERE VRSN_END_DATE IS NULL
)

SELECT
    STORE_ID,
    YEAR(DATE) AS MARKDOWN_YEAR,
    SUM(COALESCE(MARKDOWN_1, 0)) AS TOTAL_MARKDOWN_1,
    SUM(COALESCE(MARKDOWN_2, 0)) AS TOTAL_MARKDOWN_2,
    SUM(COALESCE(MARKDOWN_3, 0)) AS TOTAL_MARKDOWN_3,
    SUM(COALESCE(MARKDOWN_4, 0)) AS TOTAL_MARKDOWN_4,
    SUM(COALESCE(MARKDOWN_5, 0)) AS TOTAL_MARKDOWN_5,
    SUM(
        COALESCE(MARKDOWN_1, 0) +
        COALESCE(MARKDOWN_2, 0) +
        COALESCE(MARKDOWN_3, 0) +
        COALESCE(MARKDOWN_4, 0) +
        COALESCE(MARKDOWN_5, 0)
    ) AS TOTAL_MARKDOWNS
FROM store_weekly_markdowns
GROUP BY
    STORE_ID,
    YEAR(DATE)