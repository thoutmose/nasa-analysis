# 🌌 nasa-analysis

<div align="center">

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=Apache%20Airflow&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=for-the-badge&logo=postgresql&logoColor=white) ![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white) ![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=for-the-badge&logo=Docker&logoColor=white) ![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white) ![Ruff](https://img.shields.io/badge/Ruff-261230.svg?style=for-the-badge&logo=ruff&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

> **Un projet de data engineering de bout en bout qui collecte, transforme et visualise les données spatiales de la NASA — suivi des astéroïdes géocroiseurs, de l'activité des éruptions solaires et des impacts de météorites historiques.**
>
> **Déployé sur une infrastructure auto-hébergée tournant sur Proxmox.**

🌐 [English](README.md) | **Français**

</div>

---

## 🛠 La Stack de Données Moderne

Ce projet s'appuie sur l'approche **Modern Data Stack (MDS)**, en privilégiant des outils modulaires, best-in-class, orientés développeur et code-first.

* **🚀 Apache Airflow (Orchestration)**  
  Le centre de commande de notre plateforme de données. Airflow permet d'écrire, planifier et surveiller des workflows sous forme de code.
  > **Pourquoi on l'utilise :** Pour orchestrer de manière fiable la séquence des tâches d'ingestion, de validation et de transformation.

* **📥 dlt | dlthub (Ingestion)**  
  Une bibliothèque Python pour le chargement de données. `dlt` (Data Load Tool) automatise le processus d'extraction et de chargement (EL), en gérant automatiquement les réponses API complexes et l'évolution des schémas.
  > **Pourquoi on l'utilise :** Pour simplifier le chargement de données JSON imbriquées depuis les APIs NASA vers PostgreSQL, sans avoir à maintenir manuellement les schémas.

* **🏛️ dbt (Transformation)**  
  La couche de transformation (le « T » dans ELT). `dbt` (data build tool) permet de transformer les données dans l'entrepôt à l'aide de SQL.
  > **Pourquoi on l'utilise :** Pour nettoyer, tester et modéliser les données brutes en tables analytiques grâce à des fichiers SQL modulaires et un contrôle de version intégré.

---

## 📐 Architecture

<div align="center">
  <img src="img/nasa_data_engineering_project.png" alt="Schéma d'architecture" width="800">
</div>

### Vue d'ensemble de l'architecture
Ce projet implémente un **pipeline de données conteneurisé** orchestré avec Apache Airflow, supportant à la fois les environnements de développement et de production avec des structures identiques et une infrastructure isolée.

#### 🌍 Environnements
Le système est divisé en deux environnements parallèles, chacun fonctionnant sur des serveurs Ubuntu dédiés (auto-hébergés sur **Proxmox**) et utilisant Docker pour garantir cohérence, portabilité et reproductibilité :
* **Développement :**  `srv-airflow-dev`
* **Production :** `srv-airflow-prod`

#### 🖥️ Infrastructure

<div align="center">
  <img src="img/nasa_project_infrastructure.png" alt="Diagramme d'infrastructure" width="800">
</div>

Quatre VMs sont provisionnées sur Proxmox. `srv-airflow-dev` et `srv-airflow-prod` exécutent chacun Airflow en tant qu'**utilisateur non-root** avec un **proxy inverse NGINX** pour la terminaison HTTPS ; les deux communiquent avec `srv-db`, qui héberge des instances PostgreSQL isolées pour le dev et la prod. `srv-services` est dédié exclusivement à la **surveillance et aux alertes** (métriques d'infrastructure et traitement des DAG) et ne joue aucun rôle dans le pipeline de données.

#### 🔄 Flux du Pipeline de Données
1. **Sources de données :** Les intégrations principales sont les APIs NASA, avec des fichiers internes/tiers supplémentaires.
2. **Ingestion des données :** Les données API sont extraites et normalisées avec `dlthub` dans les DAGs Airflow.
3. **Stockage des données (couche brute) :** Chargement direct dans une base de données PostgreSQL isolée (ségrégée par dev/prod).
4. **Transformation & Tests des données :** Les modèles `dbt` structurent les données en ensembles raffinés pour l'analytique, en appliquant des **tests de qualité des données** (unicité, non-nullité, intégrité référentielle).
5. **Orchestration :** Gérée de bout en bout par Airflow.

#### 🔁 Modèle de DAG

Tous les DAGs partagent la même structure de tâches standard :

<div align="center">
  <img src="img/airflow_dag_example.png" alt="Exemple de DAG Airflow" width="800">
