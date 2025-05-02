# AWATP (Adaptive Web Application Threat Profiler)

AWATP is a hybrid CLI + Flutter-based adaptive web application vulnerability scanner. It enables multi-target scanning using selectable modules (SQLi, XSS, SSTI), provides fingerprinting, and generates downloadable per-scan and batch reports in JSON or ZIP.

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
├── reports/
├── utils/
│   ├── parser.py
│   └── report_writer.py
├── awatp_api.py
├── main.py
├── test.py
├── requirements.txt
├── .gitignore
├── .gitattributes
├── README.md
└── awatp_ui/ (Flutter UI)
```

---

## 🚀 Features

- Multi-target URL scanning (CLI + Web UI)
- Modular vulnerability scanning (SQLi, XSS, SSTI)
- JSON-based scan reports (CLI + Web)
- Download scan results individually or in batch (ZIP)
- Real-time scan status updates in UI
- Fingerprint detection (headers, status, etc.)
- Flask backend API for asynchronous scan handling

---

## 📦 Requirements

### Python
- Python 3.8+
- Flask

Install Python dependencies:
```bash
pip install -r requirements.txt
```

### Flutter UI
- Flutter 3.x
- Dart SDK
- VS Code or Android Studio
- Chrome (for web testing)

---

## 🧪 Usage

### Run Backend API (Python)
```bash
python awatp_api.py
```

Make sure it's running at:
```
http://<your_local_ip>:5000
```

---

### Run Flutter Frontend
```bash
cd awatp_ui
flutter run -d chrome
```

Ensure `lib/main.dart` is updated to use your local IP for the Flask backend.

---

## 📝 Scan Results

- CLI and Flutter generate JSON reports under `reports/`
- Each scan result is named: `scan_<domain>_<timestamp>.json`
- The Flutter app offers:
  - Individual scan download 📥
  - Batch export as ZIP 🗂️

---

## ✅ Next Features (Roadmap)

- 🔄 Scan progress bar in UI
- 🌐 Scan history browser
- 📊 Threat dashboard
- 📤 Export as CSV / PDF
- 🔒 Login & role-based access

---

© 2025 AWATP Project
