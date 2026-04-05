# SmartHarvest — Deployment Guide

## What Was Fixed
The following overflow bugs have been resolved:
- **Government Dashboard KPI cards** — `childAspectRatio` changed from `1.4` → `1.1`, card padding reduced
- **Analytics page KPI cards** — `childAspectRatio` changed from `1.55` → `1.3`
- **Crop Detail page info cards** — `childAspectRatio` changed from `1.5` → `1.2`
- **StatsCard widget** — padding reduced, `mainAxisSize: min` added, text gets `maxLines` guard

---

## Part 1 — Deploy the Backend to Render (Free)

### Step 1 — Push backend to GitHub

```bash
cd SmartHarvest-fixed/backend
git init
git add .
git commit -m "SmartHarvest backend initial"

# Create a NEW PRIVATE repo on github.com first, then:
git remote add origin https://github.com/YOUR_USERNAME/smartharvest-backend.git
git branch -M main
git push -u origin main
```

> ⚠️ The `.gitignore` already excludes `.env` and `serviceAccountKey.json`. Never commit these.

---

### Step 2 — Get your Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com) → your project `smart-harvest-f27d4`
2. Click the ⚙️ gear icon → **Project Settings** → **Service accounts** tab
3. Click **Generate new private key** → Download the JSON file
4. Rename it `serviceAccountKey.json`

---

### Step 3 — Deploy on Render

1. Go to [render.com](https://render.com) → **Sign up with GitHub**
2. Click **New +** → **Web Service**
3. Connect your `smartharvest-backend` GitHub repo
4. Configure:
   | Field | Value |
   |---|---|
   | **Runtime** | Python 3 |
   | **Build Command** | `pip install -r requirements.txt` |
   | **Start Command** | `gunicorn "app:create_app()" --bind 0.0.0.0:$PORT --workers 2 --timeout 120` |
   | **Instance Type** | Free |

5. Scroll to **Environment Variables** → Add each one:

   | Key | Value |
   |---|---|
   | `SECRET_KEY` | any long random string e.g. `sh-prod-k3y-2026!xZ9` |
   | `FLASK_DEBUG` | `false` |
   | `FIREBASE_PROJECT_ID` | `smart-harvest-f27d4` |
   | `FIREBASE_CREDENTIALS` | `serviceAccountKey.json` |
   | `OPENWEATHER_API_KEY` | get free key from openweathermap.org |
   | `SMTP_HOST` | `smtp.gmail.com` |
   | `SMTP_PORT` | `587` |
   | `SMTP_USER` | your Gmail address |
   | `SMTP_PASSWORD` | your 16-char Gmail App Password |
   | `SMTP_FROM` | your Gmail address |

6. Under **Files** tab (or use Render's Secret Files feature):
   - Upload `serviceAccountKey.json` as a **Secret File** at path `serviceAccountKey.json`

7. Click **Create Web Service** → Wait ~3 minutes

8. Your backend URL will be: `https://smartharvest-backend-XXXX.onrender.com`
   - Test it: open `https://your-url.onrender.com/health` → should return `{"status":"ok"}`

---

## Part 2 — Update Flutter App to Point to Your Backend

### Option A — Build-time (recommended for release APK)

Pass your Render URL via `--dart-define` when building:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://smartharvest-backend-XXXX.onrender.com
```

This bakes the URL into the APK so all API calls go to your server automatically.

### Option B — Runtime (no rebuild needed, great for testing)

After installing the app on a real device:

1. Go to **Profile → Server URL**
2. Enter your Render URL: `https://smartharvest-backend-XXXX.onrender.com`
3. Tap **Save & Apply**

The app will persist this URL and use it for all requests immediately.

> **Note:** On an Android emulator, the app automatically uses `http://10.0.2.2:5000` (which maps to localhost on your computer). On a real phone on the same Wi-Fi as your computer, use `http://YOUR_COMPUTER_LAN_IP:5000` (e.g. `http://192.168.1.45:5000`) or your Render URL.

---

## Part 3 — Build the Android APK

### Prerequisites (install once)

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install (choose your OS)
   - After install run: `flutter doctor` and fix any issues shown
2. **Android Studio** — https://developer.android.com/studio
   - During install, accept Android SDK licenses: `flutter doctor --android-licenses`

### Step 2 — Build the release APK

```bash
cd SmartHarvest-fixed/frontend

# Install dependencies
flutter pub get

# Build release APK (replace with your actual Render URL)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://smartharvest-backend-XXXX.onrender.com
```

> If you skip `--dart-define`, users can still set the server URL inside the app via **Profile → Server URL**.

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3 — Install on your phone

**Option A — USB (easiest):**
```bash
flutter install   # with phone connected via USB, USB debugging ON
```

**Option B — Copy APK to phone:**
1. Transfer `app-release.apk` to your phone via USB or Google Drive
2. On the phone: Settings → Security → **Install unknown apps** → allow your file manager
3. Tap the APK file to install

---

## Part 4 — (Optional) Share with Others via Firebase App Distribution

1. In Firebase Console → **App Distribution**
2. Upload the `app-release.apk`
3. Add tester email addresses
4. Testers get an email with a download link

---

## Part 5 — (Optional) Publish to Google Play Store

1. Build a signed app bundle:
   ```bash
   flutter build appbundle --release
   ```
2. Create a keystore (one-time):
   ```bash
   keytool -genkey -v -keystore ~/smartharvest.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smartharvest
   ```
3. Sign and upload `build/app/outputs/bundle/release/app-release.aab` to Play Console

---

## Quick Reference

| Service | URL | Purpose |
|---|---|---|
| Render | render.com | Backend hosting (free) |
| Firebase | console.firebase.google.com | Auth + Firestore |
| OpenWeatherMap | openweathermap.org/api | Weather data (free) |
| Gmail App Password | myaccount.google.com/apppasswords | OTP emails |
