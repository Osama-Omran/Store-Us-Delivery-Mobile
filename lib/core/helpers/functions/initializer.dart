import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/bloc_observer.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/helpers/utils/remote_config_services.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';

class Initializer {
  static Future<void> initializeServices() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await PreferencesHelper.init();

    setupLocator();
    await getIt.allReady();
    await RemoteConfigServices.init();

    if (kDebugMode) Bloc.observer = MyBlocObserver();
  }
}
