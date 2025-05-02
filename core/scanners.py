from core.sqli import test_sqli
from core.xss import test_xss  # Ensure the "core/xss.py" file exists and contains the "test_xss" function
from core.ssti import test_ssti
from core.fingerprints import fingerprint_url
from core.open_redirect import scan_for_open_redirect  # <-- added

async def run_scan_modules(client, url, modules):
    results = []

    if "sqli" in modules:
        results.append(await test_sqli(client, url))

    if "xss" in modules:
        results.append(await test_xss(client, url))

    if "ssti" in modules:
        results.append(await test_ssti(client, url))

    if "open_redirect" in modules:
        results.append(await scan_for_open_redirect(client, url))  # <-- fixed argument mismatch

    return {
        "fingerprint": fingerprint_url(url),
        "results": results
    }
