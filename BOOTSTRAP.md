# bootstrap.dart — how to wire in error_tracking

This file assumes: a Very Good CLI-generated Flutter app (`lib/bootstrap.dart` plus
`lib/main_development.dart` / `lib/main_staging.dart` / `lib/main_production.dart`), and the
`error_tracking` package already built per `ERROR_TRACKING.md` and registered as a dependency in
the app's `pubspec.yaml` (see `CREATE_PACKAGE.md` step 5 for how to register a package — the app
itself needs the same `path:` dependency treatment as any other workspace member depending on it).

## Starting point

The default Very Good CLI scaffold looks like this:

```dart
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(await builder());
}
```

and each `main_FLAVOR.dart`:
```dart
import 'package:APP_NAME/app/app.dart';
import 'package:APP_NAME/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
```

## Target end state

Three changes, all driven by `error_tracking` now existing:

1. **Wrap everything in `ErrorTracking.init`.** It sets `FlutterError.onError` internally, so the
   scaffold's manual assignment must be removed — keeping both would mean one silently overwrites
   the other. This also adds the `runZonedGuarded` async-error coverage the scaffold never had.
2. **Move `WidgetsFlutterBinding.ensureInitialized()` inside the guarded `appRunner`, as its first
   line.** The default scaffold never calls this at all (it happened to not need it, since nothing
   before `runApp` touched a platform channel) — but `ErrorTracking.init` does async work ahead of
   `runApp`, so it's now required, and it must run inside the same zone as the rest of startup.
3. **`bootstrap` takes an `environment` string; `debug` is derived, not passed in.** Each flavor
   identifies itself by name. `debug: kDebugMode` (from `package:flutter/foundation.dart`) is used
   instead of threading a manual `bool` through three call sites, since `kDebugMode` can't drift
   from the actual build mode the way a hand-typed literal could.

`lib/bootstrap.dart`:
```dart
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:error_tracking/error_tracking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

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
```

Each `main_FLAVOR.dart` passes its own `environment`, keeping `builder` unchanged:
```dart
// main_development.dart
await bootstrap(environment: 'development', builder: () => const App());

// main_staging.dart
await bootstrap(environment: 'staging', builder: () => const App());

// main_production.dart
await bootstrap(environment: 'production', builder: () => const App());
```

## Why the `builder` callback is kept, not replaced

Some real-world bootstrap examples construct the root widget directly inside `bootstrap` instead
(passing in already-built repositories as constructor arguments). Don't switch to that shape here
— keep `builder`. Reasoning:

- **Composition root stays outside `bootstrap`.** `bootstrap` never sees the app widget or its
  dependencies; it only wires infrastructure (error tracking, bloc observer, binding init) and
  runs whatever it's handed. As the app grows real dependencies (a repository backed by local
  storage, for example), those get constructed in `App` itself (idiomatically, via
  `RepositoryProvider`) or in a `main_FLAVOR.dart`, not folded into `bootstrap`. This keeps
  `bootstrap.dart` permanently small and stable instead of growing with every dependency the app
  ever adds.
- **Testability.** `bootstrap` can be exercised in isolation with a throwaway
  `builder: () => Container()` — no repository or client construction needs faking just to verify
  error tracking and the bloc observer wire up correctly.
- **Flavor flexibility is retained for free.** If a flavor ever needs to run a genuinely different
  root widget (a dev-only debug overlay, say), that's a one-line change in that flavor's
  `main_FLAVOR.dart` — `bootstrap` itself never needs to change.

## Verify

From the app root: `flutter analyze` (should report no issues) and `flutter test` (existing tests
should still pass — this change doesn't require new tests of its own, since `bootstrap.dart`'s
behavior is exercised indirectly through `error_tracking`'s own tests).
