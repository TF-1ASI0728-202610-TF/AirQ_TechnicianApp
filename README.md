# AirQ Technician Mobile App (tecnico_app_airq)

## Description
This is a cross-platform mobile application developed with Flutter. It is designed specifically for Field Technicians to install, configure, and maintain AirQ sensors on client premises.

## Key Features
- **Authentication**: Technicians log in using credentials created by the System Administrator.
- **Sensor Assignment**: Allows technicians to link a physical sensor's ID/MAC address to a specific Client's Campus and Classroom.
- **Diagnostics**: View real-time ping status or recent telemetry data to confirm a successful installation before leaving the site.
- **Ticket Management**: Receive and update maintenance tickets reported by clients (e.g., replacing broken nodes, calibrating sensors).

## Tech Stack
- Flutter Framework (Dart)
- Material Design UI
- HTTP client (for communicating with the Spring Boot Backend REST APIs)

## How to Run Locally
1. Ensure you have the Flutter SDK installed and an Android/iOS emulator running (or a physical device connected).
2. Install the project packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Build for Production
To generate a release APK for Android devices:
```bash
flutter build apk --release
```
To build for iOS (requires a macOS environment with Xcode):
```bash
flutter build ipa
```
