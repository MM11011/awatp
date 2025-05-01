import argparse
import asyncio
import os
from core.fingerprints import fingerprint_target
from core.scanner import run_scanner
from utils.report_writer import save_scan_report
from rich import print
from rich.prompt import Prompt

def parse_args():
    parser = argparse.ArgumentParser(description="AWATP: Adaptive Web App Threat Profiler")
    parser.add_argument("--url", help="Target URL (e.g., https://example.com)")
    parser.add_argument("--input", help="File with list of URLs to scan")
    parser.add_argument("--json", action="store_true", help="Output JSON only (suppress console output)")
    parser.add_argument("--silent", action="store_true", help="Suppress all console output")
    parser.add_argument("--modules", help="Comma-separated list of modules (e.g., sqli,xss,ssti)")
    return parser.parse_args()

async def scan_target(url, modules, silent, json_output):
    if not silent:
        print(f"\n🎯 [bold]Scanning:[/bold] {url}")

    fingerprint = fingerprint_target(url)
    selected_modules = modules.split(",") if modules else None
    results = await run_scanner(url, fingerprint, selected_modules)

    if not silent and not json_output:
        print("\n📄 [bold]Fingerprint Summary:[/bold]")
        for k, v in fingerprint.items():
            print(f"  {k}: {v}")

        print("\n🧪 [bold]Scan Results:[/bold]")
        for r in results:
            print(f"  {r['type']}: [bold]{'VULNERABLE' if r['vulnerable'] else 'Safe'}[/bold]")

    save_scan_report(url, fingerprint, results)

def main():
    args = parse_args()
    targets = []

    if args.input:
        if not os.path.exists(args.input):
            print(f"[red]❌ Input file not found: {args.input}[/red]")
            return
        with open(args.input, "r") as f:
            targets = [line.strip() for line in f if line.strip()]
    elif args.url:
        targets = [args.url]
    else:
        # Interactive fallback
        target = Prompt.ask("🔍 Enter target URL (e.g. https://example.com)")
        targets = [target]

    loop = asyncio.get_event_loop()
    for url in targets:
        loop.run_until_complete(scan_target(url, args.modules, args.silent, args.json))

if __name__ == "__main__":
    main()
