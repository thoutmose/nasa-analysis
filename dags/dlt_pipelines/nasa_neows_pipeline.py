from collections.abc import Generator
from datetime import datetime, timedelta
from typing import Any

import dlt
import requests

BASE_URL = "https://api.nasa.gov/neo/rest/v1"


@dlt.source
def neows_source(
    api_key: str, start_date: str, end_date: str
) -> tuple[Any, Any]:
    """dlt source for the NASA NeoWs (Near Earth Object Web Service) API.

    Yields two resources — ``near_earth_objects`` and ``close_approaches`` —
    fetched in 7-day windows between *start_date* and *end_date*.

    Args:
        api_key: NASA API key used for authentication.
        start_date: Inclusive start date in ``YYYY-MM-DD`` format.
        end_date: Exclusive end date in ``YYYY-MM-DD`` format.
    """

    @dlt.resource(
        write_disposition="merge",
        primary_key="id",
        name="near_earth_objects",
    )
    def neo_feed() -> Generator[dict[str, Any]]:
        """Yield one record per near-earth object per observation date."""
        current_start = datetime.strptime(start_date, "%Y-%m-%d")
        final_end = datetime.strptime(end_date, "%Y-%m-%d")

        while current_start < final_end:
            current_end = min(current_start + timedelta(days=7), final_end)

            params: dict[str, str] = {
                "start_date": current_start.strftime("%Y-%m-%d"),
                "end_date": current_end.strftime("%Y-%m-%d"),
                "api_key": api_key,
            }

            response = requests.get(f"{BASE_URL}/feed", params=params)
            response.raise_for_status()
            data: dict[str, Any] = response.json()

            for _date, neos in data["near_earth_objects"].items():
                for neo in neos:
                    diameter = neo["estimated_diameter"]["kilometers"]
                    is_hazardous: bool = neo[
                        "is_potentially_hazardous_asteroid"]
                    yield {
                        "id": neo["id"],
                        "neo_reference_id": neo["neo_reference_id"],
                        "name": neo["name"],
                        "nasa_jpl_url": neo["nasa_jpl_url"],
                        "absolute_magnitude_h": neo["absolute_magnitude_h"],
                        "is_potentially_hazardous": is_hazardous,
                        "estimated_diameter_km_min": diameter[
                            "estimated_diameter_min"],
                        "estimated_diameter_km_max": diameter[
                            "estimated_diameter_max"],
                        "close_approach_data": neo.get(
                            "close_approach_data", []),
                        "observation_date": _date,
                    }

            current_start = current_end

    @dlt.resource(
        write_disposition="merge",
        primary_key="id",
        name="close_approaches",
    )
    def close_approaches() -> Generator[dict[str, Any]]:
        """Yield one record per close-approach event per NEO."""
        current_start = datetime.strptime(start_date, "%Y-%m-%d")
        final_end = datetime.strptime(end_date, "%Y-%m-%d")

        while current_start < final_end:
            current_end = min(current_start + timedelta(days=7), final_end)

            params: dict[str, str] = {
                "start_date": current_start.strftime("%Y-%m-%d"),
                "end_date": current_end.strftime("%Y-%m-%d"),
                "api_key": api_key,
            }

            response = requests.get(f"{BASE_URL}/feed", params=params)
            response.raise_for_status()
            data: dict[str, Any] = response.json()

            for _date, neos in data["near_earth_objects"].items():
                for neo in neos:
                    for approach in neo.get("close_approach_data", []):
                        approach_date: str = approach["close_approach_date"]
                        epoch: int = approach["epoch_date_close_approach"]
                        velocity: dict[str, str] = approach["relative_velocity"]
                        distance: dict[str, str] = approach["miss_distance"]
                        is_hazardous = neo["is_potentially_hazardous_asteroid"]
                        yield {
                            "id": f"{neo['id']}_{approach_date}",
                            "neo_id": neo["id"],
                            "neo_name": neo["name"],
                            "close_approach_date": approach_date,
                            "epoch_date_close_approach": epoch,
                            "orbiting_body": approach["orbiting_body"],
                            "velocity_km_per_sec": float(
                                velocity["kilometers_per_second"]
                            ),
                            "velocity_km_per_hour": float(
                                velocity["kilometers_per_hour"]
                            ),
                            "miss_distance_km": float(distance["kilometers"]),
                            "miss_distance_lunar": float(distance["lunar"]),
                            "is_potentially_hazardous": is_hazardous,
                        }

            current_start = current_end

    return neo_feed, close_approaches


def run_pipeline(
    api_key: str,
    start_date: str,
    end_date: str,
) -> Any:
    """Build and run the dlt pipeline for the given date range.

    Reads destination credentials from ``.dlt/secrets.toml`` or environment
    variables — no connection string is passed explicitly.

    Args:
        api_key: NASA API key.
        start_date: Inclusive start date in ``YYYY-MM-DD`` format.
        end_date: Exclusive end date in ``YYYY-MM-DD`` format.

    Returns:
        dlt ``LoadInfo`` object describing the completed load.
    """
    pipeline = dlt.pipeline(
        pipeline_name="nasa_neows",
        destination="postgres",
        dataset_name="nasa_neows",
    )

    source = neows_source(
        api_key=api_key,
        start_date=start_date,
        end_date=end_date,
    )

    load_info = pipeline.run(
        source,
        loader_file_format="insert_values",
        write_disposition="merge",
        schema_contract="evolve",
    )
    return load_info
