import httpx

async def scan_for_xss(client: httpx.AsyncClient, url: str):
    payload = "<script>alert(1)</script>"
    test_url = f"{url}?q={payload}"

    try:
        response = await client.get(test_url, timeout=10)
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

# Fix for import
test_xss = scan_for_xss
