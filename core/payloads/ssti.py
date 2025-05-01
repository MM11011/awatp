import httpx

def scan_for_ssti(url):
    payload = "{{7*7}}"  # Simple Jinja2 payload
    test_url = f"{url}?input={payload}"

    try:
        response = httpx.get(test_url, timeout=10)

        if "49" in response.text:
            return {
                "type": "Server-Side Template Injection (SSTI)",
                "payload": test_url,
                "vulnerable": True,
                "evidence": "Evaluated expression (49) found in response"
            }

        return {
            "type": "Server-Side Template Injection (SSTI)",
            "payload": test_url,
            "vulnerable": False,
            "evidence": "Payload not evaluated"
        }

    except httpx.RequestError as e:
        return {
            "type": "Server-Side Template Injection (SSTI)",
            "payload": test_url,
            "vulnerable": False,
            "evidence": f"Request failed: {str(e)}"
        }
