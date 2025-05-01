import json
import os
from datetime import datetime

def save_scan_report(target_url, fingerprint_info, scan_results):
    # Create reports directory if it doesn't exist
    os.makedirs("reports", exist_ok=True)

    # Timestamp for file name
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    safe_url = target_url.replace("https://", "").replace("http://", "").replace("/", "_")
    filename = f"reports/scan_{safe_url}_{timestamp}.json"

    report_data = {
        "target": target_url,
        "timestamp": timestamp,
        "fingerprint": fingerprint_info,
        "results": scan_results
    }

    with open(filename, "w") as f:
        json.dump(report_data, f, indent=4)

    print(f"\n📝 Scan report saved to: {filename}")
