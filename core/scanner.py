import asyncio
import httpx
from core.payloads import sql, xss, ssti

async def run_scanner(url, fingerprint_info):
    print("🛠️  Running async vulnerability scanner...")

    async with httpx.AsyncClient() as client:
        tasks = [
            sql.scan_for_sqli(client, url),
            xss.scan_for_xss(client, url),
            ssti.scan_for_ssti(client, url),
        ]

        results = await asyncio.gather(*tasks)

    return results
