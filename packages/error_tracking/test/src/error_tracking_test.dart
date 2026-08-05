import 'package:error_tracking/error_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorTracking.init', () {
    test('runs appRunner', () async {
      var didRun = false;

      await ErrorTracking.init(
        debug: false,
        environment: 'test',
        appRunner: () async {
          didRun = true;
        },
      );

      expect(didRun, isTrue);
    });
  });
}
