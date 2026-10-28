import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/usecases/get_delivery_reasons_usecase.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

class DeliveryReasonsCubit extends Cubit<DeliveryReasonsState> {
  DeliveryReasonsCubit(this._usecase) : super(const DeliveryReasonsInitial());

  final GetDeliveryReasonsUsecase _usecase;

  Future<void> loadReasons() async {
    if (isClosed || state is DeliveryReasonsLoading ||
        state is DeliveryReasonsSuccess) {
      return;
    }
    emit(const DeliveryReasonsLoading());
    try {
      final ApiResult<DeliveryReasonsData> result = await _usecase.call();
      if (isClosed) return;
      result.when(
        success: (data) => emit(DeliveryReasonsSuccess(data)),
        failure: (error) => emit(DeliveryReasonsFailure(
          error.apiErrorModel.message,
        )),
      );
    } catch (_) {
      if (!isClosed) {
        emit(const DeliveryReasonsFailure('delivery_reasons_load_failed'));
      }
    }
  }
}
