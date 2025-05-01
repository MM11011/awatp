import httpx

def scan_for_xss(url):
    payload = "<script>alert(1)</script>"
    test_url = f"{url}?q={payload}"

    try:
        response = httpx.get(test_url, timeout=10)

        if payload in response.text:
            return {
                "type": "Cross-Site Scripting (Reflected)",
                "payload": test_url,
                "vulnerable": True,
                "evidence": "Payload reflected in response"
            }

        return {
            "type": "Cross-Site Scripting (Reflected)",
            "payload": test_url,
            "vulnerable": False,
            "evidence": "Payload not reflected in response"
        }

    except httpx.RequestError as e:
        return {
            "type": "Cross-Site Scripting (Reflected)",
            "payload": test_url,
            "vulnerable": False,
            "evidence": f"Request failed: {str(e)}"
        }
