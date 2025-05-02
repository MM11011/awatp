# tests/test_ssti.py

import pytest
from core.payloads.ssti import scan_for_ssti

class MockResponse:
    def __init__(self, text):
        self.text = text

class MockClient:
    def __init__(self, response_text):
        self.response = MockResponse(response_text)

    async def get(self, url, params=None, timeout=10):
        return self.response

@pytest.mark.asyncio
async def test_ssti_detected():
    client = MockClient("SSTI Test 49")
    result = await scan_for_ssti(client, "http://example.com")
    assert result["ssti"] == 1

@pytest.mark.asyncio
async def test_ssti_not_detected():
    client = MockClient("Normal content")
    result = await scan_for_ssti(client, "http://example.com")
    assert result["ssti"] == 0
