import pytest
import csv
import io
from unittest.mock import MagicMock, patch

from dlt_pipelines.nasa_meteorite_landings_dataset_pipeline import (
    fetch_meteorite_landings,
)

CSV_HEADER = "name,id,nametype,recclass,mass (g),fall,year,reclat,reclong,GeoLocation\n"


def _make_response(csv_body: str) -> MagicMock:
    mock = MagicMock()
    mock.text = CSV_HEADER + csv_body
    mock.raise_for_status.return_value = None
    return mock


class TestFetchMeteoriteLandings:
    def test_parses_single_record(self):
        row = "Aachen,1,Valid,L5,21.0,Fell,01/01/1880 12:00:00 AM,50.775,6.08333,\"(50.775, 6.08333)\""
        with patch(
            "dlt_pipelines.nasa_meteorite_landings_dataset_pipeline.requests.get",
            return_value=_make_response(row),
        ):
            records = list(fetch_meteorite_landings())

        assert len(records) == 1
        r = records[0]
        assert r["name"] == "Aachen"
        assert r["id"] == 1
        assert r["nametype"] == "Valid"
        assert r["recclass"] == "L5"
        assert r["mass"] == 21.0
        assert r["fall"] == "Fell"
        assert r["reclat"] == 50.775
        assert r["reclong"] == 6.08333
        assert r["geolocation"] == "(50.775, 6.08333)"

    def test_parses_multiple_records(self):
        rows = (
            "Aachen,1,Valid,L5,21.0,Fell,01/01/1880 12:00:00 AM,50.775,6.08333,\"(50.775, 6.08333)\"\n"
            "Aarhus,2,Valid,H6,720.0,Fell,01/01/1951 12:00:00 AM,56.18333,10.23333,\"(56.18333, 10.23333)\""
        )
        with patch(
            "dlt_pipelines.nasa_meteorite_landings_dataset_pipeline.requests.get",
            return_value=_make_response(rows),
        ):
            records = list(fetch_meteorite_landings())

        assert len(records) == 2
        assert records[1]["name"] == "Aarhus"
        assert records[1]["id"] == 2

    def test_missing_optional_fields_become_none(self):
        # mass, reclat, reclong, id left empty
        row = "Unknown,,Valid,L5,,Fell,,,,"
        with patch(
            "dlt_pipelines.nasa_meteorite_landings_dataset_pipeline.requests.get",
            return_value=_make_response(row),
        ):
            records = list(fetch_meteorite_landings())

        r = records[0]
        assert r["id"] is None
        assert r["mass"] is None
        assert r["reclat"] is None
        assert r["reclong"] is None

    def test_raises_on_http_error(self):
        mock = MagicMock()
        mock.raise_for_status.side_effect = Exception("404 Not Found")
        with patch(
            "dlt_pipelines.nasa_meteorite_landings_dataset_pipeline.requests.get",
            return_value=mock,
        ):
            with pytest.raises(Exception, match="404 Not Found"):
                list(fetch_meteorite_landings())


