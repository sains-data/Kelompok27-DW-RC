TUGAS MISI KETIGA
PERANCANGAN DAN IMPLEMENTASI GUDANG DATA



 


Disusun oleh : 

KELOMPOK 27 
RC



Putri Maulida Charani
Elilya Octaviani
Irhamna Mahdi
Randa Andriana Putra
Rafly Prabu Darmawan

121450050
122450009
122450049
122450083
122450140



PROGRAM STUDI SAINS DATA
FAKULTAS SAINS
INSTITUT TEKNOLOGI SUMATERA
LAMPUNG SELATAN
2025
Alur Aliran Data
	Aliran data menggambarkan proses transformasi data dari sumber mentah menjadi siap digunakan untuk analisis bisnis. Diagram ini secara rinci menjelaskan alur untuk Data Warehouse DompetImut dengan mengacu pada arsitektur dan metode ETL (Extract, Transform, Load). 

Aliran data DompetImut dimulai dari dua sumber utama, yaitu basis data operasional (tabel Pengguna, Transaksi, Layanan) dan API eksternal (data geolokalisasi, pedagang dan transaksi pihak ketiga). Data dari kedua sumber ini diekstrak melalui SSIS atau Azure Data Factory dan kemudian disimpan dalam format mentah di Zona Mentah tanpa modifikasi. Di Silver Layer (Zona Bersih), data dibersihkan dan diubah. Proses ini termasuk menormalkan format, menangani data yang hilang, menormalkan alamat, dan menambahkan atribut seperti is_fraud untuk mendeteksi transaksi yang mencurigakan. Data yang telah dibersihkan dan terstruktur diproses ke Gold Layer (Curated Zone) menggunakan model Star Schema, dengan tabel fakta (fact_transactions) dan tabel dimensi (dim_user, dim_time, dim_location). Fase ini juga mencakup agregasi dan optimisasi, seperti partisi waktu dan pembuatan indeks. Dari Gold Layer, data digunakan oleh SSAS untuk analisis multidimensi dan oleh Power BI untuk visualisasi interaktif seperti peta transaksi yang mencurigakan dan analisis perilaku pengguna. Hasil analisis ini menjadi dasar pengambilan keputusan oleh berbagai pihak, seperti manajemen, tim risiko, pemasaran, analis data, pengembang produk, dan investor, sesuai dengan kebutuhan strategis masing-masing.

Arsitektur
Arsitektur dirancang untuk mengelola volume data yang besar, memastikan keamanan dan integritas data, serta mendukung kebutuhan analitik yang kompleks secara efisien. 

Data Source
Data Source merupakan lapisan awal yang berisi sumber data utama. Dalam kasus ini, data berisi rekapan transaksi sistem dompet digital. 

Staging Area 
Staging berfungsi sebagai tempat menampung data mentah dari berbagai sumber. Pada tahap ini, dilakukan proses data cleansing, validasi struktur data, penghapusan entri duplikat, dan normalisasi format. Staging Area menjaga integritas dan kualitas data sebelum dilanjutkan ke proses ETL. 
ETL Layer (Extract, Transform, Load)
Tahap ETL menghubungkan staging dengan data warehouse. Data diekstrak lalu ditransformasikan menggunakan python (termasuk parsing tanggal transaksi, pengelompokkan jenis pembayaran), dan pembentukan surrogate key waktu. Setelah data siap, selanjutnya dimuat ke database penyimpanan utama.
Data Warehouse Layer
Semua data yang sudah siap dikumpulkan di gudang data. Desainnya menggunakan skema bintang (star schema), jadi ada satu tabel utama yang menyimpan data transaksi dan beberapa tabel pendukung seperti pengguna atau waktu. Sistem ini dirancang agar pencarian data jadi cepat dan efisien.
BI Layer 
Data ditampilkan ke pengguna dalam bentuk visualisasi dengan alat seperti Metabase atau Poser BI, yang mempermudah proses pengambilan keputusan dengan menampilkan grafik, filter, atau laporan dari gudang data.


ETL Pipeline
(a). Extract

