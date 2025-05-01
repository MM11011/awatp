import json
import os
from datetime import datetime
from rich.console import Console

console = Console()

def save_scan_report(target_url, fingerprint_info, scan_results):
    # Ensure reports directory exists
    os.makedirs("reports", exist_ok=True)

    # Format timestamp and sanitize filename
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    safe_url = target_url.replace("https://", "").replace("http://", "").replace("/", "_")
    filename = f"reports/scan_{safe_url}_{timestamp}.json"

    # Report structure
    report_data = {
        "target": target_url,
        "timestamp": timestamp,
        "fingerprint": fingerprint_info,
        "results": scan_results
    }

    try:
        with open(filename, "w") as f:
            json.dump(report_data, f, indent=4)
        console.print(f"\n📝 [bold blue]Scan report saved to:[/bold blue] {filename}")
    except Exception as e:
        console.print(f"[red]❌ Failed to save report:[/red] {e}")
