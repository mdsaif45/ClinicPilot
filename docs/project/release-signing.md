# Release Signing & CI Deployment Guide — ClinicPilot

This document explains production release signing for ClinicPilot Android builds, keystore management protocols, local and CI build procedures, transition procedures across signing keys, and emergency backup guidance.

---

## Table of Contents
1. [Overview & Security Architecture](#1-overview--security-architecture)
2. [Generating a Production Release Keystore](#2-generating-a-production-release-keystore)
3. [Local Gradle Configuration](#3-local-gradle-configuration)
4. [Building Production Release Artifacts](#4-building-production-release-artifacts)
5. [Transitioning from Debug Signing (v0.2.0 -> v0.3.0+)](#5-transitioning-from-debug-signing-v020---v030)
6. [GitHub Actions CI Secrets Setup](#6-github-actions-ci-secrets-setup)
7. [Verifying Keystore Signatures & Fingerprints](#7-verifying-keystore-signatures--fingerprints)

---

## 1. Overview & Security Architecture

Android strictly enforces signing certificate matching for application updates. An APK or Android App Bundle (AAB) signed with a given key can only be updated by a package bearing the exact same cryptographic signature.

> [!CAUTION]
> **CRITICAL BACKUP WARNING**:
> Store the generated `clinicpilot-release.jks` keystore file and all associated passwords in a permanent, encrypted vault (e.g., 1Password, Bitwarden, secure offline physical backup).
>
> If the keystore file or passwords are lost, **no future update can ever be installed over the existing app installation**. The only recovery is a complete uninstall and reinstall, which **wipes the local SQLite database and permanently erases all on-device patient records**.

---

## 2. Generating a Production Release Keystore

To generate a Java KeyStore (`.jks`) using standard JDK tools:

```bash
keytool -genkey -v -keystore clinicpilot-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias clinicpilot
```

You will be prompted to supply:
1. **Keystore password**: Master password protecting the keystore file.
2. **Key password**: Password protecting the specific alias private key (recommend matching keystore password).
3. **Distinguished Name (DName)** fields: Organization name, unit, city, state, country code.

---

## 3. Local Gradle Configuration

1. Place `clinicpilot-release.jks` into `android/app/` (or the project root matching your `storeFile` path).
2. Create `android/key.properties` (modeled after `android/key.properties.example`):

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=clinicpilot
storeFile=clinicpilot-release.jks
```

> [!NOTE]
> `android/key.properties` and all `*.jks` / `*.keystore` files are explicitly excluded via `.gitignore` and **must never be committed to git**.

In `android/app/build.gradle.kts`, the signing configuration dynamically resolves `key.properties`:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

---

## 4. Building Production Release Artifacts

### 4.1 Production Sideloaded APKs (Split per ABI)
For direct distribution to doctors (via WhatsApp, flash drive, or GitHub Releases), build ABI-specific APKs to keep download sizes around 16–30 MB:

```powershell
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

Generated binaries will be located at:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (modern 64-bit Android devices)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (legacy 32-bit devices)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (emulators / Chromebooks)

### 4.2 Production Google Play App Bundle (AAB)
For Google Play Store submission:

```powershell
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

Generated binary:
- `build/app/outputs/bundle/release/app-release.aab`

---

## 5. Transitioning from Debug Signing (v0.2.0 -> v0.3.0+)

Version `v0.2.0` was distributed with Android debug signing. Transitioning to official production signing is a **one-time breaking change** for devices running pre-v0.3.0 builds:

Before installing a release-signed APK on existing test devices:
1. Open ClinicPilot v0.2.0.
2. Navigate to **Settings** -> tap **Export Backup Data (CSV)** (or export `.cpbak` archive) to preserve all patient records and transactions.
3. Uninstall the debug v0.2.0 build from the device.
4. Install the new release-signed APK.
5. Restore records via **Settings > Import Backup**.

---

## 6. GitHub Actions CI Secrets Setup

Automated release workflows (`.github/workflows/release.yml`) build production-signed APKs and AABs automatically when Git release tags (e.g. `v0.9.0`) are pushed.

### 6.1 Encoding the Keystore
Encode the local `.jks` file to a Base64 ASCII string:

```bash
# Linux / macOS / Git Bash
base64 -w 0 android/app/clinicpilot-release.jks > keystore.base64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/clinicpilot-release.jks")) | Out-File -Encoding ASCII keystore.base64.txt
```

### 6.2 Configuring GitHub Repository Secrets
1. Navigate to your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions**.
2. Register the following Repository Secrets:

| Secret Name | Content / Description |
|---|---|
| `KEYSTORE_BASE64` | Raw text content of `keystore.base64.txt` |
| `KEYSTORE_PASSWORD` | The master keystore protection password |
| `KEY_PASSWORD` | The specific key alias password |
| `KEY_ALIAS` | Key alias name (e.g. `clinicpilot`) |

When these secrets are configured, `.github/workflows/release.yml` decodes the keystore into `android/app/clinicpilot-release.jks`, generates `android/key.properties`, and builds signed production artifacts. If secrets are absent (such as on public forks), the CI safely falls back to unsigned/debug artifacts.

---

## 7. Verifying Keystore Signatures & Fingerprints

To inspect the SHA-1, SHA-256, and MD5 fingerprints of your keystore:

```bash
keytool -list -v -keystore clinicpilot-release.jks -alias clinicpilot
```

To verify the signature of a compiled APK:

```bash
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
