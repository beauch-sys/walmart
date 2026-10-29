{{ config(materialized='view') }}

WITH department_sales AS (
    SELECT
        STORE_ID,
        DEPT_ID,
        TO_DATE("DATE") AS DATE,
        WEEKLY_SALES::NUMBER(18, 2) AS STORE_WEEKLY_SALES
    FROM {{ source('walmart_bronze', 'department_raw') }}
    WHERE STORE_ID IS NOT NULL
      AND DEPT_ID IS NOT NULL
      AND "DATE" IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY STORE_ID, DEPT_ID, TO_DATE("DATE")
        ORDER BY INSERTED_AT DESC NULLS LAST
    ) = 1
),
store_features AS (
    SELECT
        STORE_IDSTORE_ID,
        TO_DATE("DATE") AS DATE,
        TEMPERATURE AS STORE_TEMPERATURE,
        FUEL_PRICE,
        UNEMPLOYMENT,
        CPI,
        MARKDOWN_1,
        MARKDOWN_2,
        MARKDOWN_3,
        MARKDOWN_4,
        MARKDOWN_5
    FROM {{ source('walmart_bronze', 'fact_raw') }}
    WHERE STORE_ID IS NOT NULL
      AND "DATE" IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY STORE_ID, TO_DATE("DATE")
        ORDER BY INSERTED_AT DESC NULLS LAST
    ) = 1
)
SELECT
    d.STORE_ID,
    d.DEPT_ID,
    d.DATE,
    d.STORE_WEEKLY_SALES,
    f.FUEL_PRICE,
    f.STORE_TEMPERATURE,
    f.UNEMPLOYMENT,
    f.CPI,
    f.MARKDOWN_1,
    f.MARKDOWN_2,
    f.MARKDOWN_3,
    f.MARKDOWN_4,
    f.MARKDOWN_5,
    TO_VARCHAR(d.STORE_ID)
        || '|'
        || TO_VARCHAR(d.DEPT_ID)
        || '|'
        || TO_CHAR(d.DATE, 'YYYY-MM-DD')
        AS FACT_BUSINESS_KEY
FROM department_sales AS d
INNER JOIN {{ ref('walmart_store_dim') }} AS st
    ON d.STORE_ID = st.STORE_ID
   AND d.DEPT_ID = st.DEPT_ID
LEFT JOIN store_features AS f
    ON d.STORE_ID = f.STORE_ID
   AND d.DATE = f.DATE