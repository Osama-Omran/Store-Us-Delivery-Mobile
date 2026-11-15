import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as session;
import 'package:storeus_delivery/features/drawer_features/account/data/models/change_password_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/update_profile_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/repo/concrete_account_repo.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/change_password_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/get_me_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/logout_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/usecases/update_profile_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_state.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_change_password_dialog.dart';

// Exercise Dio's real JSON and multipart serialization against loopback only.
class _NetworkTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

class _Request {
  _Request(HttpRequest request, this.body)
    : method = request.method,
      path = request.uri.path,
      authorization = request.headers.value('authorization'),
      accept = request.headers.value('accept'),
      contentType = request.headers.contentType;

  final String method;
  final String path;
  final String? authorization;
  final String? accept;
  final ContentType? contentType;
  final String body;
}

void main() {
  _NetworkTestBinding();

  late HttpServer server;
  late Dio dio;
  late AccountCubit cubit;
  late List<_Request> requests;
  late Map<String, dynamic> mutationResponse;
  late int mutationStatus;
  late String userName;
  Completer<void>? mutationGate;
  Completer<void>? mutationStarted;

  const passwordBody = ChangePasswordRequestBody(
    currentPassword: 'OldPassword123!',
    password: 'NewPassword456!',
    passwordConfirmation: 'NewPassword456!',
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({'Access Token': 'test-token'});
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    session.token = 'test-token';
    requests = [];
    mutationResponse = {'success': true};
    mutationStatus = 200;
    userName = 'Original Driver';
    mutationGate = null;
    mutationStarted = null;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = await const Utf8Decoder(allowMalformed: true)
          .bind(request)
          .join();
      requests.add(_Request(request, body));
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/api/mobile/v1/me') {
        request.response.write(
          jsonEncode({
            'success': true,
            'data': {
              'id': 1,
              'name': userName,
              'phone': '01012345678',
              'email': 'driver@example.test',
              'employee_id': 'EMP-1',
              'role': 'driver',
            },
          }),
        );
      } else {
        mutationStarted?.complete();
        await mutationGate?.future;
        request.response.statusCode = mutationStatus;
        request.response.write(jsonEncode(mutationResponse));
      }
      await request.response.close();
    });
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:${server.port}/api/mobile/v1',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    final repo = ConcreteAccountRepo(AuthApiService(dio));
    cubit = AccountCubit(
      GetMeUsecase(repo),
      LogoutUsecase(repo),
      UpdateProfileUsecase(repo),
      ChangePasswordUsecase(repo),
    );
    await cubit.getMe();
    requests.clear();
  });

  tearDown(() async {
    if (mutationGate != null && !mutationGate!.isCompleted) {
      mutationGate!.complete();
    }
    await cubit.close();
    dio.close(force: true);
    await server.close(force: true);
    session.token = null;
  });

  test(
    'profile PATCH sends Arabic names and preserves the phone leading zero',
    () async {
      userName = 'أحمد محمد';
      await cubit.updateProfile(
        const UpdateProfileRequestBody(
          firstName: 'أحمد',
          lastName: 'محمد',
          phone: '01012345678',
        ),
      );

      final request = requests.first;
      expect(request.method, 'PATCH');
      expect(request.path, '/api/mobile/v1/profile');
      expect(request.authorization, 'Bearer test-token');
      expect(request.accept, 'application/json');
      expect(request.contentType?.mimeType, 'application/json');
      expect(jsonDecode(request.body), {
        'first_name': 'أحمد',
        'last_name': 'محمد',
        'phone': '01012345678',
      });
      expect(requests.last.path, '/api/mobile/v1/me');
      expect(cubit.state, isA<AccountProfileUpdateSuccessState>());
      expect(cubit.currentUser?.name, 'أحمد محمد');
      expect(PreferencesHelper.getUserName(), 'أحمد محمد');
    },
  );

  for (final photoOnly in [false, true]) {
    test('profile photo uses multipart POST (photoOnly: $photoOnly)', () async {
      final directory = await Directory.systemTemp.createTemp(
        'storeus-profile-',
      );
      final file = File('${directory.path}/profile.png');
      await file.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aG1cAAAAASUVORK5CYII=',
        ),
      );
      addTearDown(() async {
        await file.delete();
        await directory.delete();
      });

      await cubit.updateProfile(
        UpdateProfileRequestBody(
          firstName: photoOnly ? null : 'أحمد',
          lastName: photoOnly ? null : 'محمد',
          phone: photoOnly ? null : '01012345678',
          photo: file,
        ),
      );

      final request = requests.first;
      expect(request.method, 'POST');
      expect(request.path, '/api/mobile/v1/profile');
      expect(request.authorization, 'Bearer test-token');
      expect(request.accept, 'application/json');
      expect(request.contentType?.mimeType, 'multipart/form-data');
      expect(request.contentType?.parameters['boundary'], isNotEmpty);
      expect(request.body, contains('name="photo"; filename="profile.png"'));
      if (photoOnly) {
        expect(request.body, isNot(contains('name="first_name"')));
      } else {
        expect(request.body, contains('name="first_name"\r\n\r\nأحمد'));
        expect(request.body, contains('name="last_name"\r\n\r\nمحمد'));
        expect(request.body, contains('name="phone"\r\n\r\n01012345678'));
      }
      expect(cubit.state, isA<AccountProfileUpdateSuccessState>());
      expect(requests.last.path, '/api/mobile/v1/me');
    });
  }

  for (final requiresLogin in [null, false, true]) {
    test('password success follows requires_login=$requiresLogin', () async {
      mutationResponse = {
        'success': true,
        if (requiresLogin != null) 'data': {'requires_login': requiresLogin},
      };
      await cubit.changePassword(passwordBody);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/api/mobile/v1/profile/password');
      expect(request.authorization, 'Bearer test-token');
      expect(request.accept, 'application/json');
      expect(request.contentType?.mimeType, 'application/json');
      expect(jsonDecode(request.body), {
        'current_password': 'OldPassword123!',
        'password': 'NewPassword456!',
        'password_confirmation': 'NewPassword456!',
      });
      if (requiresLogin == true) {
        expect(cubit.state, isA<AccountLoggedOutState>());
        expect(await PreferencesHelper.getToken(), isNull);
        expect(session.token, isNull);
      } else {
        expect(cubit.state, isA<AccountPasswordChangeSuccessState>());
        expect(cubit.currentUser?.name, 'Original Driver');
        expect(await PreferencesHelper.getToken(), 'test-token');
        expect(session.token, 'test-token');
      }
    });
  }

  for (final status in [200, 422]) {
    test(
      'password rejection preserves the session and server message ($status)',
      () async {
        mutationStatus = status;
        mutationResponse = {
          'success': false,
          'message': 'كلمة المرور الحالية غير صحيحة',
        };
        await cubit.changePassword(passwordBody);

        expect(cubit.state, isA<AccountPasswordChangeFailureState>());
        expect(
          (cubit.state as AccountPasswordChangeFailureState).errorMessage,
          'كلمة المرور الحالية غير صحيحة',
        );
        expect(await PreferencesHelper.getToken(), 'test-token');
        expect(cubit.currentUser?.name, 'Original Driver');
        expect(requests, hasLength(1));
      },
    );
  }

  test(
    'profile server error keeps the current account and skips refresh',
    () async {
      mutationStatus = 500;
      await cubit.updateProfile(
        const UpdateProfileRequestBody(phone: '01012345678'),
      );
      expect(cubit.state, isA<AccountProfileUpdateFailureState>());
      expect(cubit.currentUser?.name, 'Original Driver');
      expect(requests, hasLength(1));
    },
  );

  test('duplicate profile submission sends only one mutation', () async {
    mutationGate = Completer<void>();
    mutationStarted = Completer<void>();
    const body = UpdateProfileRequestBody(phone: '01012345678');
    final first = cubit.updateProfile(body);
    await mutationStarted!.future;
    await cubit.updateProfile(body);
    mutationGate!.complete();
    await first;
    expect(
      requests.where((request) => request.path.endsWith('/profile')),
      hasLength(1),
    );
  });

  for (final success in [true, false]) {
    testWidgets('password dialog closes only on success ($success)', (
      tester,
    ) async {
      mutationStatus = success ? 200 : 422;
      mutationResponse = {'success': success, 'message': 'Password rejected'};
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const AccountChangePasswordDialog(),
                  ),
                ),
                child: const Text('Open password'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open password'));
      await tester.pumpAndSettle();
      await tester.runAsync(() => cubit.changePassword(passwordBody));
      await tester.pumpAndSettle();
      expect(
        find.byType(AccountChangePasswordDialog),
        success ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
