import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from flask import Flask, request, jsonify
from flask_cors import CORS
import asyncio
from core.fingerprints import fingerprint_target
from core.scanner import run_scanner
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from modules.recon import perform_recon

app = Flask(__name__)
CORS(app)  # Enable CORS for all domains


@app.route('/')
def index():
    return jsonify({'message': 'AWATP API is running'})


@app.route('/scan', methods=['POST'])
def scan():
    data = request.get_json()
    urls = data.get('urls', [])
    selected_modules = data.get('modules', [])

    async def run_all():
        results = {}
        for url in urls:
            info = fingerprint_target(url)
            scan_results = await run_scanner(url, info, selected_modules)
            results[url] = {
                "fingerprint": info,
                "results": scan_results
            }
        return results

    final_results = asyncio.run(run_all())
    return jsonify(final_results)


@app.route('/recon', methods=['POST'])
def recon():
    data = request.get_json()
    urls = data.get('urls', [])
    results = {}

    for url in urls:
        recon_result = perform_recon(url)
        results[url] = recon_result

    return jsonify(results)


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)

