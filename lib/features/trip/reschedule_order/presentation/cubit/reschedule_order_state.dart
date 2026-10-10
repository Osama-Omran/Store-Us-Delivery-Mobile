
sealed class RescheduleOrderState {}

final class RescheduleOrderInitial extends RescheduleOrderState {}

final class RescheduleOrderLoading extends RescheduleOrderState {}

final class RescheduleOrderSuccess extends RescheduleOrderState {}

final class RescheduleOrderFailure extends RescheduleOrderState {
  RescheduleOrderFailure(this.message);

  final String message;
}
