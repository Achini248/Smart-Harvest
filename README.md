# 🌿 Smart Harvest

Agricultural platform for farmers, buyers, and agriculture officers in Sri Lanka.

**Stack:** Flutter (Web · iOS · Android) + Flask (Python) backend + Firebase

---

## Project Structure

```
Smart-Harvest-main/
├── backend/          ← Flask API server (Python)
└── frontend/         ← Flutter app (Web, iOS, Android)
```

---

## Backend Setup

### 1. Get your Firebase Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com) → your project
2. ⚙️ Project Settings → **Service accounts** tab
3. Click **"Generate new private key"** → save the downloaded `.json` file
4. Place it at: `backend/serviceAccountKey.json`

### 2. Configure environment
```bash
cd backend
cp .env.example .env
# Edit .env — fill in SECRET_KEY and OPENWEATHER_API_KEY
```

### 3. Install & run
```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux

pip install -r requirements.txt
python app.py
# ✅ Running on http://localhost:5000
```

---

## Frontend Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0  →  https://flutter.dev/docs/get-started/install
- Chrome (for web), Android Studio (for Android), Xcode (for iOS)

### Install dependencies
```bash
cd frontend
flutter pub get
```

---

## Running the App

### 🌐 Web
```bash
cd frontend
flutter run -d chrome
```
Backend URL auto-resolves to `http://localhost:5000`.

### 📱 Android (emulator or device)
```bash
flutter run -d android
```
Backend URL auto-resolves to `http://10.0.2.2:5000` (emulator loopback to host).

For a **real Android device** on the same WiFi network:
```bash
flutter run -d android --dart-define=API_BASE_URL=http://YOUR_LOCAL_IP:5000
```

### 🍎 iOS (simulator or device)
```bash
flutter run -d ios
```
Backend URL auto-resolves to `http://localhost:5000`.

For a **real iOS device**:
```bash
flutter run -d ios --dart-define=API_BASE_URL=http://YOUR_LOCAL_IP:5000
```

---

## Building for Production

### Web
```bash
flutter build web --release
# Output: frontend/build/web/
# Deploy to Firebase Hosting, Netlify, Vercel, etc.
```

### Android APK
```bash
flutter build apk --release
# Output: frontend/build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires macOS + Xcode)
```bash
flutter build ios --release
```

---

## Firebase Configuration

The app uses Firebase for:
- **Authentication** (email/password + Google Sign-In)
- **Firestore** (real-time database)
- **Cloud Messaging** (push notifications — mobile only by default)

Firebase options are pre-configured in `frontend/lib/firebase_options.dart`.

For web Google Sign-In, ensure `localhost` is added to your Firebase Console:
> Authentication → Sign-in method → Google → Authorised domains → Add `localhost`

---

## Environment Variables

| Variable | Where | Purpose |
|---|---|---|
| `FIREBASE_CREDENTIALS` | `backend/.env` | Path to `serviceAccountKey.json` |
| `FIREBASE_PROJECT_ID` | `backend/.env` | Firebase project ID |
| `OPENWEATHER_API_KEY` | `backend/.env` | OpenWeatherMap API key |
| `SECRET_KEY` | `backend/.env` | Flask secret key |
| `API_BASE_URL` | Flutter `--dart-define` | Override backend URL (real devices) |
| `VAPID_KEY` | Flutter `--dart-define` | Firebase web push VAPID key (optional) |

---

## Security

⚠️ **Never commit these files:**
- `backend/serviceAccountKey.json`
- `backend/.env`

Both are listed in `.gitignore`.
