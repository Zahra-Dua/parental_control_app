# parental_control_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# SafeNest

This project now includes Module 4: Location Tracking & Safety Alerts.

Setup quick notes:
- Add your Google Maps key in `android/app/src/main/AndroidManifest.xml` (`com.google.android.geo.API_KEY`). For iOS, add to AppDelegate/Info.plist accordingly.
- Ensure Firestore structure under `users/{parentId}/children/{childId}` with `lastLocation`, `geofences`, `zoneEvents`.
- Review `lib/README_FIRESTORE_RULES.txt` for rules outline.
- Required packages: see `pubspec.yaml`.
