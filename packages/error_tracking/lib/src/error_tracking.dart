import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Initializes error handling and runs the app inside it.
///
/// Covers two error sources: Flutter framework errors (widget build/layout
/// errors, via [FlutterError.onError]) and uncaught async errors anywhere
/// else in the app (via [runZonedGuarded]).
///
/// This currently only logs to the console in debug mode. Because callers
/// only ever go through [init], the internals can be swapped for a real
/// backend (Sentry, Crashlytics, ...) later without changing any call site.
abstract class ErrorTracking {
  /// Sets up error handling for [environment], then runs [appRunner].
  static Future<void> init({
    required bool debug,
    required String environment,
    required FutureOr<void> Function() appRunner,
  }) async {
    FlutterError.onError = (details) {
      _report(
        debug: debug,
        environment: environment,
        error: details.exceptionAsString(),
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    await runZonedGuarded(
      appRunner,
      (error, stackTrace) => _report(
        debug: debug,
        environment: environment,
        error: error.toString(),
        stackTrace: stackTrace,
      ),
    );
  }

  static void _report({
    required bool debug,
    required String environment,
    required String error,
    StackTrace? stackTrace,
  }) {
    if (!debug) return;
    developer.log(
      error,
      name: 'ErrorTracking ($environment)',
      stackTrace: stackTrace ?? StackTrace.empty,
    );
  }
}
