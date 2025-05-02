import pytest

@pytest.fixture(scope="session")
def sample_url():
    return "http://example.com"
