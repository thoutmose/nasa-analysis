from __future__ import annotations
import logging
from typing import Any, Optional

import dlt
from dlt.common.pendulum import pendulum
from dlt.sources.rest_api import (
    RESTAPIConfig,
    rest_api_source,
)


logger = logging.getLogger(__name__)


def _validate_date_range(start_date: str, end_date: str) -> None:
    start = pendulum.parse(start_date)
    end = pendulum.parse(end_date)
    if end < start:
        raise ValueError(f"end_date ({end_date}) is before start_date ({start_date})")
    if (end - start).days > 7:
        raise ValueError(
            f"Date range exceeds NASA NEOWs 7-day limit: {(end - start).days} days"
        )


@dlt.source(name="nasa_neows")
def nasa_neows_source(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    api_key: str = dlt.secrets.value,
) -> Any:
    """
    A source that retrieves data from the NASA Near Earth Object Web Service
    (NEOWS) API.

    Args:
        start_date (str, optional): The start date for the data retrieval in
        'YYYY-MM-DD' format. Defaults to 7 days ago.
        end_date (str, optional): The end date for the data retrieval in
        'YYYY-MM-DD' format. Defaults to today.
        api_key (str, optional): Your NASA API key. Resolves from dlt secrets.

    Returns:
        Any: The data retrieved from the NASA NEOWS API.
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
            "base_url": "https://api.nasa.gov/neo/rest/v1",
        },
        "resources": [
            {
                # The name of the resource in the destination (e.g., table name)
                "name": "nasa_neows_response",
                # The write disposition determines how data is written to the
                # destination. ('merge', 'replace', 'append')
                "write_disposition": "merge",
                # The primary key is used to identify unique records for merging
                "primary_key": "id",
                "endpoint": {
                    "path": "/feed",
                    "params": {
                        "start_date": start_date,
                        "end_date": end_date,
                        "api_key": api_key,
                    },
                    "paginator": "single_page",
                    # The data selector is a JSONPath expression that specifies
                    # where to find the data within the API response
                    # $: root of the JSON response
                    # .: access a child element
                    # *: wildcard to match any element in an array or any key in
                    # an object
                    # [*]: wildcard to match any element in an array
                    "data_selector": "$.near_earth_objects.*[*]",
                },
            }
        ],
    }
    source = rest_api_source(config)

    return source


def run_pipeline() -> Any:
    pipeline = dlt.pipeline(
        pipeline_name="nasa_neows",
        destination=dlt.destinations.snowflake(enable_atomic_swap=True),
        dataset_name="nasa_neows",
    )

    load_info = pipeline.run(nasa_neows_source())
    logger.info(load_info)
    return load_info
