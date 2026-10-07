import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static SharedPreferences? preferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static bool onboardingViewed() =>
      preferences?.getBool('Onboarding Viewed') ?? false;

  static Future<bool>? setOnboardingAsViewed() =>
      preferences?.setBool('Onboarding Viewed', true);
  /////////////////////////////////////////////////////////

  static Future<void> saveToken(String token) =>
      _secureStorage.write(key: 'Access Token', value: token);

  static Future<String?> getToken() async =>
      await _secureStorage.read(key: 'Access Token');

  static Future<void> removeToken() async {
    await _secureStorage.delete(key: 'Access Token');
  }
  /////////////////////////////////////////////////////////

  static const _biometricKey = 'biometric_enabled';

  static Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }
  /////////////////////////////////////////////////////////

  static void saveUserName(String name) =>
      preferences?.setString('User Name', name);

  static String? getUserName() => preferences?.getString('User Name');
  /////////////////////////////////////////////////////////

  static void saveUserImage(String? image) =>
      preferences?.setString('User Image', image ?? '');

  static String? getUserImage() => preferences?.getString('User Image');
  /////////////////////////////////////////////////////////

  static void saveJoinDate(String joinDate) =>
      preferences?.setString('Join Date', joinDate);

  static String? getJoinDate() => preferences?.getString('Join Date');
  /////////////////////////////////////////////////////////

  static void saveCurrentBalance(double balance) =>
      preferences?.setDouble('Current Balance', balance);

  static double getCurrentBalance() =>
      preferences?.getDouble('Current Balance') ?? 0;
  /////////////////////////////////////////////////////////

  static void saveUserLevel(String? level) =>
      preferences?.setString('User Level', level ?? '');

  static String? getUserLevel() => preferences?.getString('User Level');
  /////////////////////////////////////////////////////////

  static void saveUserMemberShipNumber(String? name) =>
      preferences?.setString('User Membership Name', name ?? '');

  static String? getUserMemberShipNumber() =>
      preferences?.getString('User Membership Name');
  /////////////////////////////////////////////////////////

  static void saveUserJoiningDate(String? date) =>
      preferences?.setString('User Joining Date', date ?? '');

  static String? getUserJoiningDate() =>
      preferences?.getString('User Joining Date');
  /////////////////////////////////////////////////////////

  static void saveUserWalletBalance(String? balance) =>
      preferences?.setString('User Wallet Balance', balance ?? '');

  static String? getUserWalletBalance() =>
      preferences?.getString('User Wallet Balance');
  /////////////////////////////////////////////////////////

  static void saveUserPhoneNumber(String? phone) =>
      preferences?.setString('User Phone Number', phone ?? '');

  static String? getUserPhoneNumber() =>
      preferences?.getString('User Phone Number');
  /////////////////////////////////////////////////////////

  static void saveUserCompletedTrips(int? trips) =>
      preferences?.setInt('User Completed Trips', trips ?? 0);

  static int? getUserCompletedTrips() =>
      preferences?.getInt('User Completed Trips');
  /////////////////////////////////////////////////////////

  static void saveUserEmail(String? email) =>
      preferences?.setString('User Email', email ?? '');

  static String? getUserEmail() => preferences?.getString('User Email');
  /////////////////////////////////////////////////////////

  static void saveFCMToken(String fcmToken) =>
      preferences?.setString('FCM Token', fcmToken);

  static String? getFCMToken() => preferences?.getString('FCM Token');
  /////////////////////////////////////////////////////////

  static void setFCMTokenAsSent(bool value) =>
      preferences?.setBool('Is FCM Token Sent', value);

  static bool fcmTokenSent() =>
      preferences?.getBool('Is FCM Token Sent') ?? false;
  /////////////////////////////////////////////////////////

  static Future<void> clearToLogout() async {
    await removeToken();
    await setBiometricEnabled(false);
    await preferences?.remove('User Phone Number');
    await preferences?.remove('User Email');
    setFCMTokenAsSent(false);
  }
}
