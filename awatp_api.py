from flask import Flask, request, jsonify
from flask_cors import CORS
import asyncio
import json

from core.scanners import run_scan_modules

app = Flask(__name__)
CORS(app)

@app.route("/scan", methods=["POST"])
def scan():
    data = request.get_json()
    urls = data.get("urls", [])
    modules = data.get("modules", ["sqli", "xss", "ssti", "open_redirect"])

    # Load blocked domains
    try:
        with open("blocked_domains.json", "r") as f:
            blocked_domains = set(json.load(f))
    except FileNotFoundError:
        blocked_domains = {"google.com", "facebook.com", "youtube.com"}  # Fallback defaults

    def is_blocked(url):
        return any(domain in url for domain in blocked_domains)

    async def scan_all():
        results = {}
        for url in urls:
            if is_blocked(url):
                results[url] = {"error": "Domain is blocked from scanning."}
            else:
                results[url] = await run_scan_modules(url, modules)
        return results

    scan_results = asyncio.run(scan_all())
    return jsonify(scan_results)

@app.route("/recon", methods=["POST"])
def recon():
    from modules.recon import perform_recon
    data = request.get_json()
    urls = data.get("urls", [])
    results = {url: perform_recon(url) for url in urls}
    return jsonify(results)

if __name__ == "__main__":
    app.run(debug=True)
