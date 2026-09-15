import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/src/provider_test.dart';
import 'package:test/test.dart';

import '../mocks/mocks.dart';
import '../provider/provider.dart';

void main() {
  group('testProvider', () {
    group('counterProvider', () {
      providerTest(
        'expect [0]',
        provider: counterProvider,
        expect: () => <int>[],
      );

      providerTest(
        'expect [5]',
        provider: familyCounterProvider(5),
        expect: () => <int>[],
      );
    });

    group('futureProvider', () {
      late MockComplexRepository mockRepository;

      setUpAll(() {
        mockRepository = MockComplexRepository();
      });

      ProviderContainer createContainer() {
        return ProviderContainer.test(
          overrides: [
            complexRepositoryProvider.overrideWithValue(
              mockRepository,
            ),
          ],
          // Fail immediately instead of retrying, so errors surface as
          // AsyncError right away.
          retry: (retryCount, error) => null,
        );
      }

      providerTest(
        'expect [AsyncLoading(), AsyncData(1)]',
        provider: futureProvider,
        containerBuilder: createContainer,
        setUp: () =>
            when(mockRepository.fetchCounter).thenAnswer((_) async => 1),
        expect: () => <AsyncValue<int>>[
          const AsyncData(1),
        ],
      );

      providerTest(
        'expect [AsyncLoading(), AsyncData([])]',
        provider: futureListProvider,
        containerBuilder: createContainer,
        setUp: () =>
            when(mockRepository.fetchCounterList).thenAnswer((_) async => []),
        expect: () => <AsyncValue<List<int>>>[
          const AsyncData([]),
        ],
      );

      providerTest(
        'expect [AsyncLoading(), AsyncData(10)]',
        provider: familyFutureProvider(10),
        containerBuilder: createContainer,
        wait: const Duration(milliseconds: 100),
        expect: () => <AsyncValue<int>>[
          const AsyncData(10),
        ],
      );

      final exception = Exception('oops');

      providerTest(
        'expect [AsyncError(exception)] when repository throws',
        provider: futureProvider,
        containerBuilder: createContainer,
        setUp: () => when(mockRepository.fetchCounter)
            .thenAnswer((_) async => throw exception),
        expect: () => <AsyncValue<int>>[
          AsyncError<int>(exception, StackTrace.empty),
        ],
      );

//       test('fails immediately when verify is incorrect', () async {
//         const expectedError =
//             '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
//         try {
//           await providerTest<AsyncValue<int>>(
//             provider: futureProvider,
//             overrides: overrides,
//             verify: () => verify(mockRepository.fetchCounter).called(2),
//             tearDown: overrides.clear,
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });

//       test('shows equality warning when strings are identical', () async {
//         const expectedError = '''Expected: [Instance of 'CounterDataSource']
//   Actual: [Instance of 'CounterDataSource']
//    Which: at location [0] is <Instance of 'CounterDataSource'> instead of <Instance of 'CounterDataSource'>\n
// WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
// Alternatively, consider using Matchers in the expect of the testProvider rather than concrete state instances.\n''';
//         try {
//           await providerTest<CounterDataSource>(
//             provider: counterDataSourceProvider,
//             expect: () => <CounterDataSource>[CounterDataSource()],
//           );
//         } catch (e) {
//           expect((e as TestFailure).message, expectedError);
//         }
//       });
    });

    group('streamProvider', () {
      providerTest(
        'expect [AsyncLoading(), AsyncData(0), AsyncData(1)]',
        provider: streamProvider,
        expect: () => <AsyncValue<int>>[
          const AsyncData(0),
          const AsyncData(1),
        ],
      );

      providerTest(
        'expect [AsyncLoading(), AsyncData(0), AsyncData(1), AsyncData(2)]',
        provider: familysStreamProvider(3),
        wait: const Duration(milliseconds: 100),
        expect: () => <AsyncValue<int>>[
          const AsyncData(0),
          const AsyncData(1),
          const AsyncData(2),
        ],
      );
    });

    // group('familyExceptionProvider', () {
    //   final exception = Exception('oops');

    //   testProvider<int>(
    //     'errors supports matchers',
    //     provider: familyExceptionProvider(exception),
    //     errors: () => contains(exception),
    //   );

    //   testProvider<int>(
    //     'captures uncaught exceptions',
    //     provider: familyExceptionProvider(exception),
    //     errors: () => <Matcher>[equals(exception)],
    //   );
    // });
  });
}
