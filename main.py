import asyncio
import argparse
from core.fingerprints import fingerprint_target
from core.scanner import run_scanner
from utils.report_writer import save_scan_report
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

console = Console()

def parse_args():
    parser = argparse.ArgumentParser(description="Adaptive Web Application Threat Profiler (AWATP)")
    parser.add_argument("--url", type=str, help="Target URL to scan")
    parser.add_argument("--json", action="store_true", help="Output JSON report only, suppress terminal output")
    parser.add_argument("--silent", action="store_true", help="Suppress all output except errors")
    return parser.parse_args()

def main():
    args = parse_args()
    target = args.url

    if not target:
        if args.silent:
            return
        console.print(Panel.fit("[bold cyan]🔍 Adaptive Web Application Threat Profiler (AWATP)[/bold cyan]"))
        target = input("Enter target URL (e.g. https://example.com): ").strip()

    if not target:
        if not args.silent:
            console.print("[red]❌ No URL provided. Exiting.[/red]")
        return

    if not target.startswith("http"):
        if not args.silent:
            console.print("[red]❌ Please include the scheme (http or https) in the URL.[/red]")
        return

    if not args.silent:
        console.print(f"🎯 Scanning: [yellow]{target}[/yellow]")

    fingerprint = fingerprint_target(target)

    if not fingerprint:
        if not args.silent:
            console.print("[red]⚠️ Could not retrieve fingerprint data.[/red]")
        return

    if not args.json and not args.silent:
        table = Table(title="📄 Fingerprint Summary", show_header=True, header_style="bold magenta")
        table.add_column("Field")
        table.add_column("Value")
        for key, value in fingerprint.items():
            table.add_row(key, str(value))
        console.print(table)
        console.print("\n🚀 [bold green]Launching scans...[/bold green]")

    results = asyncio.run(run_scanner(target, fingerprint))

    if not args.json and not args.silent:
        results_table = Table(title="🧪 Scan Results", show_lines=True)
        results_table.add_column("Type", style="bold yellow")
        results_table.add_column("Payload")
        results_table.add_column("Vulnerable")
        results_table.add_column("Evidence")

        for result in results:
            vuln = "[green]🛡️ No[/green]" if not result["vulnerable"] else "[red]❌ Yes[/red]"
            results_table.add_row(result["type"], result["payload"], vuln, result["evidence"])

        console.print(results_table)

    save_scan_report(target, fingerprint, results)

if __name__ == "__main__":
    main()
