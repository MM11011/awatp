# core/payloads/open_redirect.py

async def scan_for_open_redirect(client, url):
    try:
        response = await client.get(url, follow_redirects=False, timeout=10)
        if response.status_code in [301, 302, 303, 307, 308]:
            location = response.headers.get("Location", "")
            if any(domain in location for domain in ["http://", "https://"]) and not location.startswith(url):
                return {
                    "url": url,
                    "status": "vulnerable",
                    "redirect_location": location
                }
        return {"url": url, "status": "safe"}
    except Exception as e:
        return {"url": url, "status": "error", "error": str(e)}
