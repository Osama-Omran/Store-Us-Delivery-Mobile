clear

flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks .dart_tool build

flutter pub get

cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter build ipa -t lib/app/main.dart
