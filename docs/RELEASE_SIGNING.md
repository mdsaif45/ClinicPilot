# Release Signing Documentation — ClinicPilot

This document explains how to set up production release signing for ClinicPilot Android builds, how to configure GitHub Actions secrets for CI release builds, and crucial backup guidance.

---

## 1. Generating a Release Keystore

Run the following command in your terminal to generate a Java KeyStore (`.jks`) file:

```bash
keytool -genkey -v -keystore clinicpilot-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias clinicpilot
```

You will be prompted to set passwords and enter organization details.

> [!CAUTION]
> **CRITICAL BACKUP WARNING**:
> Store the generated `clinicpilot-release.jks` file and passwords in a permanent, secure vault (e.g., password manager, secure backup).
>
> If the keystore file or passwords are lost, **no future update can ever be installed over the existing app installation**. Android enforces strict signing certificate matching. The only recovery if a key is lost is an uninstall and reinstall, which **wipes the local SQLite database and erases all patient data**.

---

## 2. Local Gradle Configuration

1. Place `clinicpilot-release.jks` in `android/app/clinicpilot-release.jks` (or root directory matching your `storeFile` path).
2. Create `android/key.properties` (based on `android/key.properties.example`):

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=clinicpilot
storeFile=clinicpilot-release.jks
```

> [!NOTE]
> `android/key.properties` and all `*.jks` files are ignored in `.gitignore` and **must never be committed to git**.

---

## 3. Transitioning from Debug Signing (v0.2.0 -> v0.3.0)

v0.2.0 was distributed with Android debug signing. Moving to production release signing is a **one-time breaking change** for already installed APKs.

Before installing the release-signed v0.3.0 APK on Dr. Zaid's device:
1. Open ClinicPilot v0.2.0.
2. Go to **Settings** -> tap **Export Backup Data (CSV)** to backup all data.
3. Uninstall v0.2.0 from the device.
4. Install the new release-signed v0.3.0 APK.

---

## 4. GitHub Actions CI Secrets Setup

To enable automated signed release builds on GitHub Actions:

1. Encode the keystore file into base64 format:
   ```bash
   base64 -w 0 android/app/clinicpilot-release.jks > keystore.base64.txt
   ```
2. Open your GitHub Repository -> **Settings** -> **Secrets and variables** -> **Actions**.
3. Add the following Repository Secrets:
   - `KEYSTORE_BASE64`: Content of `keystore.base64.txt`
   - `KEYSTORE_PASSWORD`: Keystore store password
   - `KEY_PASSWORD`: Key password
   - `KEY_ALIAS`: Key alias (e.g. `clinicpilot`)

When these secrets are present, `.github/workflows/release.yml` decodes the keystore and builds production-signed APKs. If absent, the workflow safely falls back to debug signing for forks and untagged builds.
