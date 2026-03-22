import pytest

from dlt_pipelines.nasa_donki_solar_flare_pipeline import _validate_date_range


class TestValidateDateRange:
    def test_valid_range(self):
        _validate_date_range("2024-01-01", "2024-01-05")

    def test_boundary_seven_days(self):
        _validate_date_range("2024-01-01", "2024-01-08")

    def test_end_before_start_raises(self):
        with pytest.raises(ValueError, match="end_date .* is before start_date"):
            _validate_date_range("2024-01-10", "2024-01-01")

    def test_same_day_is_valid(self):
        _validate_date_range("2024-01-01", "2024-01-01")

    def test_exceeds_seven_days_raises(self):
        with pytest.raises(ValueError, match="7-day limit"):
            _validate_date_range("2024-01-01", "2024-01-10")
