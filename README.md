# Digital Payment Data Platform

Digital Payment Data Platform adalah project data engineering end-to-end yang mensimulasikan alur data transaksi digital dari source system sampai analytical data warehouse.

Project ini mencakup proses ingestion, data quality checking, quarantine untuk data invalid, transformation, data warehouse modeling, orchestration dengan Apache Airflow, monitoring, automated testing, dan CI menggunakan GitHub Actions.

---

## 1. Project Overview

Dataset dibuat secara sintetis untuk merepresentasikan beberapa entitas utama:

- Users
- Wallets
- Merchants
- Transactions
- Transaction Types
- Payment Methods
- Transaction Statuses

Alur utama pipeline:

Synthetic Data
↓
Operational Source
↓
Raw Layer
↓
Data Quality & Quarantine
↓
Staging Layer
↓
Analytics / Data Warehouse
↓
Business Queries

Pipeline lokal diorkestrasi menggunakan Apache Airflow.

---

## 2. Objectives

Project ini dibuat untuk mempraktikkan beberapa komponen yang umum digunakan dalam data engineering:

- Data ingestion menggunakan Python dan SQL
- Relational database design
- ETL / ELT pipeline
- Data quality validation
- Quarantine untuk data invalid
- Data transformation
- Data warehouse modeling
- Star schema
- Apache Airflow orchestration
- Pipeline monitoring
- Automated testing dengan pytest
- Continuous Integration menggunakan GitHub Actions
- Docker-based local environment

---

## 3. Architecture

Arsitektur lokal project:

Synthetic Data Generator
        ↓
