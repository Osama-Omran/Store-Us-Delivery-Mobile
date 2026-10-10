
sealed class CancelDeliveryState {}

final class CancelDeliveryInitial extends CancelDeliveryState {}

final class CancelDeliveryLoading extends CancelDeliveryState {}

final class CancelDeliverySuccess extends CancelDeliveryState {}

final class CancelDeliveryFailure extends CancelDeliveryState {
  CancelDeliveryFailure(this.message);

  final String message;
}
