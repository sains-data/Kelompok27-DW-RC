SELECT
    t.year_value AS Tahun,
    t.month_of_year AS Bulan,
    COUNT(ft.transaction_id) AS Jumlah_Transaksi,
    SUM(ft.transaction_amount) AS Total_Nominal_Transaksi
FROM fact_transactions ft
JOIN dim_time t ON ft.time_id = t.time_id
WHERE ft.transaction_status = 'Successful' -- Hanya transaksi yang berhasil
GROUP BY
    t.year_value,
    t.month_of_year
ORDER BY
    Tahun,
    Bulan;

SELECT
    p.product_category AS Kategori_Produk,
    COUNT(ft.transaction_id) AS Jumlah_Transaksi,
    SUM(ft.transaction_amount) AS Total_Nominal_Transaksi
FROM
    fact_transactions ft
JOIN
    dim_product p ON ft.product_id_surrogate = p.product_id_surrogate
WHERE
    ft.transaction_status = 'Successful' -- Hanya memperhitungkan transaksi yang berhasil
GROUP BY
    p.product_category
ORDER BY
    Total_Nominal_Transaksi DESC;

SELECT
    u.user_segment AS Segmen_Pelanggan,
    u.user_id,
    u.user_name,
    COUNT(ft.transaction_id) AS Jumlah_Transaksi_Pelanggan,
    AVG(ft.transaction_amount) AS Rata_Rata_Nominal_Transaksi
FROM fact_transactions ft
JOIN dim_user u ON ft.user_id_surrogate = u.user_id_surrogate
WHERE ft.transaction_status = 'Successful'
    -- AND u.user_segment = 'Premium' -- Contoh filter untuk segmen tertentu
GROUP BY
    u.user_segment,
    u.user_id,
    u.user_name
ORDER BY
    Segmen_Pelanggan,
    Rata_Rata_Nominal_Transaksi DESC;

SELECT
    l.city AS Kota,
    p.product_name AS Nama_Produk,
    p.product_category AS Kategori_Produk,
    COUNT(ft.transaction_id) AS Jumlah_Pembelian_Produk
FROM fact_transactions ft
JOIN dim_product p ON ft.product_id_surrogate = p.product_id_surrogate
JOIN dim_location l ON ft.location_id_surrogate = l.location_id_surrogate
WHERE ft.transaction_status = 'Successful'
GROUP BY
    l.city,
    p.product_name,
    p.product_category
ORDER BY
    Kota,
    Jumlah_Pembelian_Produk DESC;

WITH MonthlySales AS (
    SELECT
        t.year_value,
        t.month_of_year,
        SUM(ft.transaction_amount) AS Total_Sales
    FROM fact_transactions ft
    JOIN dim_time t ON ft.time_id = t.time_id
    WHERE ft.transaction_status = 'Successful'
    GROUP BY
        t.year_value,
        t.month_of_year
),
LaggedSales AS (
    SELECT
        year_value,
        month_of_year,
        Total_Sales,
        LAG(Total_Sales, 12, 0) OVER (ORDER BY year_value, month_of_year) AS Previous_Year_Sales
    FROM MonthlySales
)
SELECT
    year_value AS Tahun,
    month_of_year AS Bulan,
    Total_Sales AS Total_Nominal_Bulan_Ini,
    Previous_Year_Sales AS Total_Nominal_Tahun_Lalu_Bulan_Sama,
    CASE
        WHEN Previous_Year_Sales = 0 THEN NULL -- Atau 100% jika dianggap pertumbuhan dari 0
        ELSE (Total_Sales - Previous_Year_Sales) * 100.0 / Previous_Year_Sales
    END AS Persentase_Pertumbuhan_YoY
FROM LaggedSales
ORDER BY
    Tahun,
    Bulan;

SELECT
    p.product_category AS Kategori_Produk,
    ft.payment_method AS Metode_Pembayaran,
    COUNT(ft.transaction_id) AS Jumlah_Transaksi_Mencurigakan
FROM fact_transactions ft
JOIN dim_product p ON ft.product_id_surrogate = p.product_id_surrogate
WHERE ft.is_fraud = TRUE -- Menggunakan TRUE untuk tipe data BOOLEAN di PostgreSQL
GROUP BY
    p.product_category,
    ft.payment_method
ORDER BY
    Jumlah_Transaksi_Mencurigakan DESC;

