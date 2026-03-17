from datetime import datetime, timedelta
from typing import Any

from airflow.sdk import Variable, dag, task
from airflow.sdk.bases.hook import BaseHook

default_args: dict[str, Any] = {
    "owner": "data-team",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}


@dag(
    dag_id="nasa_neows_taskflow",
    default_args=default_args,
    schedule="@daily",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["nasa", "dlt", "taskflow"],
)
def nasa_neows_taskflow() -> None:
    """Ingest NASA NeoWs near-Earth object data into PostgreSQL via dlt.

    Daily pipeline that:
    1. Extracts and loads NEO feed data for the scheduled interval.
    2. Validates that rows were written to the database.
    3. Alerts when potentially hazardous objects are detected.
    """

    @task()
    def extract_and_load(**context: Any) -> str:
        """Extract NEOs from the NASA NeoWs API and load them into PostgreSQL.

        Returns a string representation of the dlt LoadInfo object.
        """
        from dlt_pipelines.nasa_neows_pipeline import run_pipeline

        nasa_api_key: str = Variable.get("NASA_API_KEY")
        print(f"DEBUG: context['ds'] = {context.get('ds')}")
        print(f"DEBUG: context['data_interval_end'] = {context.get('data_interval_end')}")

        load_info = run_pipeline(
            api_key=nasa_api_key,
            start_date=context["ds"],
            end_date=context["data_interval_end"].strftime("%Y-%m-%d"),
        )
        return str(load_info)

    @task()
    def validate(load_info: str, **context: Any) -> dict[str, int]:
        """Assert that at least one near-earth object row was written.

        Args:
            load_info: Stringified dlt LoadInfo from the upstream task.

        Returns:
            Dict with ``record_count`` key containing the total row count.

        Raises:
            ValueError: If the ``near_earth_objects`` table is empty.
        """
        import psycopg2
        from psycopg2 import errors

        pg_conn = BaseHook.get_connection("postgres_dlt")
        conn = psycopg2.connect(
            host=pg_conn.host,
            port=pg_conn.port,
            dbname=pg_conn.schema,
            user=pg_conn.login,
            password=pg_conn.password,
        )
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT COUNT(*) FROM nasa_neows.near_earth_objects")
            count: int = cursor.fetchone()[0]
        except errors.UndefinedTable:
            count = 0
        cursor.close()
        conn.close()

        if count == 0:
            raise ValueError("No data loaded!")
        return {"record_count": count}

    @task()
    def alert_hazardous(**context: Any) -> int:
        """Log potentially hazardous objects for the current interval date.

        Queries the ``close_approaches`` table filtered to the DAG execution
        date and prints a summary for each hazardous object ordered by
        ascending miss distance.

        Returns:
            Number of hazardous objects found.
        """
        import psycopg2
        from psycopg2 import errors

        pg_conn = BaseHook.get_connection("postgres_dlt")
        conn = psycopg2.connect(
            host=pg_conn.host,
            port=pg_conn.port,
            dbname=pg_conn.schema,
            user=pg_conn.login,
            password=pg_conn.password,
        )
        cursor = conn.cursor()
        try:
            cursor.execute(
                """
                SELECT neo_name, miss_distance_km, velocity_km_per_sec
                FROM nasa_neows.close_approaches
                WHERE is_potentially_hazardous = true
                AND close_approach_date = %s
                ORDER BY miss_distance_km ASC
            """,
                (context["ds"],),
            )
            hazardous: list[tuple[str, float, float]] = cursor.fetchall()
        except errors.UndefinedTable:
            hazardous = []
        cursor.close()
        conn.close()

        if hazardous:
            print(f"⚠️ {len(hazardous)} hazardous objects detected!")
            for h in hazardous:
                print(f"  🪨 {h[0]} - {h[1]:,.0f} km away at {h[2]:,.2f} km/s")

        return len(hazardous)

    # Define task dependencies
    load_result = extract_and_load()
    validation = validate(load_result)
    alert = alert_hazardous()

    validation >> alert


# Instantiate the DAG
nasa_neows_taskflow()
