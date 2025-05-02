from urllib.parse import urlparse
import os

# Read blocked domains from environment variable or use default list
BLOCKED_DOMAINS = os.getenv("BLOCKED_DOMAINS", "").split(",")

def is_blocked_domain(url: str) -> bool:
    try:
        hostname = urlparse(url).hostname
        if hostname is None:
            return True  # treat malformed URLs as blocked
        return hostname in BLOCKED_DOMAINS
    except Exception:
        return True
