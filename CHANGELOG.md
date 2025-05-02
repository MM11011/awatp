# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial Flask API (`awatp_api.py`) with `/scan` and `/recon` endpoints.
- Modular scanning architecture for XSS, SQLi, SSTI, and Open Redirect.
- Domain blocklist support via `blocked_domains.json`.
- Blocking logic for sensitive domains (e.g. google.com).
- Recon module using DNS resolution.
- Fingerprinting module for tech stack detection.
- Full test coverage for fingerprinting, SQLi, SSTI, and Open Redirect modules.
- Mock-based testing setup using `pytest` and `pytest-asyncio`.
- Structured `tests/` directory with `conftest.py` and individual test modules.
- Configurable backend scanning via module selection in request payload.
- Dart/Flutter UI views: scan, recon.
- Modal alerts for blocked scans in the UI (WIP).
- Frontend integration of scanning with backend via HTTP.

### Changed
- Refactored project structure to follow scalable modular layout.
- Moved scanner logic into `core/scanners.py` with payloads in `core/payloads/`.

### Fixed
- Async issues with scan modules in test cases.
- Import path issues with `core/` module by using PYTHONPATH workaround.

