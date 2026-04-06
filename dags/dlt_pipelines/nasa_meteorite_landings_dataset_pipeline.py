import dlt
import requests
import csv
import io


@dlt.resource(name="meteorite_landings", write_disposition="replace")
def fetch_meteorite_landings():
    """
    Fetches the NASA Meteorite Landings dataset from a public CSV URL and yields
    each record as a dictionary. The dataset includes information about
    meteorite landings such as name, id, type, mass, fall status, year, and
    geolocation.

    Returns:
        Generator[dict]: A generator that yields each meteorite landing record
        as a dictionary.
    """

    url = "https://data.nasa.gov/docs/legacy/meteorite_landings/Meteorite_Landings.csv"

    response = requests.get(url, timeout=30)
    response.raise_for_status()

    # Parse CSV content
    reader = csv.DictReader(io.StringIO(response.text))

    for row in reader:
        yield {
            "name": row.get("name"),
            "id": int(row["id"]) if row.get("id") else None,
            "nametype": row.get("nametype"),
            "recclass": row.get("recclass"),
            "mass": float(row["mass (g)"]) if row.get("mass (g)") else None,
            "fall": row.get("fall"),
            "year": row.get("year"),
            "reclat": float(row["reclat"]) if row.get("reclat") else None,
            "reclong": float(row["reclong"]) if row.get("reclong") else None,
            "geolocation": row.get("GeoLocation"),
        }


@dlt.source
def nasa_source():
    return fetch_meteorite_landings()


def run_pipeline():
    pipeline = dlt.pipeline(
        pipeline_name="nasa_meteorites",
        destination=dlt.destinations.snowflake(enable_atomic_swap=True),
        dataset_name="nasa_meteorite_landings",
    )

    load_info = pipeline.run(nasa_source())
    print(load_info)
    return load_info


if __name__ == "__main__":
    run_pipeline()
