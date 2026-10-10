
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final GetOrderDetailsUsecase _getOrderDetailsUsecase;

  OrderDetailsCubit(this._getOrderDetailsUsecase)
      : super(OrderDetailsInitial());

  static OrderDetailsCubit get(BuildContext context) =>
      BlocProvider.of<OrderDetailsCubit>(context);

  int _requestId = 0;

  // ======= Get Order Details ======= //
  Future<void> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async {
    if (isClosed || state is OrderDetailsLoadingState) {
      return;
    }

    final requestId = ++_requestId;

    emit(OrderDetailsLoadingState());

    final result = await _getOrderDetailsUsecase.call(
      tripId: tripId,
      orderId: orderId,
    );

    if (isClosed || requestId != _requestId) return;

    result.when(
      success: (response) {
        if (!response.success || response.data == null) {
          emit(
            OrderDetailsFailureState(response.message),
          );
          return;
        }

        emit(OrderDetailsSuccessState(response.data!));
      },
      failure: (error) {
        emit(
          OrderDetailsFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );
  }
}
