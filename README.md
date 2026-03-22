# 🌌 nasa-analysis

<div align="center">

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=Apache%20Airflow&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=for-the-badge&logo=postgresql&logoColor=white) ![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white) ![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=Docker&logoColor=white) ![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white) ![Ruff](https://img.shields.io/badge/Ruff-261230.svg?style=for-the-badge&logo=ruff&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

> **An end-to-end data engineering project that collects, transforms, and visualizes NASA space data — tracking near-Earth asteroids, solar flare activity, and historical meteorite impacts.**
>
> **Deployed on a self-hosted infrastructure running on Proxmox.**

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
The system is split into two parallel environments, each running on dedicated Ubuntu-based servers (self-hosted on **Proxmox**) and utilizing Docker to ensure consistency, portability, and reproducibility:
* **Development:**  `srv-airflow-dev`
* **Production:** `srv-airflow-prod`

#### 🖥️ Infrastructure

<div align="center">
  <img src="img/nasa_project_infrastructure.png" alt="Infrastructure Diagram" width="800">
</div>

Four VMs are provisioned on Proxmox. `srv-airflow-dev` and `srv-airflow-prod` each run Airflow as a **non-root user** with an **NGINX reverse proxy** for HTTPS termination; both communicate with `srv-db`, which hosts isolated PostgreSQL instances for dev and prod. `srv-services` is dedicated exclusively to **monitoring and alerting** (infrastructure metrics and DAG processing) and plays no role in the data pipeline.

#### 🔄 Data Pipeline Flow
1. **Data Sources:** Primary integrations are NASA APIs, with additional internal/third-party files.
2. **Data Ingestion:** API data is extracted and normalized using `dlthub` within Airflow DAGs.
3. **Data Storage (Raw Layer):** Loads directly into an isolated PostgreSQL database (segregated by dev/prod).
4. **Data Transformation & Testing:** `dbt` models structure the data into refined sets for analytics, enforcing **data quality tests** (uniqueness, non-null, referential integrity).
5. **Orchestration:** Managed end-to-end by Airflow.

#### 🔁 DAG Pattern

All DAGs share the same standard task structure:

<div align="center">
  <img src="img/airflow_dag_example.png" alt="Airflow DAG example" width="800">
</div>

1. **`is_api_available`** *(sensor)* — polls the data source every 30 seconds. Returns the raw response on success, `None` on rate-limit (HTTP 429), or keeps poking on any other failure.
2. **`check_availability`** *(branch)* — routes execution: proceeds to `extract_and_load` if data was returned, or diverts to `stop` if the source was unavailable/rate-limited.
3. **`extract_and_load`** — runs the `dlt` pipeline to extract, normalize, and load data into PostgreSQL.
4. **`stop`** — graceful no-op branch that marks the run as skipped without raising an error.

The average time execution of each DAG takes less than 30 seconds.

#### ⚙️ CI/CD & Operations
* **CI/CD:** GitHub Actions pipeline with three sequential stages — **Lint → Test → Deploy** — triggered on every push or pull request to `main` and `dev`. See [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml).
* **Monitoring & Observability:** Metrics handled by **Grafana**, with integrated **Slack** alerting.
* **Code Quality:** **Ruff** enforces Python linting and formatting across the repository.

---

## 📊 Data Sources

| Source | API / File | Description |
| :--- | :--- | :--- |
| **NeoWs** | NASA NeoWs REST API | Near-Earth asteroid close-approach data |
| **DONKI — GST** | NASA DONKI REST API | Geomagnetic storm event records |
| **DONKI — Solar Flare** | NASA DONKI REST API | Solar flare activity and intensity data |
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
| **CI/CD** | GitHub Actions | — |
| **Language** | Python | `≥ 3.13` |

---

## 📁 Project Structure

```text
nasa-analysis/                     # Root project directory for NASA data analysis
.
├── .github                        # GitHub configuration
│   ├── instructions               # Copilot instructions
│   └── workflows
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── .dlt                           # DLT (Data Load Tool) configuration directory               [gitignored]
│   ├── config.toml                # DLT configuration file (pipeline settings)                 [gitignored]
│   └── secrets.toml               # DLT secrets file (credentials, API keys)                   [gitignored]
├── .env.example                   # Example environment variables file
├── .gitignore                     # Specifies files/dirs to ignore in Git
├── .python-version                # Python version specification (for pyenv)
├── README.md                      # Project documentation
├── config                         # Airflow configuration directory
│   ├── airflow.cfg                # Airflow main configuration file
│   └── airflow_local_settings.py  # Custom Airflow settings
├── dags                           # Airflow DAGs directory
│   ├── dlt_pipelines              # Subdirectory for DLT pipeline definitions
│   │   ├── nasa_donki_gst_pipeline.py                # DONKI Geomagnetic Storm pipeline
│   │   ├── nasa_donki_solar_flare_pipeline.py        # DONKI Solar Flare pipeline
│   │   ├── nasa_meteorite_landings_dataset_pipeline.py # Meteorite Landings pipeline
│   │   └── nasa_neows_pipeline.py                    # Near Earth Object Web Service pipeline
│   ├── nasa_donki_gst_dag.py                         # Airflow DAG for DONKI GST data
│   ├── nasa_donki_solar_flare_dag.py                 # Airflow DAG for DONKI Solar Flare data
│   ├── nasa_meteorite_landings_dataset_dag.py        # Airflow DAG for Meteorite Landings data
│   └── nasa_neows_dag.py                             # Airflow DAG for NASA NeoWs data
├── docker-compose.yaml            # Docker Compose configuration for services
├── img                            # Image assets directory
│   ├── airflow_dag_example.png            # Example Airflow DAG screenshot
│   ├── nasa_data_engineering_project.png  # Project architecture diagram
│   └── nasa_project_infrastructure.png    # Infrastructure diagram
├── pyproject.toml                 # Python project configuration (build system, tools)
├── logs                           # Logging files
├── requirements.txt               # Python dependencies├── tests                          # Unit tests (pytest)
│   ├── test_donki_gst_pipeline.py
│   ├── test_donki_solar_flare_pipeline.py
│   ├── test_meteorite_pipeline.py
│   └── test_neows_pipeline.py├── utils                          # Utility scripts directory
│   ├── build.sh                   # Build automation script
│   └── linting.sh                 # Code linting script
└── uv.lock                        # Lock file for UV package manager (Python)
```

---

## ⚙️ CI/CD Pipeline

The project uses **GitHub Actions** ([`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml)) with three sequential jobs triggered on every push or pull request to `main` and `dev`:

| Step | Job | What it does |
| :---: | :--- | :--- |
| 1 | **Lint** | Runs `ruff check` and `ruff format --check` on the `dags/` directory. Fails fast on any style or lint error. |
| 2 | **Test** | Runs `pytest tests/ -v` (19 tests). Only executes if lint passes. |
| 3 | **Deploy** | SSHes into the target server, runs `git pull` and `utils/build.sh`. Only runs on direct pushes (not PRs). Automatically selects `.env.dev` on `dev` and `.env.prod` on `main`. |

**Required GitHub repository secrets for deploy:**

| Secret | Description |
| :--- | :--- |
| `SSH_HOST` | Server IP or hostname |
| `SSH_USERNAME` | SSH user on the server |
| `SSH_PRIVATE_KEY` | Private key for SSH authentication |
| `DEPLOY_PATH` | Absolute path to the project on the server |

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

**Run the unit tests:**
```bash
uv run pytest tests/ -v
```

**Trigger dbt transformations manually:**
```bash
dbt run
dbt test
```