Sumber Data:
Basis Data Operasional (SQL Server): Tabel Users, Transactions, Services.
API Eksternal: Data Geolokasi, Merchant, Transaksi Pihak Ketiga.
Alat Extract:
SQL Server Integration Services (SSIS) untuk mengambil data dari sistem operasional.
Azure Data Factory untuk API eksternal.
Python + Requests untuk ekstraksi data berbasis API.
Proses Extract:
Jalankan koneksi ke database SQL Server dan lakukan query untuk mengekstrak data transaksi terbaru.
Lakukan pemanggilan API eksternal untuk mendapatkan data merchant, lokasi, dan transaksi pihak ketiga.
Simpan semua data mentah ke Staging Area dalam format CSV atau Parquet.
(b). Transform
Proses Pembersihan & Normalisasi Data:
Menghapus duplikasi dan entri kosong.
Menormalkan alamat pengguna menggunakan library Geopy.
Parsing tanggal transaksi untuk format yang seragam.
Menambahkan atribut is_fraud berdasarkan deteksi pola anomali.
Alat Transform:
Pandas & PySpark untuk normalisasi dan transformasi data.
SQL untuk validasi dan integrasi data.
Scikit-learn untuk flagging is_fraud (deteksi transaksi mencurigakan).
Proses Transform:
Normalisasi data pengguna (alamat, geolokasi).
Kelompokkan jenis pembayaran (e-wallet, transfer bank, kartu kredit).
Identifikasi pola transaksi yang mencurigakan dan tandai dengan is_fraud.
Mapping data ke dalam struktur Star Schema:
Fact Table: fact_transactions
Dimension Tables: dim_user, dim_time, dim_location
(c). Load
Gudang Data & Struktur Penyimpanan
Database utama: SQL Server Data Warehouse.
Penyimpanan terstruktur: Star Schema untuk akses cepat.
Partisi data berdasarkan waktu transaksi untuk optimasi query.
Alat Load:
SSIS untuk loading batch data ke database.
SQL Server Management Studio (SSMS) untuk indexing dan partisi data.
Proses Load:
Memuat tabel Fact Transactions dengan atribut transaksi yang telah dibersihkan.
Memuat tabel Dimensi dengan atribut terkait pengguna, waktu, dan lokasi.
Optimasi Indexing untuk mempercepat analisis query.
(d). BI & Analitik
Visualisasi & Analitik
SQL Server Analysis Services (SSAS): Model OLAP untuk analitik multidimensi.
Power BI & Metabase: Dashboard interaktif untuk analisis transaksi dan fraud map.
Proses BI:
SSAS melakukan agregasi berdasarkan lokasi transaksi dan deteksi pola fraud.
Power BI menampilkan peta interaktif dari distribusi transaksi dan pola pembayaran.
Dashboard memberikan wawasan kepada manajemen, tim risiko, dan investor untuk pengambilan keputusan.


Fact Table: fact_transactions (Berisi data utama terkait transaksi yang dilakukan oleh pengguna).
Column Name
Data Type
Description
Transaction_id
INT (FK)
ID unik transaksi
user_id
INT (FK)
Referensi ke pengguna
time_id
INT (FK)
Referensi ke waktu transaksi
location_id
INT (FK)
Referensi ke lokasi transaksi
service_id
INT (FK)
Referensi ke layanan terkait
amount
DECIMAL (10,2)
Nominal transaksi
payment_type
VARCHAR (50)
Jenis pembayaran
is_fraud
BOOLEAN






Alat
SQL Server Integration Service (SSIS)
SSIS adalah alat utama dalam proses Extract, Transform, dan Load (ETL) yang digunakan dalam pengembangan gudang data DompetImut. SSIS memungkinkan ekstraksi data dari berbagai sumber data operasional seperti SQL Server dan mendukung pengambilan data dari API eksternal melalui komponen script. Selain itu, SSIS memungkinkan proses transformasi data seperti pembersihan, penghapusan duplicate, dan pengolahan data menjadi format yang lebih terstruktur. Selanjutnya, hasil transformasi dimuat ke area pengujian atau langsung ke gudang data. SSIS memungkinkan penggunaan SQL Server Agent untuk membuat paket ETL yang terjadwal secara otomatis.

Database Engine
Pengelolaan dan penyimpanan gudang data DompetImut bergantung pada Database Engine. Struktur data dirancang untuk implementasi menggunakan model skema bintang. Di dalam model ini, terdapat tabel fakta utama yang disebut fact_transactions yang menyimpan semua data transaksi yang telah diproses melalui proses ETL, termasuk atribut transaksi, jumlah, dan jenis pembayaran, serta flag yang mendeteksi transaksi penipuan (is_fraud). Beberapa tabel dimensi terhubung ke tabel fakta seperti dim_user menyimpan informasi pengguna lengkap, dim_time menyimpan data dimensi tanggal, dan dim_location menyimpan data dimensi lokasi. Database Engine juga memiliki fitur partisi data berdasarkan waktu transaksi, yang memungkinkan query dilakukan lebih cepat karena data dapat difokuskan pada rentang waktu tertentu tanpa memindai tabel secara keseluruhan. Selain itu, kolom-kolom penting seperti transaction_id, user_id, dan date_id diindeks untuk mempercepat pencarian dan analisis data. Untuk memastikan gudang data DompetImut tetap aman dan tersedia meskipun terjadi gangguan sistem, fitur backup dan restore Database Engine juga digunakan. Database Engine mengatur semua pengaturan keamanan akses data.

