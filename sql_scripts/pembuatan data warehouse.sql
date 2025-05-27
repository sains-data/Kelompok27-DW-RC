CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date_value DATE NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,
    day_of_month INT NOT NULL,
    month_of_year INT NOT NULL,
    quarter_of_year INT NOT NULL,
    year_value INT NOT NULL,
    hour_of_day INT NOT NULL,
    is_weekend BOOLEAN NOT NULL -- Di PostgreSQL, tipe data BIT sering diganti dengan BOOLEAN
);

CREATE TABLE dim_user (
    user_id_surrogate INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Penyesuaian untuk PostgreSQL
    user_id VARCHAR(255) NOT NULL UNIQUE,
    user_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    registration_date DATE,
    user_segment VARCHAR(50),
    valid_from TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Menggunakan TIMESTAMPTZ untuk zona waktu
    valid_to TIMESTAMPTZ DEFAULT '9999-12-31 23:59:59+00',
    is_current BOOLEAN DEFAULT TRUE                     -- Penyesuaian BIT ke BOOLEAN
);

CREATE TABLE dim_location (
    location_id_surrogate INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Penyesuaian
    location_id VARCHAR(255) NOT NULL UNIQUE,
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Indonesia'
);

CREATE TABLE dim_product (
    product_id_surrogate INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Penyesuaian
    product_id VARCHAR(255) NOT NULL UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(100),
    provider VARCHAR(100)
);

CREATE TABLE dim_merchant (
    merchant_id_surrogate INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Penyesuaian
    merchant_id VARCHAR(255) NOT NULL UNIQUE,
    merchant_name VARCHAR(255) NOT NULL,
    merchant_category VARCHAR(100)
);

CREATE TABLE dim_device (
    device_id_surrogate INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Penyesuaian
    device_id VARCHAR(255) NOT NULL UNIQUE,
    device_type VARCHAR(50),
    device_os VARCHAR(50)
);
CREATE TABLE fact_transactions (
    transaction_id VARCHAR(255) PRIMARY KEY,
    user_id_surrogate INT NOT NULL,
    time_id INT NOT NULL,
    location_id_surrogate INT NOT NULL,
    product_id_surrogate INT NOT NULL,
    merchant_id_surrogate INT, -- Bisa NULL jika tidak ada merchant terkait
    device_id_surrogate INT NOT NULL,
    transaction_amount DECIMAL(18, 2) NOT NULL,
    transaction_fee DECIMAL(10, 2) DEFAULT 0,
    cashback_amount DECIMAL(10, 2) DEFAULT 0,
    loyalty_points_earned INT DEFAULT 0,
    payment_method VARCHAR(50),
    transaction_status VARCHAR(50),
    is_fraud BOOLEAN DEFAULT FALSE, -- <<< Tambahkan koma di sini

    CONSTRAINT FK_Transaction_User FOREIGN KEY (user_id_surrogate) REFERENCES dim_user(user_id_surrogate),
    CONSTRAINT FK_Transaction_Time FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    CONSTRAINT FK_Transaction_Location FOREIGN KEY (location_id_surrogate) REFERENCES dim_location(location_id_surrogate),
    CONSTRAINT FK_Transaction_Product FOREIGN KEY (product_id_surrogate) REFERENCES dim_product(product_id_surrogate),
    CONSTRAINT FK_Transaction_Merchant FOREIGN KEY (merchant_id_surrogate) REFERENCES dim_merchant(merchant_id_surrogate),
    CONSTRAINT FK_Transaction_Device FOREIGN KEY (device_id_surrogate) REFERENCES dim_device(device_id_surrogate)
);