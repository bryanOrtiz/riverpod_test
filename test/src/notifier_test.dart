import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/src/provider_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../notifier/notifier.dart';
import '../provider/provider.dart';

void main() {
  group('providerTest', () {
    group('CounterNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: counterNotifierProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called',
        provider: counterNotifierProvider,
        act: (container) =>
            container.read(counterNotifierProvider.notifier).increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple times',
        provider: counterNotifierProvider,
        act: (container) {
          container.read(counterNotifierProvider.notifier)
            ..increment()
            ..increment();
        },
        expect: () => <int>[1, 2],
      );

      providerTest(
        'expect [3] when increment is called and seed is 2',
        provider: counterNotifierProvider,
        containerBuilder: () => ProviderContainer.test(
          overrides: [
            initialCounterProvider.overrideWithValue(2),
          ],
        ),
        act: (container) =>
            container.read(counterNotifierProvider.notifier).increment(),
        expect: () => <int>[3],
      );
    });

    group('AsyncCounterNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: asyncCounterNotifierProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called',
        provider: asyncCounterNotifierProvider,
        act: (container) =>
            container.read(asyncCounterNotifierProvider.notifier).increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple '
        'times with async act',
        provider: asyncCounterNotifierProvider,
        act: (container) async {
          await container
              .read(asyncCounterNotifierProvider.notifier)
              .increment();
          await container
              .read(asyncCounterNotifierProvider.notifier)
              .increment();
        },
        expect: () => <int>[1, 2],
      );
    });

    group('DelayedCounterNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: delayedCounterNotifierProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [] when increment is called without wait',
        provider: delayedCounterNotifierProvider,
        act: (container) =>
            container.read(delayedCounterNotifierProvider.notifier).increment(),
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called with wait',
        provider: delayedCounterNotifierProvider,
        act: (container) =>
            container.read(delayedCounterNotifierProvider.notifier).increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => <int>[1],
      );
    });

    group('MultiCounterNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: multiCounterNotifierProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [1, 2] when increment is called',
        provider: multiCounterNotifierProvider,
        act: (container) =>
            container.read(multiCounterNotifierProvider.notifier).increment(),
        expect: () => <int>[1, 2],
      );

      providerTest(
        'expect [1, 2, 3, 4] when increment is called '
        'multiple times',
        provider: multiCounterNotifierProvider,
        act: (container) {
          container.read(multiCounterNotifierProvider.notifier).increment();
          container.read(multiCounterNotifierProvider.notifier).increment();
        },
        expect: () => <int>[1, 2, 3, 4],
      );
    });

    group('ComplexNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: complexNotifierProvider,
        expect: () => <Matcher>[],
      );

      providerTest(
        'expect [ComplexStateB] when emitB is called',
        provider: complexNotifierProvider,
        act: (container) =>
            container.read(complexNotifierProvider.notifier).setComplexStateB(),
        expect: () => [isA<ComplexStateB>()],
      );
    });

    group('SideEffectCounterNotifier', () {
      late MockRepository repository;

      setUp(() {
        repository = MockRepository();
        when(repository.sideEffect).thenReturn(null);
      });

      ProviderContainer createContainer() {
        return ProviderContainer.test(
          overrides: [repositoryProvider.overrideWithValue(repository)],
        );
      }

      providerTest(
        'expect [] when nothing is called',
        provider: sideEffectCounterNotifierProvider,
        containerBuilder: createContainer,
        expect: () => <int>[],
      );

      providerTest(
        'expect [10] when incrementByRepository is called',
        setUp: () => when(repository.incrementCounter).thenReturn(10),
        provider: sideEffectCounterNotifierProvider,
        containerBuilder: createContainer,
        act: (container) => container
            .read(sideEffectCounterNotifierProvider.notifier)
            .incrementByRepository(),
        expect: () => <int>[10],
        verify: (_) => verify(repository.incrementCounter).called(1),
      );

      providerTest(
        'does not require an expect',
        provider: sideEffectCounterNotifierProvider,
        containerBuilder: createContainer,
        act: (container) => container
            .read(sideEffectCounterNotifierProvider.notifier)
            .increment(),
        verify: (_) => verify(repository.sideEffect).called(1),
      );
    });

    group('CounterAutoDisposeNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: counterAutoDisposeNotifierProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called',
        provider: counterAutoDisposeNotifierProvider,
        act: (container) => container
            .read(counterAutoDisposeNotifierProvider.notifier)
            .increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple times',
        provider: counterAutoDisposeNotifierProvider,
        act: (container) {
          container.read(counterAutoDisposeNotifierProvider.notifier)
            ..increment()
            ..increment();
        },
        expect: () => <int>[1, 2],
      );
    });

    group('CounterFamilyNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: counterFamilyNotifierProvider(0),
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called',
        provider: counterFamilyNotifierProvider(0),
        act: (container) => container
            .read(counterFamilyNotifierProvider(0).notifier)
            .increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple times',
        provider: counterFamilyNotifierProvider(0),
        act: (container) {
          container.read(counterFamilyNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => <int>[1, 2],
      );
    });

    group('CounterAutoDisposeFamilyNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        act: (container) => container
            .read(counterAutoDisposeFamilyNotifierProvider(0).notifier)
            .increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple times',
        provider: counterAutoDisposeFamilyNotifierProvider(0),
        act: (container) {
          container.read(counterAutoDisposeFamilyNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => <int>[1, 2],
      );
    });
  });
}
