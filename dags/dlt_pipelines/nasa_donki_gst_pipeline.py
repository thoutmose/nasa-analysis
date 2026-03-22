from __future__ import annotations
import logging
from typing import Any, Optional

import dlt
from dlt.common.pendulum import pendulum
from dlt.sources.rest_api import (
    RESTAPIConfig,
    rest_api_source
)


logger = logging.getLogger(__name__)


def _validate_date_range(start_date: str, end_date: str) -> None:
    start = pendulum.parse(start_date)
    end = pendulum.parse(end_date)
    if end < start:
        raise ValueError(
            f"end_date ({end_date}) is before start_date ({start_date})")
    if (end - start).days > 7:
        raise ValueError(
            "Date range exceeds NASA DONKI GST 7-day limit:"
            f" {(end - start).days} days"
        )


@dlt.source(name="nasa_donki")
def nasa_donki_gst_source(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    api_key: str = dlt.secrets.value
) -> Any:
    """
    A DLT source for NASA's DONKI (Space Weather Database Of Notifications, 
    Knowledge, Information) GST (Geospace Storms and Transients).

    Args:
        start_date (str): The start date for the data in YYYY-MM-DD format.
        end_date (str): The end date for the data in YYYY-MM-DD format.
        api_key (str): Your NASA API key. Defaults to the value of the 
        "NASA_API_KEY" secret.

    Returns:
        Any: The data retrieved from NASA DONKI GST API.
    """
    if not start_date:
        logger.info("Start date not provided. Defaulting to 7 days ago.")
        start_date = pendulum.now().subtract(days=7).strftime("%Y-%m-%d")
    if not end_date:
        logger.info("End date not provided. Defaulting to today.")
        end_date = pendulum.now().strftime("%Y-%m-%d")

    _validate_date_range(start_date, end_date)

    config: RESTAPIConfig = {
        "client": {
            "base_url": "https://api.nasa.gov/DONKI",
        },
        "resources": [
            {
                "name": "nasa_donki_gst_response",
                "write_disposition": "merge",
                "primary_key": "gstID",
                "endpoint": {
                    "path": "/GST",
                    "params": {
                        "start_date": start_date,
                        "end_date": end_date,
                        "api_key": api_key,
                    },
                    "paginator": "single_page",
                    "data_selector": "$[*]",
                },
            }
        ],
    }
    source = rest_api_source(config)
    
    return source

def run_pipeline() -> Any:
    pipeline = dlt.pipeline(
        pipeline_name="nasa_donki_gst",
        destination="postgres",
        dataset_name="nasa_db",
    )
    
    load_info = pipeline.run(nasa_donki_gst_source())
    logger.info(load_info)
    return load_info