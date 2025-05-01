# 🔍 AWATP – Adaptive Web Application Threat Profiler

AWATP is an adaptive, async-powered Python scanner for web applications. It intelligently fingerprints targets, then dynamically applies selected vulnerability scans based on user input.

Built for **security engineers, red teamers, and AppSec learners**, AWATP offers a modular, terminal-native experience with JSON reporting and flexible CLI automation.

---

## 🚀 Features

- ✅ Asynchronous scanning engine using `httpx.AsyncClient`
- ✅ Fingerprints server headers and tech stack hints
- ✅ Adaptive scan module runner (`sqli`, `xss`, `ssti`)
- ✅ Terminal UI powered by `rich` for beautiful, structured output
- ✅ JSON report generation with auto-timestamped filenames
- ✅ CLI flags for headless use: `--url`, `--json`, `--silent`, `--modules`
- ✅ Modular and extensible payload structure

---

## 🛠️ Usage

You can run AWATP interactively or with command-line flags for automation.

### 🔁 Interactive Mode

```bash
python main.py
```

You'll be prompted to enter a URL. All scans will run unless otherwise specified.

---

### ⚙️ Command-Line Mode

```bash
python main.py --url https://target.com
```

Specify scan modules:

```bash
python main.py --url https://target.com --modules sqli,xss
```

Suppress output but save report:

```bash
python main.py --url https://target.com --json
```

Fully silent mode:

```bash
python main.py --url https://target.com --silent
```

---

### 🔧 CLI Flag Summary

| Flag         | Description                                                              |
|--------------|--------------------------------------------------------------------------|
| `--url`      | Provide a target URL directly                                            |
| `--json`     | Output only JSON report (no console output)                              |
| `--silent`   | Suppress all output except fatal errors                                  |
| `--modules`  | Comma-separated list of scans to run (e.g., `sqli,xss,ssti`)             |

---

## 📂 Project Structure

```
awatp/
├── core/
│   ├── scanner.py
│   ├── fingerprints.py
│   └── payloads/
│       ├── sql.py
│       ├── xss.py
│       └── ssti.py
├── reports/               # Scan output (JSON)
├── utils/
│   └── report_writer.py
├── main.py
├── requirements.txt
├── README.md
└── venv/                  # Local virtual environment (gitignored)
```

---

## 📄 Sample Output

```
🎯 Scanning: https://httpbin.org/anything

📄 Fingerprint Summary
+----------------+---------------------+
| Field          | Value               |
+----------------+---------------------+
| Server         | gunicorn/19.9.0     |
| X-Powered-By   | Unknown             |
| Content-Type   | application/json    |
| Status Code    | 200                 |
+----------------+---------------------+

🧪 Scan Results
+-----------------------------+------------------------+------------+-------------------------------+
| Type                        | Payload                | Vulnerable | Evidence                      |
+-----------------------------+------------------------+------------+-------------------------------+
| SQL Injection               | ...?id=1'              | No         | No obvious SQL errors         |
| Cross-Site Scripting (XSS)  | ...?q=<script>...</>   | No         | Payload not reflected         |
| Server-Side Template (SSTI) | ...?input={{7*7}}      | No         | Payload not evaluated         |
+-----------------------------+------------------------+------------+-------------------------------+

📝 Scan report saved to: reports/scan_httpbin.org_20250501_123456.json
```

---

## 🧠 Inspiration

AWATP is inspired by tools like Nikto and Wapiti but reimagined with modern async architecture, modular payloads, and real-time adaptive scanning logic.

---

## 📜 License

MIT License — use, modify, and contribute freely.

---

## 🤝 Contributing

Want to build more modules or enhance fingerprinting? PRs and forks are welcome.
