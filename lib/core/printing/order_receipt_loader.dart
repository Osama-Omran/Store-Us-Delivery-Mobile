import 'package:storeus_delivery/core/printing/storeus_receipt_builder.dart';
import 'package:storeus_delivery/core/printing/usb_esc_pos_printer.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';

/// Reuses the existing Repo -> UseCase -> API chain; no new API is invented.
class OrderReceiptLoader {
  const OrderReceiptLoader._();

  static Future<ReceiptDocument> load({
    required int tripId,
    required int orderId,
  }) async {
    // Refresh the financial summary using the same endpoint as the cards.
    final ordersResponse = await getIt<GetTripOrdersUsecase>()(tripId: tripId);
    TripOrderModel? summary;
    String? summaryError;
    ordersResponse.when(
      success: (result) {
        if (!result.success) {
          summaryError = result.message;
          return;
        }
        for (final item in result.data) {
          if (item.id == orderId) {
            summary = TripOrderModel.fromApi(item);
            break;
          }
        }
      },
      failure: (error) {
        summaryError = error.apiErrorModel.message;
      },
    );
    final orderSummary = summary;
    if (orderSummary == null) {
      throw StateError(summaryError ?? 'تعذر تحميل قيمة الطلب والتحصيل للطباعة');
    }
    if (!orderSummary.isHandled) {
      throw StateError('لم يتم اتخاذ إجراء على الطلب بعد');
    }

    final response = await getIt<GetOrderDetailsUsecase>()(
      tripId: tripId,
      orderId: orderId,
    );
    ReceiptDocument? receipt;
    String? errorMessage;

    response.when(
      success: (result) {
        if (result.success && result.data != null) {
          receipt = StoreusReceiptBuilder.order(
            result.data!,
            summary: orderSummary,
          );
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
