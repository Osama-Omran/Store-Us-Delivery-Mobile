import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/dio_factory.dart';
import 'package:storeus_delivery/core/helpers/apis/environment_config.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/localization/locale_cubit.dart';
import 'package:storeus_delivery/core/helpers/utils/force_update_services.dart';
import 'package:storeus_delivery/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:storeus_delivery/features/login/data/repo/concrete_login_repo.dart';
import 'package:storeus_delivery/features/login/domain/repo/login_repo_interface.dart';
import 'package:storeus_delivery/features/login/domain/usecases/login_usecase.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Dio
  getIt.registerSingletonAsync<Dio>(() => DioFactory.getDio());

  // Api Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  );

  // getIt.registerLazySingleton<LayoutApiService>(
  //   () => LayoutApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<HomeApiService>(
  //   () => HomeApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<VendorsApiService>(
  //   () => VendorsApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<ProductsApiService>(
  //   () => ProductsApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<CartApiService>(
  //   () => CartApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<AddressApiService>(
  //   () => AddressApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<CheckoutApiService>(
  //   () => CheckoutApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );
  //
  // getIt.registerLazySingleton<OrdersApiService>(
  //   () => OrdersApiService(getIt<Dio>(), baseUrl: EnvironmentConfig.baseUrl),
  // );

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
}
