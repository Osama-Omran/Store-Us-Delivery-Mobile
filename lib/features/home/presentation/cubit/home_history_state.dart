
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';

sealed class HomeHistoryState {}

final class HomeHistoryInitial extends HomeHistoryState {}

final class HomeHistoryLoadingState extends HomeHistoryState {}

final class HomeHistorySuccessState extends HomeHistoryState {
  final List<TripHistoryItem> trips;

  HomeHistorySuccessState(this.trips);
}

final class HomeHistoryFailureState extends HomeHistoryState {
  final String? errorMessage;

  HomeHistoryFailureState(this.errorMessage);
}
