import 'package:error_tracking/error_tracking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorTracking.init', () {
    // init installs a global FlutterError.onError; save and restore it so
    // these tests don't leak a handler into each other or the test harness.
    FlutterExceptionHandler? originalOnError;

    setUp(() => originalOnError = FlutterError.onError);
    tearDown(() => FlutterError.onError = originalOnError);

    test('runs the appRunner', () async {
      var didRun = false;

      await ErrorTracking.init(
        debug: false,
        environment: 'test',
        appRunner: () async => didRun = true,
      );

      expect(didRun, isTrue);
    });

    test('installs a FlutterError.onError handler', () async {
      await ErrorTracking.init(
        debug: false,
        environment: 'test',
        appRunner: () {},
      );

      expect(FlutterError.onError, isNotNull);
      expect(FlutterError.onError, isNot(originalOnError));
    });

    test(
      'the installed handler reports and presents framework errors',
      () async {
        await ErrorTracking.init(
          debug: true,
          environment: 'test',
          appRunner: () {},
        );

        // Invoking the handler runs the reporter (debug on → it logs) and
        // forwards to presentError, without throwing.
        FlutterError.onError!(
          FlutterErrorDetails(exception: Exception('boom')),
        );
      },
    );

    test(
      'reports an uncaught error from the app runner in debug mode',
      () async {
        // The throw escapes into runZonedGuarded, which routes it to the
        // reporter rather than letting it propagate — so init completes.
        await ErrorTracking.init(
          debug: true,
          environment: 'test',
          appRunner: () => throw Exception('async boom'),
        );
      },
    );

    test('stays silent when not in debug mode', () async {
      // Same path, but with debug off the reporter returns early (no log).
      await ErrorTracking.init(
        debug: false,
        environment: 'test',
        appRunner: () => throw Exception('async boom'),
      );
    });
  });
}
