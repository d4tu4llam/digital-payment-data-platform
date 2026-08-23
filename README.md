# Digital Payment Data Platform

An end-to-end data engineering project that simulates a digital wallet and payment data platform.

The project is designed to demonstrate how transactional data can be generated, stored, validated, transformed, modeled, orchestrated, monitored, and prepared for analytics in a production-like data engineering workflow.

---

## Objective

Build a reliable and scalable data platform for synthetic digital payment transactions.

The project focuses on:

* Data ingestion
* ETL / ELT pipelines
* Data quality validation
* Relational data modeling
* Data warehouse modeling
* Workflow orchestration
* Pipeline monitoring
* Cloud-based data platforms
* Automation
* Testing
* CI/CD
* Technical documentation

The overall architecture is designed to resemble the responsibilities commonly handled by a Data Engineering or Data Warehouse team in a fintech environment.

---

## Project Scope

The platform simulates several types of digital-wallet transactions:

* Payment
* Transfer
* Top Up
* Withdrawal
* Refund
* Bill Payment

The synthetic source system contains:

* Users
* Wallets
* Merchants
* Transactions
* Transaction Types
* Payment Methods
* Transaction Statuses

The generated dataset is designed to include realistic variation in:

* User registration dates
* Merchant onboarding dates
* Transaction timestamps
* Transaction amounts
* Merchant categories
* Merchant sizes
* Transaction types
* Payment methods
* Transaction statuses
* Transaction channels

---

## Planned Architecture

```text
Synthetic Data Generator
          │
          ▼
   PostgreSQL Source
          │
          ▼
       Raw Layer
          │
          ▼
 Data Quality Validation
          │
     ┌────┴────┐
     ▼         ▼
   Valid     Invalid
     │         │
     ▼         ▼
  Staging   Quarantine
     │
     ▼
 Transformation
     │
     ▼
 Data Warehouse
     │
     ▼
 Analytical Models
     │
     ▼
 Analytics / Dashboard
```

The pipeline will later be orchestrated and monitored using Apache Airflow.

Cloud components will include Google Cloud Storage and BigQuery.

---

## Technology Stack

### Programming

* Python
* SQL
* Bash

### Database and Data Warehouse

* PostgreSQL
* BigQuery

### Workflow Orchestration

* Apache Airflow

### Cloud

* Google Cloud Platform
* Google Cloud Storage
* BigQuery

### Containerization

* Docker
* Docker Compose

### Testing

* pytest

### Version Control and CI/CD

* Git
* GitHub
* GitHub Actions

### Monitoring and Automation

* Python automation scripts
* Pipeline monitoring
* Logging
* Data quality checks
* Alerting

---

## Current Relational Data Model

The operational source database is normalized into several related tables.

```text
users
  │
  │ 1:1
  ▼
wallets
  │
  │ 1:N
  ▼
transactions
  │
  ├── merchants
  ├── transaction_types
  ├── payment_methods
  └── transaction_statuses
```

The `transactions` table also references `users` through `counterparty_user_id` for user-to-user transfers.

### Main Relationships

```text
users 1 ─── 1 wallets

users 1 ─── N transactions

wallets 1 ─── N transactions

merchants 1 ─── N transactions

transaction_types 1 ─── N transactions

payment_methods 1 ─── N transactions

transaction_statuses 1 ─── N transactions
```

For transfer transactions:

```text
transactions.user_id
        │
        ▼
     sender user

transactions.counterparty_user_id
        │
        ▼
    receiver user
```

---

## Data Layers

The project separates data processing into multiple layers.

### Source

Represents the simulated transactional application database.

```text
source.users
source.wallets
source.merchants
source.transactions
source.transaction_types
source.payment_methods
source.transaction_statuses
```

### Raw

Stores extracted data with minimal modification.

Purpose:

* Preserve source data
* Enable reprocessing
* Support auditing
* Maintain historical ingestion records

### Staging

Contains cleaned and standardized data before warehouse transformation.

Typical operations include:

* Data type conversion
* Deduplication
* Standardization
* Validation
* Null handling

### Analytics

Contains analytical models designed for reporting and business analysis.

Planned warehouse model:

```text
                       dim_users
                           │
                           │
                           ▼
dim_merchants ──── fact_transactions ──── dim_date
                           │
                    ┌──────┴──────┐
                    ▼             ▼
          dim_transaction   dim_payment
              _types          _methods
```

---

## Project Structure

```text
digital-payment-data-platform/
│
├── src/
│   ├── ingestion/
│   ├── transformation/
│   ├── validation/
│   └── monitoring/
│
├── dags/
├── scripts/
├── sql/
├── tests/
├── notebooks/
├── docs/
├── data/
│   ├── raw/
│   ├── processed/
│   └── quarantine/
│
├── docker-compose.yml
├── requirements.txt
├── .gitignore
└── README.md
```

### Directory Responsibilities

`src/ingestion/`

Responsible for generating, extracting, and loading source data.

`src/transformation/`

Contains transformation logic used to clean and prepare data.

`src/validation/`

Contains data quality and business-rule validation logic.

`src/monitoring/`

Contains pipeline health checks, metrics, and monitoring logic.

`dags/`

Contains Apache Airflow DAG definitions.

`sql/`

Contains database schema, seed data, transformations, warehouse models, and analytical queries.

`scripts/`

Contains operational and automation scripts.

`tests/`

Contains automated unit and integration tests.

`notebooks/`

Contains exploratory data profiling and validation notebooks.

`data/`

Contains locally generated raw, processed, and quarantined datasets.

`docs/`

Contains technical documentation, architecture diagrams, runbooks, and troubleshooting guides.

---

## Current Progress

### Completed

* Python virtual environment
* Project directory structure
* Docker environment
* PostgreSQL container
* PostgreSQL connectivity from Python
* Database schemas
* Relational source model
* Primary key and foreign key relationships
* Lookup tables
* Source indexes
* Synthetic users
* Synthetic wallets
* Synthetic merchants
* Synthetic digital-wallet transactions
* Multiple transaction types
* Temporal transaction constraints
* Realistic transaction distributions

### Current Dataset

```text
Users        : 10,000
Wallets      : 10,000
Merchants    : 1,000
Transactions : 100,000
```

Current transaction types:

```text
PAYMENT
TRANSFER
TOP_UP
WITHDRAWAL
REFUND
BILL_PAYMENT
```

### In Progress

* Data profiling
* Referential integrity verification
* Business-rule validation
* Temporal validation

### Planned Next Steps

1. Profile generated source data
2. Validate relational consistency
3. Load synthetic data into PostgreSQL source tables
4. Build raw ingestion layer
5. Implement data quality rules
6. Create quarantine handling
7. Build staging transformations
8. Create analytical star schema
9. Implement analytical SQL
10. Add Apache Airflow orchestration
11. Add pipeline monitoring and retries
12. Add Python automation
13. Add automated tests
14. Add GitHub Actions CI
15. Integrate Google Cloud Storage
16. Integrate BigQuery
17. Build analytical dashboard
18. Complete technical documentation

---

## Project Status

**Current Phase:** Synthetic source data generation and validation.

The core relational model and synthetic transaction generator are operational. The next phase focuses on profiling the generated datasets and validating referential, temporal, and business-rule consistency before ingestion into PostgreSQL source tables.
