import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static SharedPreferences? preferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) =>
      _secureStorage.write(key: 'Access Token', value: token);

  static Future<String?> getToken() async =>
      await _secureStorage.read(key: 'Access Token');

  static Future<void> removeToken() async {
    await _secureStorage.delete(key: 'Access Token');
  }
  /////////////////////////////////////////////////////////

  static void saveUserName(String name) =>
      preferences?.setString('User Name', name);

  static String? getUserName() => preferences?.getString('User Name');
  /////////////////////////////////////////////////////////
}
