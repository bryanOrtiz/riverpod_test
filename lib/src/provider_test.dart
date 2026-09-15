import 'dart:async';

import 'package:collection/collection.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' as test;

/// Generic Riverpod test helper.
///
/// Supports any provider that can be listened to by a [ProviderContainer].
/// [providerTest] wraps [test.test] and records every value emitted by
/// [provider] while running through this lifecycle:
///
/// 1. [setUp] runs, then a [ProviderContainer] is created (via
///    [containerBuilder] if provided, otherwise [ProviderContainer.test]).
/// 2. A listener is attached to [provider]. If [emitInitialState] is `true`,
///    the current value is recorded immediately, before [act] runs.
/// 3. [act] runs and is awaited, so it can perform any actions that change
///    provider state (e.g. calling a notifier method).
/// 4. If [wait] is set, execution pauses for that [Duration] before emitted
///    values are collected, allowing async/debounced state changes to
///    resolve. A `Duration.zero` delay always happens after this, so
///    microtask-scheduled emissions (e.g. `scheduleMicrotask`) are captured.
/// 5. The first [skip] recorded values are discarded.
/// 6. If [expect] is provided, it is called to produce the expected values
///    and compared against everything recorded:
///    - If the expected value is a `List<AsyncValue>` and at least one
///      emitted value is an [AsyncValue], each entry is compared with
///      [_asyncValueEquals] (e.g. [AsyncLoading] instances are always equal
///      regardless of their previous value/error, [AsyncData] is compared by
///      deep equality, and [AsyncError] by its `error` value).
///    - Otherwise, the expected value is treated as a `Matcher` (or wrapped
///      into one), so matchers like `contains`, `containsAll`, and
///      `containsAllInOrder` work as well as plain lists.
///    On failure, a readable diff between expected and actual is appended to
///    the test failure message.
/// 7. [verify] runs, receiving the [ProviderContainer], for any additional
///    assertions (e.g. verifying mock interactions) after [expect].
/// 8. The container is disposed and [tearDown] runs. Both always run, even
///    if [act], [expect], or [verify] throw.
///
/// Examples:
///
/// ```dart
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
/// ```
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
    await _providerTestRunner(
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

/// The engine behind [providerTest]: creates a [ProviderContainer] (via
/// [containerBuilder], or [ProviderContainer.test] by default), listens to
/// [provider], runs [act], and collects every value emitted afterward. Once
/// [wait] (if any) has elapsed and the first [skip] values are dropped, the
/// collected values are compared against [expect], then [verify] runs. The
/// container is always disposed and [tearDown] always runs, even if [act],
/// [expect], or [verify] throws.
///
/// See [providerTest]'s doc comment for the full step-by-step behavior.
Future<void> _providerTestRunner<T>({
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
        if (expected is List &&
            emitted.isNotEmpty &&
            emitted.first is AsyncValue) {
          _expectAsyncValueList(
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
        final diff = _testDiff(expected: expected, actual: emitted);
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

/// Compares two [AsyncValue]s the way test expectations should, rather than
/// with strict `==`: any two [AsyncLoading]s are considered equal regardless
/// of the value/error they carry, [AsyncData]s are compared by deep equality
/// of their value, and [AsyncError]s are compared only by their `error`
/// object (ignoring stack trace). Anything else falls back to `==`.
bool _asyncValueEquals(
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

/// Asserts that [actual] and [expected] contain the same [AsyncValue]s, in
/// the same order, comparing each pair with [_asyncValueEquals]. Fails with a
/// clear reason if the lists have different lengths or if any entry at a
/// given index mismatches.
void _expectAsyncValueList(
  List<AsyncValue> actual,
  List<AsyncValue> expected,
) {
  test.expect(actual.length, expected.length,
      reason: 'Expected: ${expected.length} and actual: ${actual.length} lists '
          'have different lengths');

  for (var i = 0; i < actual.length; i++) {
    test.expect(
      _asyncValueEquals(actual[i], expected[i]),
      test.isTrue,
      reason: 'Mismatch at index $i',
    );
  }
}

/// Create a [diff] enter expected and actual.
String _testDiff({required dynamic expected, required dynamic actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());
  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln()
    ..writeln(differences._toPrettyString())
    ..writeln()
    ..writeln('${"=" * 4} end diff ${"=" * 36}');

  return buffer.toString();
}

extension on List<Diff> {
  /// Renders this list of [Diff]s as a single ANSI-colored string: unchanged
  /// segments are dimmed, deletions are wrapped in `[-...-]` and colored red,
  /// and insertions are wrapped in `{+...+}` and colored green. Used by
  /// [_testDiff] to build the diff appended to failed test messages.
  String _toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
          break;
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
          break;
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
          break;
      }
    }

    return buffer.toString();
  }
}
