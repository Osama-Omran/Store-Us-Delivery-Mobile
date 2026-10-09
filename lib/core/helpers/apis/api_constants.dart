import 'package:storeus_delivery/core/helpers/apis/environment_config.dart';

class ApiConstants {
  //======= Base URLs =======//
  static String get baseUrl => EnvironmentConfig.baseUrl;

  //======= Authentication =======//
  static const String login = '/login';

  //======= Home =======//
  // static const String bootstrap = '/bootstrap/home';
  // static const String menu = '/catalog/menu';
  // static const String homeCategories = '$vendors/supported-categories';
  // static const String subcategories = '$menu/subcategories';
  // static const String promotions = '/promotions-products';
  // static const String addresses = '$identity/addresses';
  // static const String address = '$identity/address';
  // static const String defaultAddress = '$address/default';
  // static const String storeUsVendor = '$vendors/storeus/resolve';

  //======= Trip =======//
  static const String trips = '/trips';
  static const String currentTrip = '$trips/current';
  static const String loadedItems = '$trips/{tripId}/loaded-items';
  static const String acceptTrip = '$trips/{tripId}/accept';
}
