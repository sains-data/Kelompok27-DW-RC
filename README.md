# Proyek Perancangan Data Warehouse Fintech 'DompetImut'

## Deskripsi Proyek

DompetImut adalah perusahaan *fintech* yang menyediakan layanan dompet digital, terutama ditujukan untuk masyarakat urban dan generasi milenial di Indonesia. Layanan yang ditawarkan meliputi kemudahan dalam bertransaksi seperti pembayaran kepada *merchant*, transfer antar pengguna, pembelian pulsa, serta integrasi dengan *e-commerce*. Seiring pertumbuhannya, DompetImut menghadapi tantangan terkait integrasi data yang tersebar, yang menghambat analisis *real-time* dan deteksi penipuan.

Proyek *data warehouse* ini bertujuan untuk:
* Membangun sistem terpusat untuk mengkonsolidasikan data dari berbagai sumber guna memastikan konsistensi dan kemudahan akses untuk analisis menyeluruh.
* Mengembangkan analitik lanjutan untuk memahami pola penggunaan, melakukan segmentasi pelanggan secara akurat, serta merancang strategi retensi dan promosi yang lebih efektif.
* Menyediakan sistem otomatis untuk mendeteksi anomali transaksi secara *real-time* dan meminimalkan risiko penipuan.
* Membangun *dashboard* interaktif yang mudah diakses oleh *stakeholder* non-teknis dan mengotomatiskan proses pelaporan.
* Mengembangkan infrastruktur data yang skalabel dan fleksibel.

## Fitur Utama

* **Pipeline ETL (Extract, Transform, Load) Komprehensif**: Mengintegrasikan data dari berbagai sumber (database operasional, file CSV, API eksternal), membersihkan, mentransformasi (termasuk derivasi atribut `is_fraud`), dan memuatnya ke dalam *data warehouse*. Menggunakan arsitektur berlapis (Raw, Silver, Gold Zone).
* **Pemodelan Data dengan Skema Bintang (*Star Schema*)**: Data di *Gold Zone* dimodelkan menggunakan *star schema* dengan tabel fakta utama `fact_transactions` dan tabel dimensi (`dim_user`, `dim_time`, `dim_location`, `dim_product`, `dim_merchant`, `dim_device`) untuk optimalisasi kueri analitik.
* **Kapabilitas OLAP (Online Analytical Processing)**: Memungkinkan analisis multidimensi data untuk menggali *insight* bisnis, seperti tren transaksi, segmentasi pelanggan, dan analisis produk.
* **Deteksi Penipuan**: Sistem dirancang untuk mendukung identifikasi transaksi mencurigakan melalui atribut `is_fraud` dan analisis pola.
* **Pelaporan dan Visualisasi Interaktif**: Menyediakan *dashboard* dan laporan melalui Power BI dan SSRS untuk berbagai *stakeholder*.

## Arsitektur Data Warehouse

Arsitektur *data warehouse* DompetImut terdiri dari tiga zona utama:
1.  **Raw Zone (Bronze Layer)**: Menyimpan data mentah yang diekstrak dari berbagai sistem sumber tanpa modifikasi signifikan.
2.  **Silver Zone (Cleaned Zone)**: Data dari *Raw Zone* dibersihkan, dinormalisasi, dan ditransformasi. Proses ini termasuk penanganan nilai hilang, standarisasi format, dan penambahan atribut turunan seperti `is_fraud`.
3.  **Gold Zone (Curated Zone)**: Data yang telah bersih dan terstruktur dimodelkan menggunakan pendekatan *Star Schema*. Zona ini menjadi sumber utama untuk analitik dan pelaporan.

**Diagram Skema Bintang:**
![image](https://github.com/user-attachments/assets/fe55b8ec-2059-4631-8fc4-c226fa97d6de)

## Setup dan Penggunaan

### 1. Setup Database
* Pastikan Anda memiliki instance SQL Server yang berjalan.
* Jalankan skrip DDL dari direktori `sql_scripts/` untuk membuat skema *data warehouse* (dimensi, fakta, dan staging jika diperlukan). Urutan:
    1.  `pembuatan data warehouse.sql`
    2.  `etl.sql`
    3.  (Opsional) `create_staging_tables.sql` jika Anda akan memuat data mentah ke staging terlebih dahulu.
* Jalankan skrip `sql_scripts/Indexes/create_indexes.sql` untuk membuat indeks pada tabel.

### 2. Proses ETL
* **Sumber Data**: Siapkan data sumber Anda (misalnya, file CSV, atau koneksi ke database operasional). Sesuaikan struktur tabel staging (`sql_scripts/DDL/create_staging_tables.sql`) dan skrip ETL DML (`sql_scripts/DML_ETL/`) agar cocok dengan sumber data Anda.
* **Eksekusi ETL**:
    * Jika menggunakan **SSIS**: Buka dan jalankan paket SSIS.
    * Jika menggunakan **Skrip SQL**:
        1.  Muat data mentah Anda ke dalam tabel staging.
        2.  Jalankan skrip transformasi pada data staging.
        3.  Jalankan skrip pemuatan dari staging ke tabel dimensi dan fakta.

### 3. Analisis Data (OLAP)
* Setelah data dimuat ke *data warehouse*, Anda dapat menjalankan kueri analitik dari direktori `sql_scripts/OLAP_Queries/` (misalnya, `analysis_queries.sql`) menggunakan SSMS atau alat kueri SQL lainnya yang terhubung ke *data warehouse* DompetImut.
* Data juga dapat diakses melalui SSAS Cube dan divisualisasikan menggunakan Power BI[cite: 1, 106].

## Tim Proyek (Kelompok 27 RC) [cite: 1, 171]

| Nama                    | NIM       | Peran   |
| ----------------------- | --------- | ------- |
| RANDA ANDRIANA PUTRA    | 122450083 | Ketua   |
| PUTRI MAULIDA CHAIRANI  | 121450050 | Anggota |
| ELILYA OCTAVIANI        | 122450009 | Anggota |
| IRHAMNA MAHDI           | 122450049 | Anggota |
| RAFLY PRABU DARMAWAN    | 122450140 | Anggota |

---
