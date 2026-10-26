{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='DATE_ID',
        merge_update_columns=['IS_HOLIDAY', 'UPDATE_DATE']
    )
}}

WITH source_dates AS (
    SELECT
        TO_DATE("DATE") AS STORE_DATE,
        MAX(IFF(IS_HOLIDAY, TRUE, FALSE)) AS IS_HOLIDAY
    FROM {{ source('walmart_bronze', 'department_raw') }}
    WHERE "DATE" IS NOT NULL
    GROUP BY TO_DATE("DATE")
),
transformed AS (
    SELECT
        TO_NUMBER(TO_CHAR(STORE_DATE, 'YYYYMMDD')) AS DATE_ID,
        STORE_DATE,
        IS_HOLIDAY,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS INSERT_DATE,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS UPDATE_DATE
    FROM source_dates
)
SELECT * FROM transformed

{% if is_incremental() %}

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS existing
    WHERE existing.DATE_ID = transformed.DATE_ID
      AND existing.IS_HOLIDAY
          IS NOT DISTINCT FROM transformed.IS_HOLIDAY
)

{% endif %}