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
        act: (container) => container.read(counterNotifierProvider.notifier).increment(),
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
        act: (container) => container.read(counterNotifierProvider.notifier).increment(),
        expect: () => <int>[3],
      );

      // test('fails immediately when expectation is incorrect', () async {
      //   const expectedError = 'Expected: [2]\n'
      //       '  Actual: [1]\n'
      //       '   Which: at location [0] is <1> instead of <2>\n'
      //       '\n'
      //       '==== diff ========================================\n'
      //       '\n'
      //       // ignore: lines_longer_than_80_chars
      //       '\x1B[90m[\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m]\x1B[0m\n'
      //       '\n'
      //       '==== end diff ====================================\n';
      //   try {
      //     await notifierTest<CounterNotifier, int>(
      //       provider: counterNotifierProvider,
      //       act: (notifier) => notifier.increment(),
      //       expect: () => <int>[2],
      //       errors: Exception.new,
      //     );
      //   } catch (e) {
      //     expect((e as TestFailure).message, expectedError);
      //   }
      // });

      // test(
      //   'fails immediately when '
      //   'uncaught exception occurs within notifier',
      //   () async {
      //     try {
      //       await notifierTest<ErrorCounterNotifier, int>(
      //         provider: errorNotifierProvider,
      //         act: (notifier) => notifier.increment(),
      //         expect: () => <int>[1],
      //       );
      //     } catch (e) {
      //       expect(e, isA<CounterNotifierError>());
      //     }
      //   },
      // );

      // test('fails immediately when exception occurs in act', () async {
      //   final exception = Exception('oops');

      //   try {
      //     await notifierTest<ErrorCounterNotifier, int>(
      //       provider: errorNotifierProvider,
      //       act: (_) => throw exception,
      //       expect: () => [1],
      //     );
      //   } catch (e) {
      //     expect(e, equals(exception));
      //   }
      // });
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
        act: (container) => container.read(asyncCounterNotifierProvider.notifier).increment(),
        expect: () => <int>[1],
      );

      providerTest(
        'expect [1, 2] when increment is called multiple '
        'times with async act',
        provider: asyncCounterNotifierProvider,
        act: (container) async {
          await container.read(asyncCounterNotifierProvider.notifier).increment();
          await container.read(asyncCounterNotifierProvider.notifier).increment();
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
        act: (container) => container.read(delayedCounterNotifierProvider.notifier).increment(),
        expect: () => <int>[],
      );

      providerTest(
        'expect [1] when increment is called with wait',
        provider: delayedCounterNotifierProvider,
        act: (container) => container.read(delayedCounterNotifierProvider.notifier).increment(),
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
        act: (container) => container.read(multiCounterNotifierProvider.notifier).increment(),
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
        act: (container) => container.read(complexNotifierProvider.notifier).setComplexStateB(),
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
        act: (container) => container.read(sideEffectCounterNotifierProvider.notifier).incrementByRepository(),
        expect: () => <int>[10],
        verify: (_) => verify(repository.incrementCounter).called(1),
      );

      providerTest(
        'does not require an expect',
        provider: sideEffectCounterNotifierProvider,
        containerBuilder: createContainer,
        act: (container) => container.read(sideEffectCounterNotifierProvider.notifier).increment(),
        verify: (_) => verify(repository.sideEffect).called(1),
      );

//       test('fails immediately when verify is incorrect', () async {
//         const expectedError = '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
//         try {
//           await notifierTest<int>(
//             provider: sideEffectCounterNotifierProvider,
//             overrides: overrides,
//             act: (notifier) => notifier.increment(),
//             verify: (_) => verify(repository.sideEffect).called(2),
//             tearDown: overrides.clear,
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });

//       test('shows equality warning when strings are identical', () async {
//         const expectedError = '''Expected: [Instance of 'ComplexStateA']
//   Actual: [Instance of 'ComplexStateA']
//    Which: at location [0] is <Instance of 'ComplexStateA'> instead of <Instance of 'ComplexStateA'>\n
// WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
// Alternatively, consider using Matchers in the expect of the providerTest rather than concrete state instances.\n''';
//         try {
//           await notifierTest<ComplexState>(
//             provider: complexNotifierProvider,
//             act: (notifier) => notifier.setComplexStateA(),
//             expect: () => <ComplexState>[ComplexStateA()],
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });
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
        act: (container) => container.read(counterAutoDisposeNotifierProvider.notifier).increment(),
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
        act: (container) => container.read(counterFamilyNotifierProvider(0).notifier).increment(),
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
        act: (container) => container.read(counterAutoDisposeFamilyNotifierProvider(0).notifier).increment(),
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
