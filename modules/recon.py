import socket

def perform_recon(url):
    try:
        ip = socket.gethostbyname(url.replace("https://", "").replace("http://", "").split("/")[0])
        return {"resolved_ip": ip}
    except Exception as e:
        return {"error": str(e)}
