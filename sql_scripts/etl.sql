CREATE TABLE staging_users (
    user_id_source VARCHAR(255),
    user_name_raw VARCHAR(255),
    email_raw VARCHAR(255),
    user_phone_raw VARCHAR(50),
    registration_date_text VARCHAR(50),
    total_spent_raw DECIMAL(18,2),
    user_segment_raw VARCHAR(50),
    user_name_cleaned VARCHAR(255),
    email_cleaned VARCHAR(255),
    user_phone_std VARCHAR(20),
    registration_date_std DATE,
    user_segment_std VARCHAR(50),
    load_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging_transactions (
    transaction_id_source VARCHAR(255),
    user_id_source VARCHAR(255),
    transaction_date_raw VARCHAR(50),
    product_id_source VARCHAR(255),
    merchant_id_source VARCHAR(255),
    device_id_source VARCHAR(255),
    location_id_source VARCHAR(255),
    product_amount_raw DECIMAL(18,2),
    transaction_fee_raw DECIMAL(10,2),
    cashback_raw DECIMAL(10,2),
    loyalty_points_raw INT,
    payment_method_raw VARCHAR(100),
    transaction_status_raw VARCHAR(50),
    current_transaction_location_raw VARCHAR(255),
    original_location_raw VARCHAR(255),
    transaction_value_raw DECIMAL(18,2),
    is_fraud_derived BOOLEAN,
    payment_method_std VARCHAR(50),
    transaction_status_std VARCHAR(50),
    load_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

UPDATE staging_users
SET 
    user_phone_std = REPLACE(REPLACE(user_phone_raw, '-', ''), ' ', ''),
    registration_date_std = registration_date_text::date,
    user_segment_std = CASE 
                            WHEN total_spent_raw > 1000000 THEN 'Premium'
                            WHEN total_spent_raw > 100000 THEN 'Basic'
                            ELSE 'New'
                       END,
    user_name_cleaned = user_name_raw,
    email_cleaned = email_raw;

UPDATE staging_transactions
SET is_fraud_derived = CASE 
                            WHEN current_transaction_location_raw != original_location_raw AND transaction_value_raw > 5000000 THEN TRUE
                            ELSE FALSE
                       END,
    payment_method_std = LTRIM(RTRIM(UPPER(payment_method_raw))),
    transaction_status_std = LTRIM(RTRIM(UPPER(transaction_status_raw)));

INSERT INTO dim_user (user_id, user_name, email, phone_number, registration_date, user_segment)
SELECT 
    s.user_id_source, 
    s.user_name_cleaned, 
    s.email_cleaned, 
    s.user_phone_std, 
    s.registration_date_std, 
    s.user_segment_std
FROM staging_users s
WHERE NOT EXISTS (SELECT 1 FROM dim_user du WHERE du.user_id = s.user_id_source);

INSERT INTO dim_time (time_id, date_value, day_of_week, day_of_month, month_of_year, quarter_of_year, year_value, hour_of_day, is_weekend)
VALUES
(2023011508, '2023-01-15', 'Minggu', 15, 1, 1, 2023, 8, TRUE),
(2023011510, '2023-01-15', 'Minggu', 15, 1, 1, 2023, 10, TRUE),
(2023011614, '2023-01-16', 'Senin', 16, 1, 1, 2023, 14, FALSE);

INSERT INTO fact_transactions (
    transaction_id, 
    user_id_surrogate, 
    time_id, 
    location_id_surrogate, 
    product_id_surrogate, 
    merchant_id_surrogate, 
    device_id_surrogate, 
    transaction_amount, 
    transaction_fee, 
    cashback_amount, 
    loyalty_points_earned, 
    payment_method, 
    transaction_status, 
    is_fraud
)
SELECT 
    st.transaction_id_source,
    du.user_id_surrogate,
    to_char(st.transaction_date_raw::timestamp, 'YYYYMMDDHH24')::integer,
    dl.location_id_surrogate,
    dp.product_id_surrogate,
    dm.merchant_id_surrogate,
    dd.device_id_surrogate,
    st.product_amount_raw,
    st.transaction_fee_raw,
    st.cashback_raw,
    st.loyalty_points_raw,
    st.payment_method_std,
    st.transaction_status_std,
    st.is_fraud_derived
FROM staging_transactions st
JOIN dim_user du ON st.user_id_source = du.user_id
JOIN dim_location dl ON st.location_id_source = dl.location_id
JOIN dim_product dp ON st.product_id_source = dp.product_id
LEFT JOIN dim_merchant dm ON st.merchant_id_source = dm.merchant_id
JOIN dim_device dd ON st.device_id_source = dd.device_id;

CREATE INDEX IDX_Fact_User ON fact_transactions(user_id_surrogate);
CREATE INDEX IDX_Fact_Time ON fact_transactions(time_id);
CREATE INDEX IDX_Fact_Location ON fact_transactions(location_id_surrogate);
CREATE INDEX IDX_Fact_Product ON fact_transactions(product_id_surrogate);
CREATE INDEX IDX_Fact_Merchant ON fact_transactions(merchant_id_surrogate);
CREATE INDEX IDX_Fact_Device ON fact_transactions(device_id_surrogate);
CREATE INDEX IDX_Fact_IsFraud ON fact_transactions(is_fraud);

CREATE INDEX IDX_DimTime_DateValue ON dim_time(date_value);
CREATE INDEX IDX_DimUser_Segment ON dim_user(user_segment);
CREATE INDEX IDX_DimUser_NaturalKey ON dim_user(user_id);
CREATE INDEX IDX_DimProduct_Category ON dim_product(product_category);
CREATE INDEX IDX_DimProduct_NaturalKey ON dim_product(product_id);
CREATE INDEX IDX_DimMerchant_NaturalKey ON dim_merchant(merchant_id);
CREATE INDEX IDX_DimLocation_NaturalKey ON dim_location(location_id);
CREATE INDEX IDX_DimDevice_NaturalKey ON dim_device(device_id);