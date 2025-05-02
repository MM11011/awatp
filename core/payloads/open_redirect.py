import httpx

async def scan_for_open_redirect(client, url):
    payload = f"{url}?next=https://evil.com"
    try:
        response = await client.get(payload, follow_redirects=False)
        vulnerable = response.headers.get("Location", "").startswith("https://evil.com")
        return {
            "type": "Open Redirect",
            "payload": payload,
            "vulnerable": vulnerable,
            "evidence": response.headers.get("Location", "No redirect")
        }
    except Exception as e:
        return {
            "type": "Open Redirect",
            "payload": payload,
            "vulnerable": False,
            "evidence": f"Error: {str(e)}"
        }
