# core/payloads/sql.py

async def scan_for_sqli(client, url):
    test_url = f"{url}?id=1"
    try:
        response = await client.get(test_url, timeout=10)
        indicators = ["You have an error in your SQL syntax", "SQLSTATE", "syntax error"]
        vulnerable = any(indicator in response.text for indicator in indicators)
        return {
            "type": "SQL Injection",
            "payload": test_url,
            "evidence": response.text if vulnerable else "No obvious SQL errors",
            "vulnerable": vulnerable,
            "sqli": int(vulnerable)
        }
    except Exception as e:
        return {
            "error": str(e),
            "sqli": 0
        }
