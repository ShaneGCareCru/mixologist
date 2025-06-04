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

Authentication and backend calls should be implemented using Firebase Authentication and a Cloud Function that interacts with the Python service. The function stores the OpenAI API key securely server‑side and proxies requests from authenticated users.
