# core/payloads/ssti.py

async def scan_for_ssti(client, url):
    payload = "{{7*7}}"
    try:
        response = await client.get(url, params={"q": payload}, timeout=10)
        vulnerable = "49" in response.text
        return {
            "type": "SSTI",
            "payload": payload,
            "evidence": response.text if vulnerable else "No SSTI detected",
            "vulnerable": vulnerable,
            "ssti": int(vulnerable)
        }
    except Exception as e:
        return {
            "error": str(e),
            "ssti": 0
        }
