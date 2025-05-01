import httpx
from core.payloads import sql

# Main scanning function
def run_scanner(url, fingerprint_info):
    print("🛠️  Running vulnerability scanner...")

    results = []

    # === STEP 1: Decide what scans to run based on fingerprint ===
    tech_stack = f"{fingerprint_info.get('X-Powered-By', '')} {fingerprint_info.get('Server', '')}".lower()

    if "php" in tech_stack:
        print("🔎 Detected PHP — Running SQL Injection scan...")
        sql_result = sql.scan_for_sqli(url)
        results.append(sql_result)
    else:
        print("ℹ️ No targeted payloads for this stack yet.")

    return results
