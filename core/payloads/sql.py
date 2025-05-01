import httpx

def scan_for_sqli(url):
    test_url = f"{url}?id=1'"
    try:
        response = httpx.get(test_url, timeout=10)

        if "sql" in response.text.lower() or "syntax" in response.text.lower():
            return {
                "type": "SQL Injection",
                "payload": test_url,
                "vulnerable": True,
                "evidence": "Found SQL error in response"
            }

        return {
            "type": "SQL Injection",
            "payload": test_url,
            "vulnerable": False,
            "evidence": "No obvious SQL errors"
        }

    except httpx.RequestError as e:
        return {
            "type": "SQL Injection",
            "payload": test_url,
            "vulnerable": False,
            "evidence": f"Request failed: {str(e)}"
        }