data/source_seed/*.csv
        ↓
PostgreSQL source.*
        ↓
Extract
        ↓
PostgreSQL raw.*
        ↓
Data Quality Check
        ↓
Quarantine Invalid Records
        ↓
Quality Threshold
        ↓
PostgreSQL staging.*
        ↓
Transform
        ↓
PostgreSQL analytics.*
        ↓
Business Queries

Task Airflow:

start_monitoring
        ↓
extract_source_to_raw
        ↓
quarantine_invalid_transactions
        ↓
check_quality_threshold
        ↓
load_staging
        ↓
load_dimensions
        ↓
load_fact_transactions

---

## 4. Technology Stack

| Technology | Usage |
|---|---|
| Python | Data generation, ingestion, validation, monitoring |
| PostgreSQL | Source, raw, staging, analytics warehouse |
| SQLAlchemy | Database connection dari Python |
| SQL | Validation, transformation, warehouse modeling |
| Docker | Menjalankan PostgreSQL dan Airflow |
| Docker Compose | Mengatur service lokal |
| Apache Airflow | Pipeline orchestration |
| pytest | Automated testing |
| Git | Version control |
| GitHub Actions | Continuous Integration |
| Pandas | Synthetic data generation dan profiling |
| NumPy | Data distribution dan random generation |

---

## 5. Data Layers

### Source Layer

Schema:

source.*

Source layer mensimulasikan operational database dari aplikasi pembayaran digital.

Tables:

source.users
source.wallets
source.merchants
source.transaction_types
source.payment_methods
source.transaction_statuses
source.transactions

Data awal dibuat menggunakan synthetic data generator lalu dimasukkan ke PostgreSQL.

### Raw Layer

Schema:

raw.*

Raw layer berfungsi sebagai landing area hasil ingestion dari source.

Tables:

raw.users
raw.wallets
raw.merchants
raw.transaction_types
raw.payment_methods
raw.transaction_statuses
raw.transactions

Raw layer menggunakan constraint minimal supaya data bermasalah tetap bisa diterima dan diperiksa pada tahap berikutnya.

Setiap table memiliki metadata:

ingested_at

### Quarantine Layer

Schema:

quarantine.*

Data invalid tidak langsung dibuang. Record yang gagal quality rule disimpan di:

quarantine.transactions

Informasi yang disimpan meliputi:

transaction_id
validation_rule
failure_reason
quarantined_at

Contoh validation rule:

POSITIVE_AMOUNT
VALID_USER
VALID_WALLET
WALLET_OWNERSHIP
VALID_MERCHANT
TRANSFER_COUNTERPARTY
TRANSFER_SELF
PAYMENT_MERCHANT
WALLET_TEMPORAL
MERCHANT_TEMPORAL

Dengan cara ini, data invalid masih bisa diperiksa tanpa masuk ke downstream layer.

---

## 6. Data Quality Threshold

Pipeline menggunakan threshold untuk menentukan apakah jumlah data invalid masih bisa ditoleransi.

Default threshold:

5%

Contoh hasil:

Raw transactions          : 100,003
Quarantined transactions  : 3
Valid transactions        : 100,000
Invalid ratio             : 0.0030%
Threshold                 : 5.00%

Karena invalid ratio masih di bawah threshold, pipeline tetap dilanjutkan.

Jika invalid ratio melebihi 5%, pipeline dihentikan sebelum data masuk ke staging.

---

## 7. Staging Layer

Schema:

staging.*

Staging layer berisi data yang sudah dibersihkan dan distandardisasi.

Transformasi yang dilakukan antara lain:

- TRIM pada string
- UPPER untuk status atau kode tertentu
- LOWER untuk email
- Normalisasi empty string menjadi NULL
- Exclude transaksi yang sudah masuk quarantine

Secara sederhana:

staging transactions
=
raw transactions
-
quarantined transactions

---

## 8. Analytics Layer

Schema:

analytics.*

Analytics layer menggunakan star schema.

Core tables:

analytics.dim_users
analytics.dim_merchants
analytics.dim_transaction_types
analytics.dim_date
analytics.fact_transactions

Struktur sederhananya:

dim_users
    |
    |
fact_transactions
    |
    +---- dim_merchants
    |
    +---- dim_transaction_types
    |
    +---- dim_date

---

## 9. Fact and Dimension

Dimension table menyimpan informasi deskriptif.

Contoh:

dim_users

berisi:

user_id
full_name
city
registration_date
status

Fact table menyimpan business event utama.

Dalam project ini:

fact_transactions

berisi informasi seperti:

transaction_id
date_key
user_key
merchant_key
transaction_type_key
amount
transaction_timestamp
channel

---

## 10. Surrogate Key

Source system menggunakan ID seperti:

U000123
M000040

Di analytics layer dibuat juga internal key seperti:

user_key
merchant_key
transaction_type_key

Contoh:

user_key | user_id
---------+---------
1        | U000001
2        | U000002

user_id tetap digunakan sebagai business key dari source, sedangkan user_key digunakan sebagai internal key di data warehouse.

---

## 11. Airflow Orchestration

DAG utama:

digital_payment_pipeline

Task flow:

start_monitoring
        ↓
extract_source_to_raw
        ↓
quarantine_invalid_transactions
        ↓
check_quality_threshold
        ↓
load_staging
        ↓
load_dimensions
        ↓
load_fact_transactions

Jika salah satu task gagal, downstream task tidak dijalankan.

DAG dapat di-trigger manual melalui Airflow UI.

---

## 12. Pipeline Monitoring

Pipeline run dicatat ke:

monitoring.pipeline_run_log

Kolom yang dicatat:

run_id
pipeline_name
status
started_at
finished_at
rows_processed
error_message

Status yang digunakan:

RUNNING
SUCCESS
FAILED

Monitoring ini dipakai untuk melihat histori execution pipeline dan jumlah row yang berhasil diproses.

---

## 13. Automated Testing

Automated testing menggunakan pytest.

Test yang tersedia antara lain:

- Source-to-raw consistency
- Staging row-count consistency
- Quarantine exclusion
- Staging-to-fact consistency
- Fact table tidak kosong
- Transaction amount harus positif
- User key integrity
- Merchant key integrity
- Transaction type key integrity
- Date key integrity
- Data quality threshold

Run locally:

pytest -v

---

## 14. Controlled Bad Data Test

Untuk menguji quarantine flow, tersedia fixture:

sql/tests/01_inject_bad_transactions.sql

File ini memasukkan beberapa transaksi yang sengaja dibuat invalid.

Contoh:

BAD_TX_001
- negative amount

BAD_TX_002
- invalid wallet

BAD_TX_003
- transfer tanpa counterparty

Expected flow:

100,000 source transactions
↓
100,000 raw
↓
inject 3 bad transactions
↓
100,003 raw
↓
3 quarantined
↓
100,000 staging
↓
100,000 fact

Bad transaction tetap disimpan di quarantine dan tidak masuk ke staging maupun analytics.

---

## 15. Continuous Integration

GitHub Actions digunakan untuk menjalankan end-to-end pipeline test setiap push atau pull request ke branch main.

CI melakukan:

Start PostgreSQL
↓
Create schemas and tables
↓
Generate synthetic data
↓
Load source
↓
Extract source to raw
↓
Inject controlled bad data
↓
Quarantine invalid records
↓
Check quality threshold
↓
Load staging
↓
Load analytics warehouse
↓
Run pytest

Workflow:

.github/workflows/ci.yml

---

## 16. Project Structure

digital-payment-data-platform/
│
├── dags/
│   └── digital_payment_pipeline.py
│
├── data/
│   ├── source_seed/
│   ├── raw/
│   ├── processed/
│   └── quarantine/
│
├── notebooks/
│   └── 01_profile_generated_data.ipynb
│
├── sql/
│   ├── source/
│   ├── raw/
│   ├── staging/
│   ├── analytics/
│   ├── validation/
│   ├── quarantine/
│   ├── monitoring/
│   └── tests/
│
├── src/
│   ├── ingestion/
│   ├── validation/
│   ├── transformation/
│   └── monitoring/
│
├── tests/
│   └── test_pipeline_data.py
│
├── docs/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── docker-compose.yml
├── requirements.txt
├── .gitignore
└── README.md

---

## 17. Running Locally

Clone repository:

git clone <repository-url>
cd digital-payment-data-platform

Create virtual environment:

py -m venv .venv
.venv\Scripts\activate

Install dependencies:

pip install -r requirements.txt

Start infrastructure:

docker compose up -d

Services:

PostgreSQL
Airflow

PostgreSQL host:

127.0.0.1:55432

Airflow UI:

http://localhost:8080

Run tests:

pytest -v

Run pipeline:

Buka Airflow UI lalu trigger DAG:

digital_payment_pipeline

---

## 18. Example Business Queries

Analytics warehouse digunakan untuk beberapa query seperti:

- Transaction volume per hari
- Transaction value berdasarkan transaction type
- Aktivitas transaksi berdasarkan kota user
- Top merchant category
- Top merchant berdasarkan transaction value
- Monthly transaction trend
- Weekday vs weekend activity
- Transaction activity berdasarkan channel
- Top users berdasarkan transaction value

Query tersedia di:

sql/analytics/04_business_queries.sql

---

## 19. Current Status

Local MVP:

Synthetic Data Generation   : Done
PostgreSQL Source           : Done
Raw Layer                   : Done
Data Quality Validation     : Done
Quarantine Handling         : Done
Quality Threshold           : Done
Staging Transformation      : Done
Star Schema                 : Done
Business Queries            : Done
Airflow Orchestration       : Done
Pipeline Monitoring         : Done
pytest                      : Done
GitHub Actions CI           : Done

Next development:

- Google Cloud Storage
- BigQuery
- Cloud deployment
- Architecture diagram
- Additional monitoring metrics
- Incremental ingestion

---

## 20. Future Cloud Architecture

Planned cloud extension:

Operational Source
        ↓
Airflow
        ↓
Google Cloud Storage
        ↓
BigQuery Raw
        ↓
BigQuery Staging
        ↓
BigQuery Analytics
        ↓
Dashboard / Analytics

Local MVP diselesaikan terlebih dahulu sebelum pipeline dikembangkan ke cloud.
