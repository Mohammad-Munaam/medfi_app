# MEDFI - Emergency Ambulance App 🚑

MEDFI is a premium emergency ambulance service application built with Flutter. It provides real-time tracking, seamless driver-user interaction, and reliable emergency medical assistance.

## ✨ Features

- **Real-time Tracking**: Integrated with Google Maps for precise ambulance and user location monitoring.
- **Instant Authentication**: Secure login via Firebase and Google Sign-In.
- **Emergency Notifications**: Real-time alerts using Firebase Cloud Messaging and Local Notifications.
- **Dynamic Selection**: Efficient driver selection and assignment system.
- **Seamless Communication**: Direct contact options via `url_launcher`.
- **Location Services**: High-precision location tracking with `geolocator`.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Cloud Messaging, Analytics, Crashlytics)
- **Maps & Location**: Google Maps SDK, Geolocator
- **State Management**: Provider
- **Design System**: Material Design with custom premium aesthetics

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Mohammad-Munaam/medfi_app.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**:
   - Add your `google-services.json` for Android.
   - Add your `GoogleService-Info.plist` for iOS.
4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/core`: Essential app-wide services and constants.
- `lib/models`: Data structures and models.
- `lib/providers`: State management logic.
- `lib/screens`: UI screens and page layouts.
- `lib/services`: Integration with external APIs (Firebase, Google, etc.).
- `lib/widgets`: Reusable UI components.

## 📈 Current Status

✅ Phase 1: Core UI & Authentication
✅ Phase 2: Location Services & Google Maps Integration
🔄 Phase 3: Driver Selection & Advanced Notifications (In Progress)

---
*Built with ❤️ for emergency medical assistance.*
