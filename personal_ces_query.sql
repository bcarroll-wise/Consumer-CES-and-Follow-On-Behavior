WITH ces_responses AS (
    -- Web (from INT_FEATURE_FEEDBACK)
    SELECT DISTINCT
        USER_ID AS user_id,
        SCORE AS ces_score,
        COMMENT AS ces_comment,
        CAST(MESSAGE_TIMESTAMP AS DATE) AS survey_date,
        PLATFORM AS platform,
        'WEB' AS source_table
    FROM ANALYTICS_DB.RPT_PRODUCT.INT_FEATURE_FEEDBACK
    WHERE FEATURE_NAME = 'CONSUMER_ONBOARDING_FLOW_DROP_OFF_CUSTOMER_EFFORT_SCORE'
      AND ADDITIONAL_DROP_OFF_STEP = 'VERIFICATION_FLOW'

    UNION ALL

    -- Mobile (from INT_FEEDBACK_UPDATED)
    SELECT DISTINCT
        USER_ID AS user_id,
        FEEDBACK_SCORE AS ces_score,
        FEEDBACK_COMMENT AS ces_comment,
        CAST(SUBMITTED_AT AS DATE) AS survey_date,
        CLIENT_PLATFORM AS platform,
        'MOBILE' AS source_table
    FROM ANALYTICS_DB.RPT_PRODUCT.INT_FEEDBACK_UPDATED
    WHERE SURVEY = 'CONSUMER_ONBOARDING_FLOW_DROP_OFF_CUSTOMER_EFFORT_SCORE'
      AND FEEDBACK_DROP_OFF_STEP = 'VERIFICATION_FLOW'
      AND FEEDBACK_SCORE IS NOT NULL
),
first_transfer AS (
    SELECT
        t.USER_ID,
        MIN(t.TRANSFER_CREATION_TIME) AS first_transfer_date,
        MIN_BY(t.INVOICE_VALUE_GBP, t.TRANSFER_CREATION_TIME) AS first_transfer_amount_gbp,
        MIN_BY(t.SOURCE_CURRENCY, t.TRANSFER_CREATION_TIME) AS first_transfer_source_currency,
        MIN_BY(t.INVOICE_VALUE, t.TRANSFER_CREATION_TIME) AS first_transfer_amount_source
    FROM ANALYTICS_DB.RPT_PRODUCT.LOOKUP_TRANSFER_CONTEXT t
    INNER JOIN ces_responses c ON t.USER_ID = c.user_id
    WHERE t.SUCCESSFUL_TRANSFER = TRUE
      AND t.TRANSFER_CREATION_TIME >= c.survey_date
    GROUP BY t.USER_ID
),
monthly_sends AS (
    SELECT
        t.USER_ID,
        DATE_TRUNC('month', t.TRANSFER_CREATION_TIME)::DATE AS send_month,
        COUNT(*) AS send_count,
        SUM(t.INVOICE_VALUE_GBP) AS send_value_gbp
    FROM ANALYTICS_DB.RPT_PRODUCT.LOOKUP_TRANSFER_CONTEXT t
    INNER JOIN ces_responses c ON t.USER_ID = c.user_id
    WHERE t.SUCCESSFUL_TRANSFER = TRUE
      AND t.TRANSFER_CREATION_TIME >= c.survey_date
    GROUP BY t.USER_ID, DATE_TRUNC('month', t.TRANSFER_CREATION_TIME)::DATE
),
user_country AS (
    SELECT USER_ID, REGISTRATION_COUNTRY
    FROM ANALYTICS_DB.RPT_PRODUCT.ONBOARDING_NEW_USER_CONVERSION
)
SELECT
    c.user_id,
    c.ces_score,
    c.ces_comment,
    c.survey_date,
    c.platform,
    c.source_table,
    uc.REGISTRATION_COUNTRY,
    f.first_transfer_date,
    f.first_transfer_amount_gbp,
    f.first_transfer_source_currency,
    f.first_transfer_amount_source,
    m.send_month,
    m.send_count,
    m.send_value_gbp
FROM ces_responses c
LEFT JOIN user_country uc ON c.user_id = uc.USER_ID
LEFT JOIN first_transfer f ON c.user_id = f.USER_ID
LEFT JOIN monthly_sends m ON c.user_id = m.USER_ID
ORDER BY c.user_id, m.send_month
