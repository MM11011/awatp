import asyncio
from core.fingerprints import fingerprint_target
from core.scanner import run_scanner
from utils.report_writer import save_scan_report
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

console = Console()

def main():
    console.print(Panel.fit("[bold cyan]🔍 Adaptive Web Application Threat Profiler (AWATP)[/bold cyan]"))
    target = input("Enter target URL (e.g. https://example.com): ").strip()

    if not target:
        console.print("[red]❌ No URL provided. Exiting.[/red]")
        return

    if not target.startswith("http"):
        console.print("[red]❌ Please include the scheme (http or https) in the URL.[/red]")
        return

    console.print(f"🎯 Scanning: [yellow]{target}[/yellow]")
    info = fingerprint_target(target)

    if info:
        table = Table(title="📄 Fingerprint Summary", show_header=True, header_style="bold magenta")
        table.add_column("Field")
        table.add_column("Value")
        for key, value in info.items():
            table.add_row(key, str(value))
        console.print(table)

        console.print("\n🚀 [bold green]Launching scans...[/bold green]")
        results = asyncio.run(run_scanner(target, info))

        results_table = Table(title="🧪 Scan Results", show_lines=True)
        results_table.add_column("Type", style="bold yellow")
        results_table.add_column("Payload")
        results_table.add_column("Vulnerable")
        results_table.add_column("Evidence")

        for result in results:
            vuln = "[green]🛡️ No[/green]" if not result["vulnerable"] else "[red]❌ Yes[/red]"
            results_table.add_row(result["type"], result["payload"], vuln, result["evidence"])

        console.print(results_table)

        # Save to JSON report
        save_scan_report(target, info, results)
    else:
        console.print("[red]⚠️ Could not retrieve fingerprint data.[/red]")

if __name__ == "__main__":
    main()
