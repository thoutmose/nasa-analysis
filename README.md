# 🌌 nasa-analysis

<div align="center">

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=Apache%20Airflow&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=for-the-badge&logo=postgresql&logoColor=white) ![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white) ![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=Docker&logoColor=white) ![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white) ![Ruff](https://img.shields.io/badge/Ruff-261230.svg?style=for-the-badge&logo=ruff&logoColor=white)

> **An end-to-end data engineering project that collects, transforms, and visualizes NASA space data — tracking near-Earth asteroids, solar flare activity, and historical meteorite impacts.**

</div>

---

## 🛠 The Modern Data Stack

This project leverages the **Modern Data Stack (MDS)** approach, emphasizing modular, best-in-class tools that are developer-friendly and code-first.

* **🚀 Apache Airflow (Orchestration)**  
  The command center of our data platform. Airflow allows us to author, schedule, and monitor workflows as code.
  > **Why we use it:** To orchestrate the sequence of ingestion, validation, and transformation tasks reliably.

* **📥 dlt | dlthub (Ingestion)**  
  A Python library for data loading. `dlt` (Data Load Tool) automates the extraction and loading (EL) process, handling complex API responses and schema evolution automatically.
  > **Why we use it:** To streamline loading nested JSON data from NASA APIs into PostgreSQL without manually maintaining schemas.

* **🏛️ dbt (Transformation)**  
  The transformation layer (the "T" in ELT). `dbt` (data build tool) allows us to transform data in the warehouse using SQL.
  > **Why we use it:** To clean, test, and model raw data into analytics-ready tables using modular SQL files and built-in version control.

---

## 📐 Architecture

<div align="center">
  <img src="img/nasa_data_engineering_project.png" alt="Architecture Schema" width="800">
</div>

### Architecture Overview
This project implements a **containerized data pipeline** orchestrated with Apache Airflow, supporting both development and production environments with identical structures and isolated infrastructure.

#### 🌍 Environments
The system is split into two parallel environments, each running on dedicated Ubuntu-based servers and utilizing Docker to ensure consistency, portability, and reproducibility:
* **Development:**  `srv-airflow-dev`
* **Production:** `srv-airflow-prod`

#### 🔄 Data Pipeline Flow
1. **Data Sources:** Primary integrations are NASA APIs, with additional internal/third-party files.
2. **Data Ingestion:** API data is extracted and normalized using `dlthub` within Airflow DAGs.
3. **Data Storage (Raw Layer):** Loads directly into an isolated PostgreSQL database (segregated by dev/prod).
4. **Data Transformation & Testing:** `dbt` models structure the data into refined sets for analytics, enforcing **data quality tests** (uniqueness, non-null, referential integrity).
5. **Orchestration:** Managed end-to-end by Airflow.

#### ⚙️ CI/CD & Operations
* **Deployment:** Distinct Dev (`dev` branch) and Prod (`main` branch) pipelines triggering automated DAG & dbt model updates.
* **Monitoring & Observability:** Metrics handled by **Grafana**, with integrated **Slack** alerting.
* **Code Quality:** **Ruff** enforces Python linting and formatting across the repository.

---

## 📊 Data Sources

| Source | API / File | Description |
| :--- | :--- | :--- |
| **NeoWs** | NASA NeoWs REST API | Near-Earth asteroid close-approach data |
| **DONKI** | NASA DONKI REST API | Solar flare and space weather events |
| **Meteorite Landings** | CSV (NASA Open Data) | Historical meteorite impact records |

---

## 💻 Tech Stack

| Layer | Tool | Version / Spec |
| :--- | :--- | :--- |
| **Orchestration** | Apache Airflow (CeleryExecutor) | `3.1.8` |
| **Ingestion** | dltHub | `1.23` |
| **Data Warehouse** | PostgreSQL | `17` |
| **Transformations** | dbt Core | `1.11.7` |
| **Message Broker** | Redis | `7.2` |
| **Code Quality** | Ruff | `0.15.7` |
| **DB Administration** | PgAdmin | `4.9.13` |
| **Monitoring** | Grafana | `12.4.1` |
| **Language** | Python | `≥ 3.13` |

---

## 📁 Project Structure

```text
nasa-analysis/
├── config/               # Airflow configuration files
├── dags/                 # Airflow DAG definitions
├── logs/                 # Airflow task logs (gitignored)
├── plugins/              # Custom Airflow plugins
├── utils/
│   └── build.sh          # Environment-aware startup script
├── docker-compose.yaml   # All services definition
├── pyproject.toml        # Dependencies and Ruff config
└── requirements.txt      # Root requirements
```

---

## 🚦 Getting Started

### 1. Prerequisites
* **Docker** and **Docker Compose**
* **Git**
* A [NASA API key](https://api.nasa.gov/) *(free)*

### 2. Environment Setup
The project uses branch-based environment files:
* `dev` branch uses `.env.dev`
* `main` branch uses `.env.prod`

Create the appropriate env file by copying the example and filling in the required values:
```bash
cp .env.example .env.dev 
```

<details>
<summary><b>Click here to see required environment variables</b></summary>
<br>

```dotenv
# Airflow database
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=
AIRFLOW__CELERY__RESULT_BACKEND=
AIRFLOW__CORE__FERNET_KEY=

# PostgreSQL
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# Airflow admin user
_AIRFLOW_WWW_USER_USERNAME=
_AIRFLOW_WWW_USER_PASSWORD=

# NASA API
NASA_API_KEY=

# Optional
LOAD_EXAMPLES=false
AIRFLOW_UID=   # run: echo $(id -u)
```
</details>

### 3. Launching the Platform

Clone the repository and select your branch:
```bash
git clone <repo-url>
cd nasa-analysis
git checkout dev  # or 'main'
```

Start all services utilizing the build script:
```bash
bash utils/build.sh 
bash utils/build.sh --volumes # remove all volumes and create new one
bash utils/build.sh --networks # remove all networks and create new one
bash utils/build.sh --volumes --networks # remove all volumes and network and create new one
```
*(The script automatically selects the correct env file, tears down any running stack, and brings up the services.)*

**Access the Airflow UI:** [http://localhost:8080](http://localhost:8080)

---

## 🔧 Development

**Run the linter and formatter:**
```bash
ruff check .
ruff format .
```

**Trigger dbt transformations manually:**
```bash
dbt run
dbt test
```
