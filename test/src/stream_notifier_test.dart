import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

import '../stream_notifier/stream_notifier.dart';

void main() {
  group('testStreamNotifier', () {
    group('CounterStreamNotifier', () {
      providerTest(
        'supports matchers (contains)',
        provider: counterStreamNotifierProvider(0),
        act: (container) => container
            .read(counterStreamNotifierProvider(0).notifier)
            .increment(),
        expect: () => contains(const AsyncData(1)),
      );

      providerTest(
        'supports matchers (containsAll)',
        provider: counterStreamNotifierProvider(0),
        act: (container) {
          container.read(counterStreamNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => containsAll(
          [
            const AsyncData(0),
            const AsyncData(1),
          ],
        ),
      );

      providerTest(
        'supports matchers (containsAllInOrder)',
        provider: counterStreamNotifierProvider(0),
        act: (container) {
          container.read(counterStreamNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        expect: () => containsAllInOrder(
          [
            const AsyncData(0),
            const AsyncData(1),
          ],
        ),
      );

      providerTest(
        'expect [] when nothing is called',
        provider: counterStreamNotifierProvider(0),
        expect: () => const <AsyncValue<int>>[AsyncData(0)],
      );

      providerTest(
        'expect [const AsyncLoading(), const AsyncData(0), const AsyncData(1)] '
        'when call increment',
        provider: counterStreamNotifierProvider(0),
        emitInitialState: true,
        wait: const Duration(milliseconds: 100),
        act: (container) {
          container.read(counterStreamNotifierProvider(0).notifier).increment();
        },
        expect: () =>
            [const AsyncLoading(), const AsyncData(0), const AsyncData(1)],
      );

      providerTest(
        'expect [const AsyncLoading(), const AsyncData(0), const AsyncData(1)] '
        'when call increment with async act',
        provider: counterStreamNotifierProvider(0),
        act: (container) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          container.read(counterStreamNotifierProvider(0).notifier).increment();
        },
        expect: () => [const AsyncData(0), const AsyncData(1)],
      );

      providerTest(
        'expect [AsyncData(1), AsyncData(2)] when call increment multiple times'
        ' with async act',
        provider: counterStreamNotifierProvider(0),
        act: (container) async {
          container.read(counterStreamNotifierProvider(0).notifier).increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          container.read(counterStreamNotifierProvider(0).notifier).increment();
        },
        expect: () =>
            [const AsyncData(0), const AsyncData(1), const AsyncData(2)],
      );

      providerTest(
        'expect [AsyncData(1)] when call increment twice and skip: 1',
        provider: counterStreamNotifierProvider(0),
        act: (container) {
          container.read(counterStreamNotifierProvider(0).notifier)
            ..increment()
            ..increment();
        },
        skip: 1,
        expect: () => <AsyncValue<int>>[const AsyncData(1)],
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
      //       provider: counterStreamNotifierProvider(0),
      //       act: (container) => container.read(counterStreamNotifierProvider(0).notifier).increment(),
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
      //         provider: errorCountStreamNotifierProvider,
      //         act: (container) => container.read(errorCountStreamNotifierProvider.notifier).increment(),
      //         expect: () => <AsyncValue<int>>[const AsyncData<int>(1)],
      //       );
      //     } catch (e) {
      //       expect(e, isA<ErrorCounterStreamNotifierError>());
      //     }
      //   },
      // );

      // test('fails immediately when exception occurs in act', () async {
      //   final exception = Exception('oops');

      //   try {
      //     await asyncNotifierTest<int>(
      //       provider: errorCountStreamNotifierProvider,
      //       act: (_) => throw exception,
      //       expect: () => [const AsyncData<int>(1)],
      //     );
      //   } catch (e) {
      //     expect(e, equals(exception));
      //   }
      // });
    });

    group('ErrorBuildStreamNotifier', () {
      providerTest(
        'expect [AsyncError] when build throws',
        provider: errorBuildStreamNotifierProvider,
        emitInitialState: true,
        expect: () => contains(
          isA<AsyncError<int>>().having(
              (e) => e.error, 'error', isA<ErrorBuildStreamNotifierError>()),
        ),
      );
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
      'is called after the test is run (StreamNotifier)',
      provider: counterStreamNotifierProvider(0),
      act: (container) =>
          container.read(counterStreamNotifierProvider(0).notifier).increment(),
      expect: () => contains(const AsyncData(1)),
      // ignore: invalid_use_of_protected_member
      verify: (container) => state =
          container.read(counterStreamNotifierProvider(0).notifier).state,
      tearDown: () {
        tearDownCallCount++;
        expect(state, equals(const AsyncData(1)));
      },
    );
  });
}
