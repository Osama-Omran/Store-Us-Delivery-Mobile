import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/dio_factory.dart';
import 'package:storeus_delivery/core/helpers/apis/environment_config.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/localization/locale_cubit.dart';
import 'package:storeus_delivery/core/helpers/utils/force_update_services.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/presentation/cubit/top_rank_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/presentation/cubit/treasury_cubit.dart';
import 'package:storeus_delivery/features/login/data/repo/concrete_login_repo.dart';
import 'package:storeus_delivery/features/login/domain/repo/login_repo_interface.dart';
import 'package:storeus_delivery/features/login/domain/usecases/login_usecase.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/update_delivery_location_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/repo/concrete_receive_trip_repo.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/accept_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/current_trip_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/usecases/loaded_items_usecase.dart';
import 'package:storeus_delivery/features/trip/receive_trip/presentation/cubit/receive_trip_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/repo/concrete_account_repo.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/trip/trip_tap/presentation/cubit/trip_tab_cubit.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/repo/concrete_trip_orders_repo.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/repo/trip_orders_repo_interface.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/usecases/get_trip_orders_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_cubit.dart';

import 'package:storeus_delivery/features/trip/reschedule_order/data/repo/concrete_reschedule_order_repo.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/repo/reschedule_order_repo_interface.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/usecases/reschedule_order_usecase.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/presentation/cubit/reschedule_order_cubit.dart';

import 'package:storeus_delivery/features/trip/order_details/data/repo/concrete_order_details_repo.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/usecases/get_order_details_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/presentation/cubit/order_details_cubit.dart';

import 'package:storeus_delivery/features/trip/cancel_delivery/data/repo/concrete_cancel_delivery_repo.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/repo/cancel_delivery_repo_interface.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/usecases/cancel_delivery_usecase.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/presentation/cubit/cancel_delivery_cubit.dart';

import 'package:storeus_delivery/core/helpers/apis/services/notifications_api_service.dart';

import 'package:storeus_delivery/features/notifications/data/repo/concrete_notifications_repo.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

