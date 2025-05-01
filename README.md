# 🔍 Adaptive Web Application Threat Profiler (AWATP)

AWATP is a Python-based security tool designed to **scan web applications intelligently** by adapting its vulnerability probes based on fingerprinted server-side technology and response behavior.

It goes beyond static scans by modifying payloads and techniques in real-time depending on:
- Detected server headers
- Tech stack hints (e.g., PHP, Flask, Node)
- Error and status code feedback

---

## 🚀 Features

- ✅ Server fingerprinting based on HTTP response headers  
- ✅ Adaptive scanning engine that selects payloads based on detected stack  
- ✅ Basic SQL Injection detection module (PHP-specific)  
- ✅ CLI-based interaction with structured output  
- ✅ Designed with security analysts and SEs in mind
- ✅ Reflected XSS detection module
- ✅ Server-Side Template Injection (SSTI) detection module
- ✅ Enhanced terminal output using `rich` for structured, colored display

## Dependencies
- [httpx](https://www.python-httpx.org/) – HTTP requests with async support
- [rich](https://rich.readthedocs.io/) – Terminal styling and pretty tables


---

## 📂 Project Structure

awatp/
├── core/
│   ├── scanner.py            
│   ├── fingerprints.py       
│   └── payloads/
│       ├── sql.py            
│       ├── xss.py            
│       └── ssti.py           
├── reports/                  
├── utils/
│   └── parser.py             
├── main.py                   
├── requirements.txt          
├── README.md                 
└── venv/                     

---

## 🛠️ Getting Started

### 1. Clone and Set Up

```bash
git clone https://github.com/YOUR_USERNAME/awatp.git
cd awatp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
2. Run the Profiler
bash
Copy
Edit
python main.py
Enter a target URL when prompted (e.g., https://httpbin.org).

📌 Roadmap
- [x] Implement adaptive payload modules (SQLi for PHP)
- [x] Add XSS and SSTI scanning support (both complete)
- [ ] Add concurrent scanning for multiple URLs
- [ ] Write scan results to structured JSON
- [ ] Web UI (Flask or Streamlit)
- [ ] Docker support for easy deployment

🧠 Inspiration
This project is inspired by traditional scanners like Nikto and Wapiti, but with a modern, adaptive approach using Python and real-time server analysis. Great for security engineers, SOC analysts, and AppSec learners.

🤝 Contributing
Pull requests and feature ideas welcome — let’s build something useful for defenders, testers, and red teamers alike.

📜 License
MIT License
