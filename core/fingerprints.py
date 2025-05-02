import httpx

def fingerprint_target(url):
    try:
        response = httpx.get(url, timeout=10)
        headers = response.headers

        server = headers.get("Server", "Unknown")
        powered_by = headers.get("X-Powered-By", "Unknown")
        content_type = headers.get("Content-Type", "Unknown")

        return {
            "Server": server,
            "X-Powered-By": powered_by,
            "Content-Type": content_type,
            "Status Code": response.status_code
        }

    except httpx.RequestError as e:
        print(f"❌ Request failed: {e}")
        return None

# ✅ Fix import issue
fingerprint_url = fingerprint_target
