import requests
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

def scan_for_open_redirect(base_url):
    """
    Scans a URL for potential open redirect vulnerabilities.
    
    Returns a dictionary with detection results.
    """
    parsed = urlparse(base_url)
    query = parse_qs(parsed.query)

    test_payload = "https://evil.com"

    vulnerable = False
    tested_urls = []

    for param in query:
        original = query[param]
        query[param] = [test_payload]

        modified_query = urlencode(query, doseq=True)
        modified_url = urlunparse(parsed._replace(query=modified_query))
        tested_urls.append(modified_url)

        try:
            response = requests.get(modified_url, allow_redirects=False, timeout=5)
            if "Location" in response.headers and test_payload in response.headers["Location"]:
                vulnerable = True
        except Exception:
            pass  # Swallow connection errors

        query[param] = original  # Restore original value

    return {
        "url": base_url,
        "vulnerable": vulnerable,
        "tested_urls": tested_urls
    }
