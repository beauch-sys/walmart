
{{ config(
    materialized='view',
    schema='GOLD'
) }}

WITH store_weekly_temperature AS (
    -- Get one temperature reading per store and date
    SELECT DISTINCT
        STORE_ID,
        DATE,
        STORE_TEMPERATURE
    FROM {{ ref('walmart_fact_table') }}
    WHERE VRSN_END_DATE IS NULL
),
temperature_changes AS (
    -- Compare each store's temperature to its previous recorded week
    SELECT
        STORE_ID,
        DATE,
        STORE_TEMPERATURE,
        STORE_TEMPERATURE - LAG(STORE_TEMPERATURE) OVER (
            PARTITION BY STORE_ID
            ORDER BY DATE
        ) AS TEMPERATURE_CHANGE
    FROM store_weekly_temperature
),
sales_with_temperature AS (
    SELECT
        f.STORE_ID,
        f.DEPT_ID,
        f.DATE,
        YEAR(f.DATE) AS SALES_YEAR,
        f.STORE_WEEKLY_SALES,
        t.TEMPERATURE_CHANGE
    FROM {{ ref('walmart_fact_table') }} f
    INNER JOIN temperature_changes t
        ON f.STORE_ID = t.STORE_ID
       AND f.DATE = t.DATE
    WHERE f.VRSN_END_DATE IS NULL
)
SELECT
    SALES_YEAR,
    CASE
        WHEN TEMPERATURE_CHANGE <= -10
            THEN 'Significant Drop'
        WHEN TEMPERATURE_CHANGE <= -5
            THEN 'Moderate Drop'
        WHEN TEMPERATURE_CHANGE < 5
            THEN 'Relatively Stable'
        WHEN TEMPERATURE_CHANGE < 10
            THEN 'Moderate Increase'
        ELSE 'Significant Increase'
    END AS TEMPERATURE_CHANGE_CATEGORY,
    COUNT(*) AS SALES_RECORD_COUNT,
    SUM(STORE_WEEKLY_SALES) AS TOTAL_WEEKLY_SALES,
    ROUND(AVG(TEMPERATURE_CHANGE), 2) AS AVG_TEMPERATURE_CHANGE
FROM sales_with_temperature
WHERE TEMPERATURE_CHANGE IS NOT NULL
GROUP BY
    SALES_YEAR,
    TEMPERATURE_CHANGE_CATEGORY
