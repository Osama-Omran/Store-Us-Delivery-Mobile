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
  static const String tripOrders = '$trips/{tripId}/orders';
  static const String tripHistory = '$trips/history';

  //======= Orders =======//
  static const String tripOrderDetails = '$trips/{tripId}/orders/{orderId}';

  // ======= Account ======= //
  static const String me = '/me';
  static const String logout = '/logout';

  static const String notifications = '/notifications';
  static const String markNotificationAsRead =
      '$notifications/{notificationId}/read';
  static const String updateOrderDeliveryLocation =
      '/trips/{tripId}/orders/{orderId}/delivery-location';
  static const String confirmDelivery =
      '$trips/{tripId}/orders/{orderId}/confirm-delivery';
  static const String topRank = '/top-rank';
  static const String reportsOverview = '/reports/overview';
  static const String supportContact = '/support/contact';
  static const String supportMessages = '/support/messages';
  static const String warehouseTransfers = '/warehouse-transfers';
  static const String retryCollection =
      '$trips/{tripId}/orders/{orderId}/retry-collection';

  //======= Treasury / Wallet =======//
  static const String tripWallet = '$trips/{tripId}/wallet';

  //======= Customers =======//
  static const String customers = '/customers';

  static const String tripCustomers = '$trips/{tripId}/customers';

  static const String deliveryOutcome =
      '$trips/{tripId}/orders/{orderId}/delivery-outcome';


  static const String deliveryReasons = '/delivery-reasons';

  static const String customerOptions = '$customers/options';

  static const String vehicleStock =
      '$trips/{tripId}/vehicle-stock';


  static const String posOptions =
      '$trips/{tripId}/pos/options';

  static const String submitPos = '$trips/{tripId}/pos';
}
