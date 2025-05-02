# AWATP (Adaptive Web Application Threat Profiler)

AWATP is a Python-based, modular web application vulnerability scanner designed for extensibility and rapid development of new security detection logic.

## Features

- ✅ Modular scan architecture (SQLi, XSS, SSTI, Open Redirect)
- ✅ Flask REST API with endpoints for `/scan` and `/recon`
- ✅ Flutter-based frontend (UI) with dark mode
- ✅ Target blacklist support via `blocked_domains.json`
- ✅ Configurable module selection via `--modules` flag
- ✅ Fingerprinting endpoint for initial tech reconnaissance
- ✅ Unit test coverage using `pytest` & `pytest-asyncio`

## Project Structure

```
awatp/
├── core/
│   ├── payloads/
│   │   ├── sqli.py
│   │   ├── xss.py
│   │   ├── ssti.py
│   │   └── open_redirect.py
│   ├── scanners.py
│   ├── fingerprints.py
│   └── __init__.py
├── tests/
│   ├── test_fingerprint_url.py
│   ├── test_open_redirect.py
│   ├── test_sql_injection.py
│   ├── test_ssti.py
│   ├── conftest.py
│   └── test_utils.py
├── awatp_api.py
├── targets.txt
├── requirements.txt
└── README.md
```

## Usage

### Run Flask API

```bash
python -m awatp_api
```

### Example Scan Request

```bash
curl -X POST http://localhost:5000/scan \
  -H "Content-Type: application/json" \
  -d '{"urls": ["https://example.com"], "modules": ["sqli", "xss"]}'
```

### Run Tests

```bash
PYTHONPATH=. pytest tests/
```

## License

MIT
