from core.fingerprints import fingerprint_target
from core.scanner import run_scanner

def main():
    print("🔍 Adaptive Web Application Threat Profiler")
    target = input("Enter target URL (e.g. https://example.com): ").strip()

    if not target.startswith("http"):
        print("❌ Please include the scheme (http or https) in the URL.")
        return

    print(f"🎯 Scanning: {target}")
    info = fingerprint_target(target)

    if info:
        print("\n📄 Fingerprint Summary:")
        for key, value in info.items():
            print(f"  {key}: {value}")

        print("\n🚀 Launching scans...")
        results = run_scanner(target, info)

        print("\n🧪 Scan Results:")
        for result in results:
            print(f"  - {result['type']}: {'✅ Vulnerable' if result['vulnerable'] else '🛡️ Not Vulnerable'}")
            print(f"    Payload: {result['payload']}")
            print(f"    Evidence: {result['evidence']}")
    else:
        print("⚠️ Could not retrieve fingerprint data.")

if __name__ == "__main__":
    main()
