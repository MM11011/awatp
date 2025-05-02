import whois
import dns.resolver

def perform_recon(url):
    try:
        domain = url.replace("http://", "").replace("https://", "").split("/")[0]

        whois_info = whois.whois(domain)
        dns_info = dns.resolver.resolve(domain, 'A')

        return {
            "domain": domain,
            "whois": {
                "registrar": whois_info.registrar,
                "creation_date": str(whois_info.creation_date),
                "expiration_date": str(whois_info.expiration_date),
            },
            "dns": [rdata.to_text() for rdata in dns_info]
        }

    except Exception as e:
        return {"error": str(e)}
