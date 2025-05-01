import asyncio
import httpx
from core.payloads import sql, xss, ssti

async def run_scanner(url, fingerprint_info, selected_modules=None):
    print("🛠️  Running async vulnerability scanner...")

    async with httpx.AsyncClient() as client:
        tasks = []

        if selected_modules is None or "sqli" in selected_modules:
            tasks.append(sql.scan_for_sqli(client, url))

        if selected_modules is None or "xss" in selected_modules:
            tasks.append(xss.scan_for_xss(client, url))

        if selected_modules is None or "ssti" in selected_modules:
            tasks.append(ssti.scan_for_ssti(client, url))

        results = await asyncio.gather(*tasks)

    return results
