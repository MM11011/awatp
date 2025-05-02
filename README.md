# 🔍 AWATP – Adaptive Web Application Threat Profiler

AWATP is an adaptive, async-powered Python scanner for web applications. It intelligently fingerprints targets, then dynamically applies selected vulnerability scans based on user input.

Built for security engineers and AppSec enthusiasts, AWATP provides both a command-line tool and a web-based UI powered by Flutter.

---

## 🚀 Features

- ✅ Asynchronous scanning engine using `httpx.AsyncClient`
- ✅ Fingerprints server headers and technologies
- ✅ Selective scan modules: `SQLi`, `XSS`, `SSTI`
- ✅ JSON report generation with auto-timestamped filenames
- ✅ CLI and Web UI support
- ✅ Modular architecture for custom payloads
- ✅ Rich terminal output with `rich`
- ✅ Cross-origin enabled Flask API backend
- ✅ Multi-target scanning (CLI and Web UI)

---

## 🛠️ Usage

### 🔁 CLI Mode (Python)

From the `awatp/` directory:

```bash
source venv/bin/activate
python main.py --url https://example.com --modules sqli,xss
```

### 📁 Multi-URL Scanning

You can scan many targets from a file:

```bash
python main.py --input targets.txt --modules sqli,xss
```

Each line in the file should be a full URL including `http` or `https`.
A report will be saved for each target in `/reports/`.

---

### 📡 API Mode (Python Flask)

```bash
cd awatp/
source venv/bin/activate
python awatp_api.py
```

Make sure your `awatp_api.py` includes this:

```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.run(host='0.0.0.0', port=5000)
```

This allows CORS access and enables access from your local network.

---

### 🖼 Web UI Mode (Flutter)

In a separate terminal:

```bash
cd awatp_ui/
flutter pub get
flutter run -d chrome
```

Then in the browser:
- Enter one or more URLs (one per line)
- Select modules
- Click "Run Scan"
- Results will appear below, and are saved to `/awatp/reports/`

---

### 🌐 Multi-Target Support (Web)

You can enter multiple target URLs (one per line) directly in the Flutter UI.

- Each URL will be scanned individually
- Results will be displayed in their own card
- Works with all module combinations

Make sure your Flask backend is running at your machine's local IP address,
and that CORS is enabled with `CORS(app)` in `awatp_api.py`.

Update `main.dart` with:

```dart
Uri.parse('http://192.168.x.x:5000/scan')
```

---

## ⚙️ CLI Flags Summary

| Flag         | Description                                                        |
|--------------|--------------------------------------------------------------------|
| `--url`      | Target URL to scan                                                 |
| `--input`    | Path to file containing URLs to scan                               |
| `--modules`  | Comma-separated list of modules to run (`sqli,xss,ssti`)           |
| `--json`     | Suppress terminal output; JSON report only                         |
| `--silent`   | Suppress all output except critical errors                         |

---

## 📂 Project Structure

```
/Projects/
├── awatp/         ← Python scanner + API
│   ├── core/
│   ├── reports/
│   ├── utils/
│   ├── main.py
│   ├── awatp_api.py
│   ├── requirements.txt
│   └── venv/
└── awatp_ui/      ← Flutter web UI
    ├── lib/
    ├── pubspec.yaml
    └── ...
```

---

## 🧪 Sample Output

```json
{
  "target": "https://httpbin.org/anything",
  "fingerprint": {
    "Server": "gunicorn/19.9.0",
    ...
  },
  "results": [
    {
      "type": "SQL Injection",
      "vulnerable": false,
      ...
    }
  ]
}
```

---

## 💡 Dual Launch Option (CLI + Web)

To launch CLI or Web UI easily:

```bash
# Launch CLI scan
source venv/bin/activate
python main.py --url https://example.com --modules sqli,xss

# Launch Web UI
# Terminal 1:
cd awatp/
source venv/bin/activate
python awatp_api.py

# Terminal 2:
cd awatp_ui/
flutter run -d chrome
```

---

## 📜 License

MIT License
