{{ config(
    materialized='view',
    schema='GOLD'
) }}

WITH store_weekly_fuel AS (
    SELECT DISTINCT
        STORE_ID,
        DATE,
        FUEL_PRICE
    FROM {{ ref('walmart_fact_table') }}
    WHERE VRSN_END_DATE IS NULL
)
SELECT
    YEAR(DATE) AS FUEL_YEAR,
    ROUND(AVG(FUEL_PRICE), 3) AS AVG_FUEL_PRICE,
    MIN(FUEL_PRICE) AS MIN_FUEL_PRICE,
    MAX(FUEL_PRICE) AS MAX_FUEL_PRICE,
    COUNT(*) AS STORE_WEEK_RECORD_COUNT
FROM store_weekly_fuel
GROUP BY YEAR(DATE)