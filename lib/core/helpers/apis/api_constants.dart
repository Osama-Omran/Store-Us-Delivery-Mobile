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

  //======= Wholesalers =======//
  // static const String vendors = '/vendors';
  // static const String products = '/search/products';
  // static const String productDetails = '$products/{product_id}/details';
  // static const String vendorProductDetails =
  //     '/search/vendor-products/{vendor_product_id}/details';

  //======= Carts =======//
  // static const String carts = '/cart/active';
  // static const String addToCart = '/cart/items';
  // static const String activeCart = '/cart/active-cart-total';
  // static const String cartDetails = '/cart';
  // static const String coupon = '/coupon';
  // static const String deleteAllCarts = '$carts/delete';

  //======= Checkout =======//
  // static const String checkoutSummary = '/checkout/summary';
  // static const String placeOrder = '/orders/place';
}
