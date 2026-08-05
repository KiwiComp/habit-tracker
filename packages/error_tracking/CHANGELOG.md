# Changelog

## 0.2.0

- Add `ErrorTracking.init`, wrapping app startup with `FlutterError.onError` (Flutter framework
  errors) and `runZonedGuarded` (uncaught async errors). Currently logs to the console in debug
  mode only; internals can be swapped for a real backend (Sentry, Crashlytics, ...) without
  changing call sites.
- Add `flutter` as a dependency — this package needs `FlutterError`, so it can no longer be a pure
  Dart package.

## 0.1.0+1

- Initial package scaffolding via `very_good create dart_package error_tracking`.
