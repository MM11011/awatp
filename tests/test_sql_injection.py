# tests/test_sql_injection.py

import pytest
from core.payloads.sql import scan_for_sqli

class MockResponse:
    def __init__(self, text):
        self.text = text

class MockClient:
    async def get(self, url, params=None, timeout=10):
        return MockResponse("You have an error in your SQL syntax")

@pytest.mark.asyncio
async def test_sql_injection_detected():
    client = MockClient()
    result = await scan_for_sqli(client, "http://example.com/search")
    assert result.get("sqli", 0) > 0

@pytest.mark.asyncio
async def test_sql_injection_not_detected():
    class SafeClient:
        async def get(self, url, params=None, timeout=10):
            return MockResponse("All good")

    client = SafeClient()
    result = await scan_for_sqli(client, "http://example.com/search")
    assert result.get("sqli", 0) == 0
