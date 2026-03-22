from datetime import datetime, timedelta
from typing import Any

from airflow.sdk import dag, task
from airflow.sdk.bases.sensor import PokeReturnValue

from dotenv import load_dotenv

import requests

from dlt_pipelines.nasa_meteorite_landings_dataset_pipeline import run_pipeline


load_dotenv()

default_args: dict[str, Any] = {
    "owner": "data-team",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}


@dag(
    dag_id="nasa_meteorite_landings_dataset",
    default_args=default_args,
    schedule="@yearly",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["nasa", "meteorite", "landings", "dlt", "data-ingestion", "airflow", "dag"],
)
def nasa_meteorite_landings_taskflow() -> None:
    @task.sensor(poke_interval=30, timeout=3600, mode="poke")
    def is_api_available() -> PokeReturnValue:
        try:
            url: str = (
                "https://data.nasa.gov/docs/legacy/meteorite_landings"
                "/Meteorite_Landings.csv"
            )
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                condition_met = True
                operator_return_value = True
            elif response.status_code == 429:
                condition_met = True
                operator_return_value = None
            else:
                condition_met = False
                operator_return_value = None
            return PokeReturnValue(
                is_done=condition_met, xcom_value=operator_return_value
            )
        except requests.RequestException:
            return PokeReturnValue(is_done=False, xcom_value=None)

    @task.branch()
    def check_availability(api_result: Any) -> str:
        if api_result:
            return "extract_and_load"
        return "stop"

    @task()
    def extract_and_load(**context: Any) -> str:
        load_info = run_pipeline()
        return str(load_info)

    @task()
    def stop() -> str:
        return "stopped"

    # Define task dependencies
    api_check = is_api_available()
    branch_task = check_availability(api_check)
    load_task = extract_and_load()
    stop_task = stop()

    # Set the load task
    api_check >> branch_task >> [load_task, stop_task]


# Instantiate the DAG
dag_instance = nasa_meteorite_landings_taskflow()
