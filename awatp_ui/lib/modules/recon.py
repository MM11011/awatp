import socket
import json
import whois
import requests
import dns.resolver

def perform_recon(url):
    results = {
        "url": url,
        "dns_records": {},
        "whois": {},
        "ip_geolocation": {},
        "headers": {},
        "open_ports": [],
        "tech_stack": []
    }

    try:
        # Extract domain from URL
        domain = url.replace("http://", "").replace("https://", "").split("/")[0]
        ip = socket.gethostbyname(domain)

        # DNS Records
        for record_type in ["A", "MX", "NS"]:
            try:
                answers = dns.resolver.resolve(domain, record_type)
                results["dns_records"][record_type] = [str(rdata) for rdata in answers]
            except Exception:
                results["dns_records"][record_type] = []

        # WHOIS
        try:
            whois_data = whois.whois(domain)
            results["whois"] = {k: str(v) for k, v in whois_data.items() if v}
        except Exception:
            results["whois"] = {"error": "WHOIS lookup failed"}

        # IP Geolocation (using ip-api.com)
        try:
            geo = requests.get(f"http://ip-api.com/json/{ip}").json()
            results["ip_geolocation"] = geo
        except Exception:
            results["ip_geolocation"] = {"error": "Geolocation lookup failed"}

        # Headers
        try:
            resp = requests.get(url, timeout=5)
            results["headers"] = dict(resp.headers)
        except Exception:
            results["headers"] = {"error": "Could not retrieve headers"}

        # Port scan (basic)
        common_ports = [21, 22, 80, 443, 8080]
        for port in common_ports:
            try:
                sock = socket.create_connection((ip, port), timeout=2)
                results["open_ports"].append(port)
                sock.close()
            except:
                pass

        # Tech fingerprinting (simple)
        techs = []
        headers = results.get("headers", {})
        if "server" in headers:
            techs.append(headers["server"])
        if "x-powered-by" in headers:
            techs.append(headers["x-powered-by"])
        results["tech_stack"] = techs

    except Exception as e:
        results["error"] = str(e)

    return results
