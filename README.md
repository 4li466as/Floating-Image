# Floating Image 🖼️

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg?logo=android)](https://www.android.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Floating Image** is a lightweight, local-only Android utility that allows you to take any image (PNG, JPG, WEBP, or animated GIF) from your device and display it as a draggable, floating system-level overlay that stays visible above all other applications. 

## ✨ Features

- **Genuine System Overlay:** Uses Android's native `WindowManager` (`TYPE_APPLICATION_OVERLAY`) to float perfectly above the Home screen, Chrome, games, and other apps.
- **Universal Image Support:** Supports standard image formats (PNG, JPG, WEBP) and completely preserves **Animated GIFs** and transparent pixels without adding artificial backgrounds.
- **Privacy First (100% Offline):** Requires zero internet permissions. The application strictly reads the local file you select and never uploads, edits, or analyzes your images.
- **Smart Boundaries:** Includes an optional screen-lock toggle to prevent dragging the image off-screen.
- **Dynamic Sizing:** Instantly resize the floating overlay on the fly (XS: 32dp, S: 64dp, M: 96dp, L: 128dp, XL: 160dp).
- **Persistent State:** Remembers your exact X/Y dragging position, selected size, and last chosen image even after you close the app.
- **Modern Glassmorphic UI:** Features a beautifully designed, dark-themed Flutter settings interface with subtle animations and glow effects.

## 🚀 Getting Started

### Prerequisites
- Android 9.0+ (API 28+) recommended for optimal GIF and overlay stability.
- Flutter SDK installed on your machine (for building from source).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/4li466as/Floating-Image.git
   ```
2. **Navigate to the project:**
   ```bash
   cd Floating-Image
   ```
3. **Get dependencies:**
   ```bash
   flutter pub get
   ```
4. **Build the release APK:**
   ```bash
   flutter build apk --release
   ```
5. **Install on your Android device:**
   ```bash
   flutter install
   ```

## ⚙️ How It Works

This application utilizes a dual-architecture design:
- **Flutter** powers the sleek, modern Settings interface and handles the local file selection using `image_picker`.
- **Native Kotlin** runs an Android Foreground Service equipped with `ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE` to satisfy strict modern Android 14+ background execution limits. It physically inflates the image view using Android's native `WindowManager` and handles touch/drag calculation events entirely at the OS level.

## 📝 Usage Note
*This application operates strictly as an image viewer. It does not perform AI background removal or image editing. To utilize a transparent floating overlay, please ensure your image already has a transparent background (e.g., a transparent PNG) before uploading it into the app.*

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
