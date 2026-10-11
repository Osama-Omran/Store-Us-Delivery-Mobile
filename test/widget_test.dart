import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/app/app_builder.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/localization/gen_l10n/app_localizations.dart';
import 'package:storeus_delivery/core/helpers/localization/locale_cubit.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/routing/app_router.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';
import 'package:storeus_delivery/features/login/domain/usecases/login_usecase.dart';
import 'package:storeus_delivery/features/login/presentation/cubit/login_cubit.dart';
import 'package:storeus_delivery/features/login/presentation/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'app opens the Arabic login and validates without an API request',
    (tester) async {
      await getIt.reset();
      addTearDown(() => getIt.reset());
      SharedPreferences.setMockInitialValues({'locale': 'ar'});
      PackageInfo.setMockInitialValues(
        appName: 'Store Us Delivery',
        packageName: 'storeus_delivery',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'test',
      );

      final usecase = _UnexpectedLoginUsecase();
      late LoginCubit login;
      getIt.registerFactory<LocaleCubit>(() => LocaleCubit());
      getIt.registerFactory<LoginCubit>(() => login = LoginCubit(usecase));
      AppRouter.routes.go(RoutesNames.login);

      await tester.pumpWidget(const AppBuilder());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      final strings = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)),
      )!;
      expect(find.text(strings.email), findsOneWidget);
      expect(find.text('StoreUs Delivery v1.0.0'), findsOneWidget);

      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      expect(find.text(strings.email_is_required), findsOneWidget);
      expect(find.text(strings.password_is_required), findsOneWidget);
      expect(usecase.calls, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(login.isClosed, isTrue);
    },
  );

  test('closing login releases its form controllers', () async {
    final login = LoginCubit(_UnexpectedLoginUsecase());
    final email = login.emailController;
    final password = login.passwordController;

    await login.close();

    expect(login.isClosed, isTrue);
    expect(() => email.addListener(() {}), throwsFlutterError);
    expect(() => password.addListener(() {}), throwsFlutterError);
  });
}

class _UnexpectedLoginUsecase implements LoginUsecase {
  int calls = 0;

  @override
  Future<ApiResult<LoginResponse>> call({required LoginRequestBody body}) {
    calls++;
    throw StateError('Invalid form submission must not call the login API');
  }
}
