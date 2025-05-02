from flask import Flask, request, jsonify
from core.fingerprints import fingerprint_target
from core.scanner import run_scanner
from utils.report_writer import save_scan_report
from flask_cors import CORS
import asyncio
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes


@app.route("/scan", methods=["POST"])
def scan():
    data = request.json
    url = data.get("url")
    modules = data.get("modules")  # Expected: list of strings

    if not url:
        return jsonify({"error": "URL is required"}), 400

    fingerprint = fingerprint_target(url)
    selected = [m.lower() for m in modules] if modules else None

    results = asyncio.run(run_scanner(url, fingerprint, selected))

    save_scan_report(url, fingerprint, results)

    return jsonify({
        "target": url,
        "fingerprint": fingerprint,
        "results": results
    })

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=5000, debug=True)

