from __future__ import annotations
import os

from dotenv import load_dotenv
from airflow.api_fastapi.common.types import UIAlert


# load environment variables from .env file
load_dotenv()

ENV = os.getenv("ENV")
DASHBOARD_UIALERTS = [
    UIAlert(text="Welcome to Airflow", category="info"),
    UIAlert(
        text="Airflow is running in development mode. Do not use this setup for production.",
        category="warning",
    )
    if ENV == "dev"
    else None,
]

