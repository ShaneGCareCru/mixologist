# Mixologist Flutter App

This folder contains a minimal Flutter front‐end for Mixologist. The goal is to support desktop, tablet and mobile devices from a single code base.

## Features

- Uses Flutter and Dart for cross‑platform UI.
- Placeholder login screen (intended for Firebase authentication).
- Communicates with the existing Flask backend without exposing the OpenAI API key to the client.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and ensure the `flutter` command is available.
2. Run `flutter pub get` inside this folder to fetch dependencies.
3. Launch the app with `flutter run` for your desired platform (mobile, desktop or web).

## Running on Emulators & Devices

To test the Mixologist Flutter app on different platforms, you can use real devices, desktop, or emulators/simulators.

### List Available Devices

```bash
flutter devices
```

### List and Launch Emulators

```bash
flutter emulators
# Launch an emulator by ID:
flutter emulators --launch <emulator id>
```

- For iOS:  
  ```bash
  flutter emulators --launch apple_ios_simulator
  ```
- For Android:  
  ```bash
  flutter emulators --launch Medium_Phone_API_36.0
  ```

### Run the App

```bash
flutter run
```
- Add `-d <device_id>` to target a specific device or emulator.

### Troubleshooting

- If no devices are found, run `flutter doctor` for setup help.
- For more on managing emulators:
  - [Flutter: Set up an editor](https://docs.flutter.dev/get-started/editor)
  - [Android emulators](https://developer.android.com/studio/run/managing-avds)
  - [iOS simulators](https://docs.flutter.dev/platform-integration/ios/launching-devices)

Authentication and backend calls should be implemented using Firebase Authentication and a Cloud Function that interacts with the Python service. The function stores the OpenAI API key securely server‑side and proxies requests from authenticated users.
