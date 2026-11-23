import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/printing/storeus_receipt_builder.dart';
import 'package:storeus_delivery/core/printing/usb_esc_pos_printer.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';

/// Reuses the existing Repo -> UseCase -> API chain; no new API is invented.
class OrderReceiptLoader {
  const OrderReceiptLoader._();

  static Future<ReceiptDocument> load({
    required int tripId,
    required int orderId,
  }) async {
    final response = await getIt<GetOrderDetailsUsecase>()(
      tripId: tripId,
      orderId: orderId,
    );
    ReceiptDocument? receipt;
    String? errorMessage;

    response.when(
      success: (result) {
        if (result.success && result.data != null) {
          receipt = StoreusReceiptBuilder.order(result.data!);
        } else {
          errorMessage = result.message;
        }
      },
      failure: (error) {
        errorMessage = error.apiErrorModel.message;
      },
    );

    if (receipt == null) {
      throw StateError(errorMessage ?? 'تعذر تحميل تفاصيل الطلب للطباعة');
    }
    return receipt!;
  }
}
