import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:error_tracking/error_tracking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:habit_tracker/app/app_bloc_observer.dart';

Future<void> bootstrap({
  required String environment,
  required FutureOr<Widget> Function() builder,
}) {
  return ErrorTracking.init(
    debug: kDebugMode,
    environment: environment,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = const AppBlocObserver();

      // Add cross-flavor configuration here

      runApp(await builder());
    },
  );
}
