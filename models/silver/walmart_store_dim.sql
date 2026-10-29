{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['STORE_ID', 'DEPT_ID'],
        merge_update_columns=[
            'STORE_TYPE',
            'STORE_SIZE',
            'UPDATE_DATE'
        ]
    )
}}

WITH department_assignments AS (
    SELECT
        STORE_ID::INTEGER AS STORE_ID,
        DEPT_ID::INTEGER AS DEPT_ID,
        INSERTED_AT
    FROM {{ source('walmart_bronze', 'department_raw') }}
    WHERE STORE_ID IS NOT NULL
      AND DEPT_ID IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY STORE_ID, DEPT_ID
        ORDER BY INSERTED_AT DESC NULLS LAST, "DATE" DESC NULLS LAST
    ) = 1
),

deduplicated_stores AS (
    SELECT
        STORE_ID::INTEGER AS STORE_ID,
        TYPE::VARCHAR AS STORE_TYPE,
        SIZE::INTEGER AS STORE_SIZE
    FROM {{ source('walmart_bronze', 'stores_raw') }}
    WHERE STORE_ID IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY STORE_ID
        ORDER BY
            INSERTED_AT DESC NULLS LAST,
            TYPE ASC NULLS LAST,
            SIZE DESC NULLS LAST
    ) = 1
),

transformed AS (
    SELECT
        d.STORE_ID,
        d.DEPT_ID,
        s.STORE_TYPE,
        s.STORE_SIZE,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS INSERT_DATE,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS UPDATE_DATE
    FROM department_assignments AS d
    INNER JOIN deduplicated_stores AS s
        ON d.STORE_ID = s.STORE_ID
)

SELECT * FROM transformed

{% if is_incremental() %}

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS existing
    WHERE existing.STORE_ID = transformed.STORE_ID
      AND existing.DEPT_ID = transformed.DEPT_ID
      AND existing.STORE_TYPE
          IS NOT DISTINCT FROM transformed.STORE_TYPE
      AND existing.STORE_SIZE
          IS NOT DISTINCT FROM transformed.STORE_SIZE
)

{% endif %}