</div>

1. **`is_api_available`** *(sensor)* — interroge la source de données toutes les 30 secondes. Retourne la réponse brute en cas de succès, `None` en cas de limitation de débit (HTTP 429), ou continue à interroger en cas d'autre échec.
2. **`check_availability`** *(branche)* — route l'exécution : passe à `extract_and_load` si des données ont été retournées, ou redirige vers `stop` si la source était indisponible/limitée.
3. **`extract_and_load`** — exécute le pipeline `dlt` pour extraire, normaliser et charger les données dans PostgreSQL.
4. **`stop`** — branche no-op gracieuse qui marque l'exécution comme ignorée sans lever d'erreur.

Le temps d'exécution moyen de chaque DAG est inférieur à 30 secondes.

#### ⚙️ CI/CD & Opérations
* **CI/CD :** Pipeline GitHub Actions avec trois étapes séquentielles — **Lint → Test → Ouvrir une PR** — déclenché à chaque push ou pull request vers `main` et `dev`. Voir [`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml).
* **Surveillance & Observabilité :** Métriques gérées par **Grafana**, avec alerting **Slack** intégré.
* **Qualité du code :** **Ruff** applique le linting et le formatage Python sur l'ensemble du dépôt.

---

## 📊 Sources de Données

| Source | API / Fichier | Description |
| :--- | :--- | :--- |
| **NeoWs** | NASA NeoWs REST API | Données d'approche rapprochée des astéroïdes géocroiseurs |
| **DONKI — GST** | NASA DONKI REST API | Enregistrements d'événements de tempêtes géomagnétiques |
| **DONKI — Solar Flare** | NASA DONKI REST API | Données d'activité et d'intensité des éruptions solaires |
| **Meteorite Landings** | CSV (NASA Open Data) | Enregistrements historiques des impacts de météorites |

---

## 💻 Stack Technique

| Couche | Outil | Version / Spec |
| :--- | :--- | :--- |
| **Orchestration** | Apache Airflow (CeleryExecutor) | `3.1.8` |
| **Ingestion** | dltHub | `1.23` |
| **Entrepôt de données** | PostgreSQL | `17` |
| **Transformations** | dbt Core | `1.11.7` |
| **Broker de messages** | Redis | `7.2` |
| **Qualité du code** | Ruff | `0.15.7` |
| **Administration BDD** | PgAdmin | `4.9.13` |
| **Surveillance** | Grafana | `12.4.1` |
| **CI/CD** | GitHub Actions | — |
| **Langage** | Python | `≥ 3.13` |

---

## 📁 Structure du Projet

```text
nasa-analysis/                     # Répertoire racine du projet d'analyse NASA
.
├── .github                        # Configuration GitHub
│   ├── instructions               # Instructions Copilot
│   └── workflows
│       └── ci-cd.yml              # Pipeline CI/CD GitHub Actions
├── .dlt                           # Répertoire de configuration DLT               [gitignored]
│   ├── config.toml                # Fichier de configuration DLT                  [gitignored]
│   └── secrets.toml               # Fichier de secrets DLT (credentials, clés API) [gitignored]
├── .env.example                   # Exemple de fichier de variables d'environnement
├── .gitignore                     # Fichiers/répertoires ignorés par Git
├── .python-version                # Spécification de la version Python (pour pyenv)
├── README.md                      # Documentation du projet (anglais)
├── README.fr.md                   # Documentation du projet (français)
├── config                         # Répertoire de configuration Airflow
│   ├── airflow.cfg                # Fichier de configuration principal Airflow
│   └── airflow_local_settings.py  # Paramètres Airflow personnalisés
├── dags                           # Répertoire des DAGs Airflow
│   ├── dlt_pipelines              # Sous-répertoire pour les définitions de pipelines DLT
│   │   ├── nasa_donki_gst_pipeline.py                # Pipeline DONKI Tempête Géomagnétique
│   │   ├── nasa_donki_solar_flare_pipeline.py        # Pipeline DONKI Éruption Solaire
│   │   ├── nasa_meteorite_landings_dataset_pipeline.py # Pipeline Impacts de Météorites
│   │   └── nasa_neows_pipeline.py                    # Pipeline Near Earth Object Web Service
│   ├── nasa_donki_gst_dag.py                         # DAG Airflow pour les données DONKI GST
│   ├── nasa_donki_solar_flare_dag.py                 # DAG Airflow pour les données DONKI Solar Flare
│   ├── nasa_meteorite_landings_dataset_dag.py        # DAG Airflow pour les données Meteorite Landings
│   └── nasa_neows_dag.py                             # DAG Airflow pour les données NASA NeoWs
├── docker-compose.yaml            # Configuration Docker Compose pour les services
├── img                            # Répertoire des ressources images
│   ├── airflow_dag_example.png            # Capture d'écran d'exemple de DAG Airflow
│   ├── nasa_data_engineering_project.png  # Diagramme d'architecture du projet
│   └── nasa_project_infrastructure.png    # Diagramme d'infrastructure
├── pyproject.toml                 # Configuration du projet Python (build system, outils)
├── logs                           # Fichiers de logs
├── requirements.txt               # Dépendances Python
├── tests                          # Tests unitaires (pytest)
│   ├── test_donki_gst_pipeline.py
│   ├── test_donki_solar_flare_pipeline.py
│   ├── test_meteorite_pipeline.py
│   └── test_neows_pipeline.py
├── utils                          # Répertoire des scripts utilitaires
│   ├── build.sh                   # Script d'automatisation du build
│   └── linting.sh                 # Script de linting du code
└── uv.lock                        # Fichier de verrouillage du gestionnaire de paquets UV
```

---

## ⚙️ Pipeline CI/CD

Le projet utilise **GitHub Actions** ([`.github/workflows/ci-cd.yml`](.github/workflows/ci-cd.yml)) avec trois jobs séquentiels déclenchés à chaque push ou pull request vers `main` et `dev` :

| Étape | Job | Ce qu'il fait |
| :---: | :--- | :--- |
| 1 | **Lint** | Exécute `ruff check` et `ruff format --check` sur le répertoire `dags/`. Échoue rapidement en cas d'erreur de style ou de lint. |
| 2 | **Test** | Exécute `pytest tests/ -v`. Ne s'exécute que si le lint passe. |
| 3 | **Ouvrir une PR** | Crée automatiquement une pull request de `dev` → `main`. Ne s'exécute que sur les pushs directs vers `dev` (pas les PRs). Utilise le `GITHUB_TOKEN` intégré — aucun secret personnalisé requis. |

---

## 🚦 Démarrage Rapide

### 1. Prérequis
* **Docker** et **Docker Compose**
* **Git**
* Une [clé API NASA](https://api.nasa.gov/) *(gratuite)*

### 2. Configuration de l'Environnement
Le projet utilise des fichiers d'environnement basés sur les branches :
* La branche `dev` utilise `.env.dev`
* La branche `main` utilise `.env.prod`

Créez le fichier d'environnement approprié en copiant l'exemple et en renseignant les valeurs requises :
```bash
cp .env.example .env.dev 
```

<details>
<summary><b>Cliquez ici pour voir les variables d'environnement requises</b></summary>
<br>

```dotenv
# Authentification Airflow
AIRFLOW__API_AUTH__JWT_SECRET=
AIRFLOW__API_AUTH__JWT_ISSUER=

# Base de données Airflow
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=
AIRFLOW__CELERY__RESULT_BACKEND=

# PostgreSQL
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# Utilisateur admin Airflow
_AIRFLOW_WWW_USER_USERNAME=
_AIRFLOW_WWW_USER_PASSWORD=

# API NASA
AIRFLOW_VAR_NASA_API_KEY=

# Optionnel
LOAD_EXAMPLES=false
AIRFLOW_UID=   # exécuter : echo $(id -u)
```
</details>

### 3. Lancement de la Plateforme

Clonez le dépôt et sélectionnez votre branche :
```bash
git clone <repo-url>
cd nasa-analysis
git checkout dev  # ou 'main'
```

Démarrez tous les services en utilisant le script de build :
```bash
bash utils/build.sh 
bash utils/build.sh --volumes # supprimer tous les volumes et en créer de nouveaux
bash utils/build.sh --networks # supprimer tous les réseaux et en créer de nouveaux
bash utils/build.sh --volumes --networks # supprimer tous les volumes et réseaux et en créer de nouveaux
```
*(Le script sélectionne automatiquement le bon fichier d'environnement, arrête toute stack en cours et démarre les services.)*

**Accéder à l'interface Airflow :** [http://localhost:8080](http://localhost:8080)

---

## 🔧 Développement

**Lancer le linter et le formateur :**
```bash
ruff check .
ruff format .
```

**Lancer les tests unitaires :**
```bash
uv run pytest tests/ -v
```

**Déclencher manuellement les transformations dbt :**
```bash
dbt run
dbt test
```
