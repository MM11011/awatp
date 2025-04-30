from core.fingerprints import fingerprint_target

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
    else:
        print("⚠️ Could not retrieve fingerprint data.")

if __name__ == "__main__":
    main()

