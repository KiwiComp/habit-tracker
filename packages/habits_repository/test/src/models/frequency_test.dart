import 'package:flutter_test/flutter_test.dart';
import 'package:habits_repository/habits_repository.dart';

void main() {
  group('Frequency.fromName', () {
    test('parses every enum value from its name', () {
      for (final frequency in Frequency.values) {
        expect(Frequency.fromName(frequency.name), frequency);
      }
    });

    test('throws for an unrecognized name', () {
      expect(() => Frequency.fromName('yearly'), throwsStateError);
    });
  });
}