import 'package:storeus_delivery/features/home/data/repo/concrete_trip_history_repo.dart';
import 'package:storeus_delivery/features/home/domain/repo/trip_history_repo_interface.dart';
import 'package:storeus_delivery/features/home/domain/usecases/get_trip_history_usecase.dart';
import 'package:storeus_delivery/features/home/presentation/cubit/home_history_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Dio
  getIt.registerSingletonAsync<Dio>(() => DioFactory.getDio());

  // Api Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  );

  // ======= Other ======= //
  getIt.registerLazySingleton<ForceUpdateServices>(() => ForceUpdateServices());

  // ======= Repositories ======= //
  getIt.registerLazySingleton<LoginRepoInterface>(
    () => ConcreteLoginRepo(getIt<AuthApiService>()),
  );

  // ======= UseCases ======= //
  getIt.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(getIt<LoginRepoInterface>()),
  );

  // ======= Cubits ======= //
  getIt.registerFactory<LocaleCubit>(() => LocaleCubit());
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<LoginUsecase>()));
  getIt.registerFactory<LayoutCubit>(() => LayoutCubit());
  getIt.registerFactory<TopRankCubit>(() => TopRankCubit());
  getIt.registerFactory<TreasuryCubit>(() => TreasuryCubit());

  getIt.registerLazySingleton<TripApiService>(
    () => TripApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ReceiveTripRepoInterface>(
    () => ConcreteReceiveTripRepo(getIt<TripApiService>()),
  );

  getIt.registerLazySingleton<CurrentTripUsecase>(
    () => CurrentTripUsecase(getIt<ReceiveTripRepoInterface>()),
  );

  getIt.registerFactory<ReceiveTripCubit>(
    () => ReceiveTripCubit(
      getIt<CurrentTripUsecase>(),
      getIt<LoadedItemsUsecase>(),
      getIt<AcceptTripUsecase>(),
    ),
  );

  getIt.registerLazySingleton<LoadedItemsUsecase>(
    () => LoadedItemsUsecase(getIt<ReceiveTripRepoInterface>()),
  );

  getIt.registerLazySingleton<AcceptTripUsecase>(
    () => AcceptTripUsecase(getIt<ReceiveTripRepoInterface>()),
  );

  // ======= Account Repository ======= //
  getIt.registerLazySingleton<AccountRepoInterface>(
    () => ConcreteAccountRepo(getIt<AuthApiService>()),
  );

  // ======= Account Usecases ======= //
  getIt.registerLazySingleton<GetMeUsecase>(
    () => GetMeUsecase(getIt<AccountRepoInterface>()),
  );

  getIt.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(getIt<AccountRepoInterface>()),
  );

  // ======= Account Cubit ======= //
  getIt.registerFactory<AccountCubit>(
    () => AccountCubit(getIt<GetMeUsecase>(), getIt<LogoutUsecase>()),
  );

  getIt.registerFactory<TripTabCubit>(
    () => TripTabCubit(
      getIt<CurrentTripUsecase>(),
      getIt<GetTripOrdersUsecase>(),
    ),
  );

  // ======= Trip Orders Repository ======= //
  getIt.registerLazySingleton<TripOrdersRepoInterface>(
    () => ConcreteTripOrdersRepo(getIt<TripApiService>()),
  );

  // ======= Trip Orders Usecase ======= //
  getIt.registerLazySingleton<GetTripOrdersUsecase>(
    () => GetTripOrdersUsecase(getIt<TripOrdersRepoInterface>()),
  );

  // ======= Home Cubit ======= //
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt<CurrentTripUsecase>(), getIt<GetTripOrdersUsecase>()),
  );

  // ======= Trip History Repository ======= //
  getIt.registerLazySingleton<TripHistoryRepoInterface>(
    () => ConcreteTripHistoryRepo(getIt<TripApiService>()),
  );

  // ======= Trip History Usecase ======= //
  getIt.registerLazySingleton<GetTripHistoryUsecase>(
    () => GetTripHistoryUsecase(getIt<TripHistoryRepoInterface>()),
  );

  // ======= Home History Cubit ======= //
  getIt.registerFactory<HomeHistoryCubit>(
    () => HomeHistoryCubit(getIt<GetTripHistoryUsecase>()),
  );

  // ======= Order Details Repository ======= //
  getIt.registerLazySingleton<OrderDetailsRepoInterface>(
    () => ConcreteOrderDetailsRepo(getIt<TripApiService>()),
  );

  // ======= Order Details Usecase ======= //
  getIt.registerLazySingleton<GetOrderDetailsUsecase>(
    () => GetOrderDetailsUsecase(getIt<OrderDetailsRepoInterface>()),
  );

  // ======= Order Details Cubit ======= //

  getIt.registerFactory<OrderDetailsCubit>(
    () => OrderDetailsCubit(
      getIt<GetOrderDetailsUsecase>(),
      getIt<GetTripOrdersUsecase>(),
      getIt<UpdateOrderDeliveryLocationUsecase>(),
    ),
  );

  // ======= Notifications API Service ======= //
  getIt.registerLazySingleton<NotificationsApiService>(
    () => NotificationsApiService(
      getIt<Dio>(),
      baseUrl: EnvironmentConfig.baseUrl,
    ),
  );

  // ======= Notifications Repository ======= //
  getIt.registerLazySingleton<NotificationsRepoInterface>(
    () => ConcreteNotificationsRepo(getIt<NotificationsApiService>()),
  );

  // ======= Notifications Usecases ======= //
  getIt.registerLazySingleton<GetNotificationsUsecase>(
    () => GetNotificationsUsecase(getIt<NotificationsRepoInterface>()),
  );

  getIt.registerLazySingleton<MarkNotificationAsReadUsecase>(
    () => MarkNotificationAsReadUsecase(getIt<NotificationsRepoInterface>()),
  );

  // ======= Notifications Cubit ======= //
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getIt<GetNotificationsUsecase>(),
      getIt<MarkNotificationAsReadUsecase>(),
    ),
  );

  getIt.registerLazySingleton<UpdateOrderDeliveryLocationUsecase>(
        () => UpdateOrderDeliveryLocationUsecase(
      getIt<OrderDetailsRepoInterface>(),
    ),
  );


// ======= Reschedule Order Repository ======= //
  getIt.registerLazySingleton<RescheduleOrderRepoInterface>(
        () => ConcreteRescheduleOrderRepo(
      getIt<TripApiService>(),
    ),
  );

// ======= Reschedule Order Usecase ======= //
  getIt.registerLazySingleton<RescheduleOrderUsecase>(
        () => RescheduleOrderUsecase(
      getIt<RescheduleOrderRepoInterface>(),
    ),
  );

// ======= Reschedule Order Cubit ======= //
  getIt.registerFactory<RescheduleOrderCubit>(
        () => RescheduleOrderCubit(
      getIt<RescheduleOrderUsecase>(),
    ),
  );


// ======= Cancel Delivery Repository ======= //
  getIt.registerLazySingleton<CancelDeliveryRepoInterface>(
        () => ConcreteCancelDeliveryRepo(
      getIt<TripApiService>(),
    ),
  );

// ======= Cancel Delivery Usecase ======= //
  getIt.registerLazySingleton<CancelDeliveryUsecase>(
        () => CancelDeliveryUsecase(
      getIt<CancelDeliveryRepoInterface>(),
    ),
  );

// ======= Cancel Delivery Cubit ======= //
  getIt.registerFactory<CancelDeliveryCubit>(
        () => CancelDeliveryCubit(
      getIt<CancelDeliveryUsecase>(),
    ),
  );

}
