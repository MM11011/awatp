import httpx
from core.payloads import sql, xss

def run_scanner(url, fingerprint_info):
    print("🛠️  Running vulnerability scanner...")

    results = []

    # SQL Injection
    print("🔎 Running SQL Injection scan...")
    sql_result = sql.scan_for_sqli(url)
    results.append(sql_result)

    # Cross-Site Scripting
    print("🔎 Running XSS scan...")
    xss_result = xss.scan_for_xss(url)
    results.append(xss_result)

    return results

