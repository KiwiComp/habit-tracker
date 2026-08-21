// bloc_lint wants every Bloc/Cubit subclass in its own file named after it.
// `_CounterCubit` is a throwaway, test-only fixture that exists solely to
// give `AppBlocObserver` a real `BlocBase` to observe — see KNOWN_GAPS.md
// for the deferred decision on whether it's worth a dedicated file.
// ignore_for_file: prefer_file_naming_conventions

import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app_bloc_observer.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void fail() => addError(Exception('boom'), StackTrace.current);
}

void main() {
  group('AppBlocObserver', () {
    test('onChange calls through to super without throwing', () {
      const observer = AppBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);

      expect(
        () => observer.onChange(
          cubit,
          const Change<int>(currentState: 0, nextState: 1),
        ),
        returnsNormally,
      );
    });

    test('onError calls through to super without throwing', () {
      const observer = AppBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);

      expect(
        () => observer.onError(cubit, Exception('boom'), StackTrace.current),
        returnsNormally,
      );
    });

    test(
      'installed as Bloc.observer, state changes still propagate normally',
      () async {
        final previousObserver = Bloc.observer;
        Bloc.observer = const AppBlocObserver();
        addTearDown(() => Bloc.observer = previousObserver);

        final cubit = _CounterCubit();
        addTearDown(cubit.close);

        final states = <int>[];
        final subscription = cubit.stream.listen(states.add);
        addTearDown(subscription.cancel);

        cubit.increment();
        await Future<void>.delayed(Duration.zero);

        expect(states, [1]);
        expect(cubit.state, 1);
      },
    );

    test(
      'installed as Bloc.observer, addError does not throw or block '
      'further emits',
      () async {
        final previousObserver = Bloc.observer;
        Bloc.observer = const AppBlocObserver();
        addTearDown(() => Bloc.observer = previousObserver);

        final cubit = _CounterCubit();
        addTearDown(cubit.close);

        expect(cubit.fail, returnsNormally);

        cubit.increment();
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, 1);
      },
    );
  });
}
