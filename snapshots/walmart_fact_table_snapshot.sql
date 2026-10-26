{% snapshot walmart_fact_table_snapshot %}

{{
    config(
        target_database='WALMART',
        target_schema='SILVER',
        unique_key='FACT_BUSINESS_KEY',
        strategy='check',
        check_cols=[
            'STORE_WEEKLY_SALES',
            'FUEL_PRICE',
            'STORE_TEMPERATURE',
            'UNEMPLOYMENT',
            'CPI',
            'MARKDOWN_1',
            'MARKDOWN_2',
            'MARKDOWN_3',
            'MARKDOWN_4',
            'MARKDOWN_5'
        ]
    )
}}

SELECT *
FROM {{ ref('walmart_fact_source') }}

{% endsnapshot %}