# test_fingerprint_url.py
import pytest
from core.fingerprints import fingerprint_target

def test_fingerprint_url_success():
    result = fingerprint_target("https://example.com")
    assert "Server" in result
    assert "Content-Type" in result
