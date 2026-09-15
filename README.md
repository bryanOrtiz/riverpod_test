<p align="center">
<a href="https://pub.dev/packages/riverpod_test"><img src="https://img.shields.io/pub/v/riverpod_test.svg?color=blue" alt="Pub"></a>
<a href="https://github.com/Eronildo/riverpod_test"><img src="https://img.shields.io/github/stars/Eronildo/riverpod_test.svg?style=flat&logo=github&colorB=blue&label=stars" alt="Star on Github"></a>
<a href="https://docs.flutter.dev/development/data-and-backend/state-mgmt/options#riverpod"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/rrousselGit/riverpod"><img src="https://img.shields.io/pub/v/riverpod.svg?label=riverpod&color=blue)](https://pub.dartlang.org/packages/riverpod" alt="Bloc Library"></a>
</p>

---

## Package

Package is a port of `felangel`'s `bloc_test`, modified to work with Riverpod Providers.\
Increase code coverage by testing all riverpod providers.

## Installation

For a Flutter project:

```console
flutter pub add --dev riverpod_test
```

For a Dart project:

```console
dart pub add --dev riverpod_test
```

## Usage

The package exposes a single generic test helper, `providerTest`, which works
with any provider that can be listened to by a `ProviderContainer` —
`Provider`, `Notifier`, `AsyncNotifier`, `StreamNotifier`, `FutureProvider`,
`StreamProvider`, and their `family`/`autoDispose` variants.

### `Provider`

```dart
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';

void main() {
  providerTest(
    'expect [0]',
    provider: counterProvider,
    emitInitialState: true,
    expect: () => [0],
  );
}

final counterProvider = Provider<int>((ref) => 0);
```

### `Notifier`

```dart
providerTest(
  'expect [1, 2] when increment is called twice',
  provider: counterNotifierProvider,
  act: (container) {
    container.read(counterNotifierProvider.notifier)
      ..increment()
      ..increment();
  },
  expect: () => [1, 2],
);

final counterNotifierProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
```

### `AsyncNotifier` (also works for `StreamNotifier` and `FutureProvider`)

```dart
providerTest(
  'expect [AsyncData(1)] when increment is called',
  provider: counterAsyncNotifierProvider(0),
  act: (container) =>
      container.read(counterAsyncNotifierProvider(0).notifier).increment(),
  expect: () => <AsyncValue<int>>[const AsyncData(1)],
);

final counterAsyncNotifierProvider =
    AsyncNotifierProvider.family<CounterAsyncNotifier, int, int>(
  CounterAsyncNotifier.new,
);

class CounterAsyncNotifier extends AsyncNotifier<int> {
  CounterAsyncNotifier(this.initialValue);

  final int initialValue;

  @override
  FutureOr<int> build() => initialValue;

  void increment() => state = AsyncData(state.value! + 1);
}
```

### Overriding providers and verifying mocks

`providerTest`'s `containerBuilder` replaces the old `overrides` parameter —
it lets you build a `ProviderContainer` with whatever overrides your test
needs, and `verify` runs afterward with that same container.

```dart
providerTest(
  'verifies sideEffect is called when increment is called',
  provider: sideEffectAsyncNotifierProvider(1),
  containerBuilder: () => ProviderContainer.test(
    overrides: [repositoryProvider.overrideWithValue(mockRepository)],
  ),
  act: (container) =>
      container.read(sideEffectAsyncNotifierProvider(1).notifier).increment(),
  verify: (_) => verify(mockRepository.sideEffect).called(1),
);

final repositoryProvider = Provider<Repository>((ref) => Repository());

class Repository {
  void sideEffect() {}
}

class MockRepository extends Mock implements Repository {}

final sideEffectAsyncNotifierProvider =
    AsyncNotifierProvider.family<SideEffectAsyncNotifier, int, int>(
  SideEffectAsyncNotifier.new,
);

class SideEffectAsyncNotifier extends AsyncNotifier<int> {
  SideEffectAsyncNotifier(this.initialValue);

  final int initialValue;

  Repository get repository => ref.watch(repositoryProvider);

  @override
  FutureOr<int> build() => initialValue;

  void increment() {
    repository.sideEffect();
    state = AsyncData(state.value! + 1);
  }
}
```