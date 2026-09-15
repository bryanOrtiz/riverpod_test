import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/src/diff.dart';
import 'package:test/test.dart' as test;

/// Generic Riverpod test helper.
///
/// Supports any provider that can be listened to by a ProviderContainer.
///
/// Examples:
///
/// providerTest<int>(
///   'returns 0',
///   provider: counterProvider,
///   expect: () => [0],
/// );
///
/// providerTest<int>(
///   'increments',
///   provider: counterProvider,
///   act: (container) {
///     container.read(counterProvider.notifier).increment();
///   },
///   emitInitialState: false,
///   expect: () => [1],
/// );
///
@isTest
void providerTest(
  String description, {
  required ProviderListenable provider,
  ProviderContainer Function()? containerBuilder,
  FutureOr<void> Function()? setUp,
  FutureOr<void> Function(ProviderContainer container)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  FutureOr<void> Function(ProviderContainer container)? verify,
  FutureOr<void> Function()? tearDown,
  bool emitInitialState = false,
}) {
  test.test(description, () async {
    await providerTestRunner(
      provider: provider,
      containerBuilder: containerBuilder,
      setUp: setUp,
      act: act,
      wait: wait,
      skip: skip,
      expect: expect,
      verify: verify,
      tearDown: tearDown,
      emitInitialState: emitInitialState,
    );
  });
}

@visibleForTesting
Future<void> providerTestRunner<T>({
  required ProviderListenable<T> provider,
  ProviderContainer Function()? containerBuilder,
  FutureOr<void> Function()? setUp,
  FutureOr<void> Function(ProviderContainer container)? act,
  Duration? wait,
  int skip = 0,
  dynamic Function()? expect,
  FutureOr<void> Function(ProviderContainer container)? verify,
  FutureOr<void> Function()? tearDown,
  bool emitInitialState = true,
}) async {
  await setUp?.call();

  final _container = containerBuilder?.call() ??
      // ignore: invalid_use_of_visible_for_testing_member
      ProviderContainer.test();

  final emitted = <T>[];

  try {
    final subscription = _container.listen<T>(
      provider,
      (previous, next) {
        emitted.add(next);
      },
      fireImmediately: emitInitialState,
    );

    // Keep autoDispose providers alive.
    subscription.read();

    await act?.call(_container);

    if (wait != null) {
      await Future<void>.delayed(wait);
    }

    await Future<void>.delayed(Duration.zero);

    if (skip > 0) {
      emitted.removeRange(
        0,
        skip.clamp(0, emitted.length),
      );
    }

    if (expect != null) {
      final expected = expect();

      try {
        if (expected is List && emitted.isNotEmpty && emitted.first is AsyncValue) {
          expectAsyncValueList(
            emitted.cast<AsyncValue>(),
            expected.cast<AsyncValue>(),
          );
        } else {
          test.expect(
            emitted,
            test.wrapMatcher(expected),
          );
        }
      } on test.TestFailure catch (e) {
        final diff = testDiff(expected: expected, actual: emitted);
        final message = '${e.message}\n$diff';
        throw test.TestFailure(message);
      }
    }

    await verify?.call(_container);
  } finally {
    _container.dispose();
    await tearDown?.call();
  }
}

bool asyncValueEquals(
  AsyncValue actual,
  AsyncValue expected,
) {
  if (actual is AsyncLoading && expected is AsyncLoading) {
    return true;
  }

  if (actual is AsyncData && expected is AsyncData) {
    return const DeepCollectionEquality().equals(
      actual.value,
      expected.value,
    );
  }

  if (actual is AsyncError && expected is AsyncError) {
    return actual.error == expected.error;
  }

  return actual == expected;
}

void expectAsyncValueList(
  List<AsyncValue> actual,
  List<AsyncValue> expected,
) {
  test.expect(actual.length, expected.length,
      reason: 'Expected: ${expected.length} and actual: ${actual.length} lists '
          'have different lengths');

  for (var i = 0; i < actual.length; i++) {
    test.expect(
      asyncValueEquals(actual[i], expected[i]),
      test.isTrue,
      reason: 'Mismatch at index $i',
    );
  }
}