SQL Server Analysis Service (SSAS)
SSAS digunakan untuk memetakan data yang telah disimpan di gudang data ke dalam cube. Cube ini memiliki tabel fakta fact_transactions yang berfungsi sebagai pusat data transaksi, dan tabel dimensi seperti dim_user, dim_time, dan dim_location yang membantu menganalisis data berdasarkan dimensi, waktu, dan lokasi pengguna. SSAS juga memungkinkan pembuatan kalkulasi agregat, seperti total transaksi per jenis pembayaran atau per lokasi, serta hierarki waktu seperti tahun, kuartal, bulan, dan hari. Selain itu, SSAS memungkinkan integrasi fitur deteksi pola transaksi mencurigakan (is_fraud) sebagai indikator analitik. Cube kemudian digunakan sebagai sumber data untuk Power BI dan Metabase untuk mendukung visualisasi dan proses pengambilan keputusan tim risiko, pemasaran, dan manajemen.

SQL Server Reporting Services (SSRS)
Laporan interaktif yang dibuat dengan SSRS dapat diakses secara online melalui portal internal organisasi DompetImut atau secara berkala dikirimkan melalui email kepada pihak yang bertanggung jawab. SSRS digunakan untuk membuat laporan seperti rekapitulasi transaksi bulanan, pengenalan jumlah transaksi mencurigakan per kota, dan laporan performa pengguna aktif bulanan. Dengan menggunakan query SQL yang telah dioptimalkan, laporan ini dibuat dengan mengambil data langsung dari tabel-tabel data gudang dan dari cube SSAS. Dengan SSRS, DompetImut dapat menyediakan laporan yang terstandarisasi, akurat, dan mudah dipantau untuk membantu proses audit internal dan evaluasi performa bisnis.

SQL Server Management Studio (SSMS)
Seluruh infrastruktur gudang data DompetImut dikelola oleh SQL Server Management Studio (SSMS). SSMS digunakan untuk menjalankan query SQL yang kompleks untuk memantau kualitas data transaksi, mengelola indeks dan partisi pada tabel fact_transactions, dan menangani kesalahan proses ETL atau kegagalan pemuatan data. Selain itu, SSMS juga digunakan untuk mengelola pembantu SQL Server, yang menjadwalkan eksekusi otomatis untuk memproses data transaksi baru dari API eksterna dan sistem operasional. SSMS juga memudahkan proses pengawasan kinerja query dan penggunaan resource server dalam mengoptimalkan kinerja sistem data warehouse agar tetap responsif dan stabil meskipun beban data terus meningkat.

Skrip Query
Realisasi Struktur Tabel dan Proses ETL
Berdasarkan desain pada bab 3, implementasi skema bintang direalisasikan dengan SQL DDL sebagai berikut :
-- Tabel Dimensi: Pengguna (User)
CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    user_email VARCHAR(100),
    user_phone VARCHAR(20)
    -- kolom tambahan jika perlu
);

-- Tabel Dimensi: Waktu (Time)
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date_value DATE,
    year INT,
    month INT,
    day INT,
    quarter INT
    -- kolom lain (mis. nama hari, minggu)
);

-- Tabel Dimensi: Lokasi (Location)
CREATE TABLE dim_location (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100)
    -- kolom lain (mis. kode pos)
);

-- Tabel Fakta: Transaksi
CREATE TABLE fact_transactions (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    time_id INT,
    location_id INT,
    amount DECIMAL(18,2),
    is_fraud BIT,
    -- kolom fakta tambahan (mis. jenis transaksi)
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);


DompetImut diproses melalui tiga tahapan utama:
Extract: Data diekstraksi dari sumber utama seperti file CSV atau API eksternal, yang mencakup informasi pengguna, layanan, transaksi, lokasi, serta data tambahan dari mitra pihak ketiga.
Transform: Data yang telah diekstrak kemudian dibersihkan, dinormalisasi, dan diklasifikasikan ke dalam entitas-entitas seperti pengguna, waktu, dan lokasi untuk membentuk tabel dimensi. Proses ini juga melibatkan penggabungan data, parsing tanggal, penambahan atribut is_fraud, serta agregasi data transaksi untuk disusun dalam struktur skema bintang.
Load: Setelah transformasi selesai, data dari masing-masing entitas dimuat ke dalam tabel dimensi, kemudian data transaksi dimuat ke dalam tabel fakta dengan relasi ke tabel dimensi melalui kunci asing, guna memastikan konsistensi dan integritas data dalam gudang data.
Evaluasi Kinerja dan Efisiensi Sistem
Metode pengujian digunakan untuk menilai seberapa efisien sistem data warehouse dalam menjalankan query analitik. Walaupun data yang digunakan dalam proyek ini tergolong kecil (sekitar 100 baris), pengujian tetap dilaksanakan untuk mengamati pengaruh penggunaan indeks dan partisi terhadap performa sistem. Pengujian dilakukan dalam dua skenario, yakni tanpa indeks pada tabel fakta dan setelah penerapan indeks pada kolom-kolom foreign key seperti Platform_ID, Year_ID, Genre_ID, dan Publisher_ID. Untuk mengukur performa query, waktu eksekusi dicatat menggunakan fungsi bawaan SQL seperti EXPLAIN ANALYZE guna memperoleh estimasi kinerja dari masing-masing skenario.
