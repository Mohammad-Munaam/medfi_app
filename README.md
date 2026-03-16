# 🏥 MEDFI

### Medical Emergency & Healthcare Assistance App

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-Language-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-MIT-success)

</p>

MEDFI is a **Flutter-based medical assistance mobile application** designed to provide **quick access to healthcare support during emergency situations**.

The application helps users **share their live location, find nearby hospitals, and quickly access emergency services**. MEDFI aims to reduce response time during medical emergencies and improve accessibility to healthcare resources.

---

# 🚀 Demo

| Home Screen        | Location Tracking  | Emergency Feature  |
| ------------------ | ------------------ | ------------------ |
| *(Add screenshot)* | *(Add screenshot)* | *(Add screenshot)* |

> 📌 Add screenshots later inside a `screenshots/` folder.

Example:

```
screenshots/home.png
screenshots/maps.png
screenshots/emergency.png
```

---

# ✨ Features

### 🚨 Emergency Assistance

Quickly access emergency medical support with minimal user interaction.

### 📍 Live Location Tracking

Real-time user location tracking using **Google Maps API**.

### 🏥 Nearby Medical Facilities

Locate nearby hospitals, pharmacies, and healthcare centers.

### 📱 User-Friendly Interface

Simple and intuitive UI for faster navigation during emergency situations.

### 🔒 Secure Data Handling

Ensures that sensitive information is handled securely.

---

# 🛠 Tech Stack

| Technology          | Usage                             |
| ------------------- | --------------------------------- |
| **Flutter**         | Cross-platform mobile development |
| **Dart**            | Programming language              |
| **Firebase**        | Backend services                  |
| **Cloud Firestore** | Database                          |
| **Google Maps API** | Location tracking                 |
| **GitHub**          | Version control                   |

---

# 🏗 Architecture

MEDFI follows a **modular Flutter architecture** to maintain clean code and scalability.

```
Presentation Layer
│
├── Screens
├── Widgets
│
Business Logic Layer
│
├── Services
├── Controllers
│
Data Layer
│
├── Firebase
├── Models
```

This architecture ensures:

* Better maintainability
* Improved scalability
* Easier testing and debugging

---

# 📂 Project Structure

```
medfi_app
│
├── android
├── ios
├── lib
│   ├── models
│   ├── screens
│   ├── services
│   ├── widgets
│   ├── utils
│   └── main.dart
│
├── assets
├── screenshots
├── pubspec.yaml
└── README.md
```

---

# ⚙️ Installation

### 1️⃣ Clone the repository

```
git clone https://github.com/yourusername/medfi_app.git
```

### 2️⃣ Navigate to project folder

```
cd medfi_app
```

### 3️⃣ Install dependencies

```
flutter pub get
```

### 4️⃣ Run the application

```
flutter run
```

---

# 🔑 Configuration

## Google Maps API Setup

1. Open **Google Cloud Console**
2. Enable:

   * Maps SDK for Android
   * Maps SDK for iOS
3. Generate an **API Key**

Add it inside:

```
android/app/src/main/AndroidManifest.xml
```

```
<meta-data
android:name="com.google.android.geo.API_KEY"
android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

---

# 📦 Build APK

```
flutter build apk --release
```

APK will be available in:

```
build/app/outputs/flutter-apk/
```

---

# 📈 Roadmap

Future improvements planned for MEDFI:

* ✅ Emergency contact alert system
* ✅ Ambulance service integration
* ⏳ AI health assistant
* ⏳ Hospital bed availability tracking
* ⏳ Medical record storage
* ⏳ Real-time ambulance tracking

---

# 🤝 Contributing

Contributions are welcome.

### Steps

1 Fork the repository

2 Create a feature branch

```
git checkout -b feature/your-feature
```

3 Commit your changes

```
git commit -m "Add new feature."
```

4 Push to GitHub

```
git push origin feature/your-feature
```

5 Open a Pull Request

---

# 🧪 Testing

Run tests using:

```
flutter test
```

---

# 📄 License

This project is licensed under the **MIT License**.

---

# 👨‍💻 Author

**Mohammad Munaam**

Flutter Developer

GitHub:
(https://github.com/Mohammad-Munaam?tab=projects)

LinkedIn:
(https://www.linkedin.com/in/mohammad-munaam-8575b7230/)

---

# ⭐ Support

If you like this project, please **give it a star ⭐ on GitHub**.
It helps the project grow and motivates further development.
