sealed class ConfirmDeliveryState {}

final class ConfirmDeliveryInitial extends ConfirmDeliveryState {}

final class ConfirmDeliveryLoading extends ConfirmDeliveryState {}

final class ConfirmDeliverySuccess extends ConfirmDeliveryState {
  ConfirmDeliverySuccess(this.response);

  final dynamic response;
}

final class ConfirmDeliveryFailure extends ConfirmDeliveryState {
  ConfirmDeliveryFailure(this.message);

  final String message;
}
