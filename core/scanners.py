from core.payloads.sql import test_sql_injection
from core.payloads.xss import test_xss
from core.payloads.ssti import test_ssti
from core.fingerprints import fingerprint_url

async def run_scan_modules(client, url: str, modules: list) -> dict:
    results = []

    if "sqli" in modules:
        results.append(await test_sql_injection(client, url))

    if "xss" in modules:
        results.append(await test_xss(client, url))

    if "ssti" in modules:
        results.append(await test_ssti(client, url))

    return {
        "fingerprint": fingerprint_url(url),
        "results": results
    }
