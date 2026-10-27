clear

flutter clean
flutter pub get


flutter build appbundle -t lib/app/main.dart
flutter build apk --release --target-platform android-arm64 -t lib/app/main.dart

flutter build ipa -t lib/app/main.dart