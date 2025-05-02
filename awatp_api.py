from flask import Flask, request, jsonify
from flask_cors import CORS
import asyncio
import logging

from core.scanners import run_scan_modules
from core.recon import perform_recon
from utils.blocklist import is_blocked_domain

app = Flask(__name__)
CORS(app)

logging.basicConfig(filename="awatp.log", level=logging.INFO)


@app.route("/scan", methods=["POST"])
def scan():
    data = request.get_json()
    if not data or "urls" not in data or "modules" not in data:
        return jsonify({"error": "Missing URLs or modules"}), 400

    urls = data["urls"]
    modules = data["modules"]
    results = {}

    async def scan_all():
        async with asyncio.TaskGroup() as tg:
            for url in urls:
                tg.create_task(scan_one(url))

    async def scan_one(url):
        if is_blocked_domain(url):
            logging.warning(f"Blocked scan attempt for URL: {url}")
            results[url] = {"error": "Blocked domain"}
            return

        logging.info(f"Scan started for {url} using modules: {modules}")
        async with asyncio.ClientSession() as client:
            scan_result = await run_scan_modules(client, url, modules)
            results[url] = scan_result
        logging.info(f"Scan completed for {url}: {scan_result}")

    asyncio.run(scan_all())
    return jsonify(results)


@app.route("/recon", methods=["POST"])
def recon():
    data = request.get_json()

    if not data or "url" not in data:
        return jsonify({"error": "Missing URL"}), 400

    target_url = data["url"]
    result = perform_recon(target_url)
    return jsonify(result)


if __name__ == "__main__":
    app.run(debug=True)
