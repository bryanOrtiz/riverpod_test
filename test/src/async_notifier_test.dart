import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../async_notifier/async_notifier.dart';
import '../mocks/mocks.dart';
import '../provider/provider.dart';

void main() {
  group('testAsyncNotifier', () {
    group('CounterAsyncNotifier', () {
      providerTest(
        'supports matchers (contains)',
        provider: counterAsyncNotifierProvider(0),
        act: (container) => container
            .read(counterAsyncNotifierProvider(0).notifier)
            .increment(),
        expect: () => contains(const AsyncData(1)),
      );

      providerTest(
        'supports matchers (containsAll)',
        provider: counterAsyncNotifierProvider(0),
        act: (container) {
          container.read(counterAsyncNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => containsAll(
          <AsyncValue<int>>[
            const AsyncData(1),
            const AsyncData(2),
          ],
        ),
      );

      providerTest(
        'supports matchers (containsAllInOrder)',
        provider: counterAsyncNotifierProvider(0),
        act: (container) {
          container.read(counterAsyncNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => containsAllInOrder(
          <AsyncValue<int>>[
            const AsyncData(1),
            const AsyncData(2),
          ],
        ),
      );

      providerTest(
        'expect [] when nothing is called',
        provider: counterAsyncNotifierProvider(0),
        expect: () => const <AsyncValue<int>>[],
      );

      providerTest(
        'expect [AsyncData(1)] when call increment',
        provider: counterAsyncNotifierProvider(0),
        act: (container) => container
            .read(counterAsyncNotifierProvider(0).notifier)
            .increment(),
        expect: () => <AsyncValue<int>>[const AsyncData(1)],
      );

      providerTest(
        'expect [AsyncData(1)] when call increment with async act',
        provider: counterAsyncNotifierProvider(0),
        act: (container) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          container.read(counterAsyncNotifierProvider(0).notifier).increment();
        },
        expect: () => <AsyncValue<int>>[const AsyncData(1)],
      );

      providerTest(
        'expect [AsyncData(1), AsyncData(2)] when call increment multiple times'
        ' with async act',
        provider: counterAsyncNotifierProvider(0),
        act: (container) async {
          container.read(counterAsyncNotifierProvider(0).notifier).increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          container.read(counterAsyncNotifierProvider(0).notifier).increment();
        },
        expect: () => <AsyncValue<int>>[const AsyncData(1), const AsyncData(2)],
      );

      providerTest(
        'expect [AsyncData(2)] when call increment twice and skip: 1',
        provider: counterAsyncNotifierProvider(0),
        act: (container) {
          container.read(counterAsyncNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        skip: 1,
        expect: () => <AsyncValue<int>>[const AsyncData(2)],
      );

      // test('fails immediately when expectation is incorrect', () async {
      //   const expectedError = 'Expected: [AsyncData<int>:AsyncData<int>(value: 2)]\n'
      //       '  Actual: [AsyncData<int>:AsyncData<int>(value: 1)]\n'
      //       '   Which: at location [0] is '
      //       'AsyncData<int>:<AsyncData<int>(value: 1)> instead of '
      //       'AsyncData<int>:<AsyncData<int>(value: 2)>\n'
      //       '\n'
      //       '==== diff ========================================\n'
      //       '\n'
      //       '\x1B[90m[AsyncData<int>(value: '
      //       '\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m)]\x1B[0m\n'
      //       '\n'
      //       '==== end diff ====================================\n';
      //   try {
      //     await asyncNotifierTest<int>(
      //       provider: counterAsyncNotifierProvider(0),
      //       act: (container) => container.read(counterAsyncNotifierProvider(0).notifier).increment(),
      //       expect: () => <AsyncValue<int>>[const AsyncData<int>(2)],
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
      //       await asyncNotifierTest<int>(
      //         provider: errorCountAsyncNotifierProvider,
      //         act: (container) => container.read(errorCountAsyncNotifierProvider.notifier).increment(),
      //         expect: () => <AsyncValue<int>>[const AsyncData<int>(1)],
      //       );
      //     } catch (e) {
      //       expect(e, isA<ErrorCounterNotifierError>());
      //     }
      //   },
      // );

      // test('fails immediately when exception occurs in act', () async {
      //   final exception = Exception('oops');

      //   try {
      //     await asyncNotifierTest<int>(
      //       provider: errorCountAsyncNotifierProvider,
      //       act: (_) => throw exception,
      //       expect: () => [const AsyncData<int>(1)],
      //     );
      //   } catch (e) {
      //     expect(e, equals(exception));
      //   }
      // });
    });

    group('ErrorBuildAsyncNotifier', () {
      providerTest(
        'expect [AsyncError] when build throws',
        provider: errorBuildAsyncNotifierProvider,
        emitInitialState: true,
        expect: () => contains(
          isA<AsyncError<int>>().having(
              (e) => e.error, 'error', isA<ErrorBuildAsyncNotifierError>()),
        ),
      );
    });

    group('AsyncCounterAsyncNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: asyncCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      providerTest(
        'expect [AsyncData(1)] when increment is called',
        provider: asyncCounterAsyncNotifierProvider,
        act: (container) => container
            .read(asyncCounterAsyncNotifierProvider.notifier)
            .increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(1)],
      );

      providerTest(
        'expect [AsyncData([])] when getFromRepository is called',
        provider: listAsyncNotifierProvider,
        act: (container) => container
            .read(listAsyncNotifierProvider.notifier)
            .getFromRepository(),
        expect: () => const <AsyncValue<List<int>>>[AsyncData([])],
      );

      providerTest(
        'expect [AsyncData(1), AsyncData(2)] when increment is called multiple '
        'times with async act',
        provider: asyncCounterAsyncNotifierProvider,
        act: (container) async {
          await container
              .read(asyncCounterAsyncNotifierProvider.notifier)
              .increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await container
              .read(asyncCounterAsyncNotifierProvider.notifier)
              .increment();
        },
        expect: () => const <AsyncValue<int>>[AsyncData(1), AsyncData(2)],
      );

      providerTest(
        'expect [AsyncData(2)] when increment is called twice and skip: 1',
        provider: asyncCounterAsyncNotifierProvider,
        skip: 1,
        act: (container) {
          container.read(asyncCounterAsyncNotifierProvider.notifier)
            ..increment()
            ..increment();
        },
        expect: () => const <AsyncValue<int>>[AsyncData(2)],
      );
    });

    group('DebounceCounterNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: debounceCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      providerTest(
        'expect [AsyncData(1)] when increment is called',
        provider: debounceCounterAsyncNotifierProvider,
        act: (container) => container
            .read(debounceCounterAsyncNotifierProvider.notifier)
            .increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => const <AsyncValue<int>>[AsyncData(1)],
      );

      providerTest(
        'expect [AsyncData(2)] when increment is called twice and skip: 1',
        provider: debounceCounterAsyncNotifierProvider,
        act: (container) async {
          await container
              .read(debounceCounterAsyncNotifierProvider.notifier)
              .increment();
          await Future<void>.delayed(const Duration(milliseconds: 305));
          await container
              .read(debounceCounterAsyncNotifierProvider.notifier)
              .increment();
        },
        skip: 1,
        wait: const Duration(milliseconds: 300),
        expect: () => const <AsyncValue<int>>[AsyncData(2)],
      );
    });

    group('MultiCounterAsyncNotifier', () {
      providerTest(
        'expect [] when nothing is called',
        provider: multiCounterAsyncNotifierProvider,
        expect: () => const <AsyncValue<int>>[],
      );

      providerTest(
        'expect [AsyncData(1), AsyncData(2)] when increment is called',
        provider: multiCounterAsyncNotifierProvider,
        act: (container) => container
            .read(multiCounterAsyncNotifierProvider.notifier)
            .increment(),
        expect: () => const <AsyncValue<int>>[AsyncData(1), AsyncData(2)],
      );

      providerTest(
        'expect [AsyncData(1), AsyncData(2), AsyncData(3), AsyncData(4)] when '
        'increment is called multiple times with async act',
        provider: multiCounterAsyncNotifierProvider,
        act: (container) async {
          container
              .read(multiCounterAsyncNotifierProvider.notifier)
              .increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          container
              .read(multiCounterAsyncNotifierProvider.notifier)
              .increment();
        },
        expect: () => const <AsyncValue<int>>[
          AsyncData(1),
          AsyncData(2),
          AsyncData(3),
          AsyncData(4),
        ],
      );

      providerTest(
        'expect [AsyncData(4)] when increment is called twice and skip: 3',
        provider: multiCounterAsyncNotifierProvider,
        act: (container) {
          container.read(multiCounterAsyncNotifierProvider.notifier)
            ..increment()
            ..increment();
        },
        skip: 3,
        expect: () => const <AsyncValue<int>>[AsyncData(4)],
      );
    });

    group('SideEffectAsyncNotifier', () {
      late MockRepository repository;

      setUp(() {
        repository = MockRepository();
      });

      ProviderContainer createContainer() {
        return ProviderContainer.test(
          overrides: [repositoryProvider.overrideWithValue(repository)],
        );
      }

      providerTest(
        'expect [AsyncData(2)]',
        provider: sideEffectAsyncNotifierProvider(1),
        setUp: () => when(repository.sideEffect).thenReturn(null),
        containerBuilder: createContainer,
        act: (container) => container
            .read(sideEffectAsyncNotifierProvider(1).notifier)
            .increment(),
        expect: () => <AsyncValue<int>>[const AsyncData(2)],
      );

      providerTest(
        'expect [AsyncData(10)]',
        provider: sideEffectAsyncNotifierProvider(1),
        containerBuilder: createContainer,
        setUp: () => when(repository.incrementCounter).thenReturn(10),
        act: (container) => container
            .read(sideEffectAsyncNotifierProvider(1).notifier)
            .incrementByRepository(),
        expect: () => <AsyncValue<int>>[const AsyncData(10)],
      );

//       test('fails immediately when verify is incorrect', () async {
//         const expectedError = '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
//         try {
//           await asyncNotifierTest<int>(
//             provider: sideEffectAsyncNotifierProvider(1),
//             overrides: overrides,
//             act: (container) => container.read(sideEffectAsyncNotifierProvider(1).notifier).increment(),
//             verify: (_) => verify(repository.sideEffect).called(2),
//             tearDown: overrides.clear,
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });

//       test('shows equality warning when strings are identical', () async {
//         const expectedError =
//             '''Expected: [\n            AsyncData<ComplexState>:AsyncData<ComplexState>(value: Instance of 'ComplexStateA')\n          ]
//   Actual: [\n            AsyncData<ComplexState>:AsyncData<ComplexState>(value: Instance of 'ComplexStateA')\n          ]
//    Which: at location [0] is AsyncData<ComplexState>:<AsyncData<ComplexState>(value: Instance of 'ComplexStateA')> instead of AsyncData<ComplexState>:<AsyncData<ComplexState>(value: Instance of 'ComplexStateA')>\n
// WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
// Alternatively, consider using Matchers in the expect of the testAsyncNotifier rather than concrete state instances.\n''';

//         try {
//           await asyncNotifierTest<ComplexState>(
//             provider: complexAsyncNotifierProvider,
//             act: (container) => container.read(complexAsyncNotifierProvider.notifier).setComplexStateA(),
//             expect: () => <AsyncValue<ComplexState>>[
//               AsyncData(ComplexStateA()),
//             ],
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });
    });
  });

  group('tearDown', () {
    late int tearDownCallCount;
    AsyncValue<int>? state;

    setUp(() {
      tearDownCallCount = 0;
    });

    tearDown(() {
      expect(tearDownCallCount, equals(1));
    });

    providerTest(
      'is called after the test is run',
      provider: counterAsyncNotifierProvider(0),
      act: (container) =>
          container.read(counterAsyncNotifierProvider(0).notifier).increment(),
      expect: () => contains(const AsyncData(1)),
      // ignore: invalid_use_of_protected_member
      verify: (container) => state =
          container.read(counterAsyncNotifierProvider(0).notifier).state,
      tearDown: () {
        tearDownCallCount++;
        expect(state, equals(const AsyncData(1)));
      },
    );
  });
}
