from datetime import datetime, timedelta
import os
from typing import Any

from airflow.sdk import Connection, Variable, dag, task
from airflow.sdk.bases.sensor import PokeReturnValue

from dotenv import load_dotenv

import requests

from dlt_pipelines.nasa_donki_gst_pipeline import run_pipeline


load_dotenv()

default_args: dict[str, Any] = {
    "owner": "data-team",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}


@dag(
    dag_id="nasa_donki_gst_dlt_pipeline_airflow_dag",
    default_args=default_args,
    schedule="@daily",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["nasa", "donki", "gst", "dlt", "data-ingestion", "airflow", "dag"],
)
def nasa_donki_gst_taskflow() -> None:
    @task.sensor(poke_interval=30, timeout=3600, mode="poke")
    def is_api_available() -> PokeReturnValue:
        import requests

        try:
            response = requests.get(
                "https://api.nasa.gov/DONKI/GST?startDate=2016-01-01"
                "&endDate=2016-01-30", 
                params={"api_key": os.getenv("NASA_API_KEY")}, timeout=10)
            if response.status_code == 200:
                condition_met = True
                operator_return_value = response.json()
            elif response.status_code == 429:
                condition_met = True
                operator_return_value = None
            else:
                condition_met = False
                operator_return_value = None
            return PokeReturnValue(
                is_done=condition_met, 
                xcom_value=operator_return_value)
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
dag_instance = nasa_donki_gst_taskflow()