import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

/// Pins the [ProviderContainer.defaultRetry] behavior (Riverpod 3.3.2) that
/// this package's other AsyncError tests rely on: a `build()` that throws a
/// plain [Exception] gets automatically retried (surfacing as a transient
/// `AsyncLoading(retrying: true)`), while a `build()` that throws an [Error]
/// bypasses retry entirely and settles straight into `AsyncError`.
///
/// If a future Riverpod upgrade changes this, it should fail loudly here
/// instead of showing up as unexplained flakiness/timeouts in unrelated
/// AsyncError tests elsewhere in this package.
void main() {
  group('ProviderContainer.defaultRetry', () {
    providerTest(
      'retries (AsyncLoading(retrying: true)) when build throws an Exception',
      provider: FutureProvider<int>((ref) => throw Exception('boom')),
      emitInitialState: true,
      expect: () => contains(
        isA<AsyncLoading<int>>().having((v) => v.retrying, 'retrying', isTrue),
      ),
    );

    providerTest(
      'does not retry (AsyncError immediately) when build throws an Error',
      provider: FutureProvider<int>((ref) => throw _CustomBuildError()),
      emitInitialState: true,
      expect: () => contains(
        isA<AsyncError<int>>()
            .having((v) => v.error, 'error', isA<_CustomBuildError>()),
      ),
    );
  });
}

class _CustomBuildError extends Error {}
