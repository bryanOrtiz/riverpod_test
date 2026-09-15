import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:test/test.dart';

void main() {
  mainProvider();
  mainNotifier();
}

void mainProvider() {
  group('counterProvider', () {
    providerTest(
      'expect []',
      provider: counterProvider,
      expect: () => const <int>[],
    );
  });
}

void mainNotifier() {
  group('counterNotifierProvider', () {
    providerTest(
      'expect [1] when increment is called',
      provider: counterNotifierProvider,
      act: (container) =>
          container.read(counterNotifierProvider.notifier).increment(),
      expect: () => const <int>[1],
    );

    providerTest(
      'expect [AsyncData(2)] when increment is called with seed: AsyncData(1)',
      provider: counterAsyncNotifierProvider(0),
      containerBuilder: () => ProviderContainer(
        overrides: [
          counterAsyncNotifierProvider(0)
              .overrideWith(() => CounterAsyncNotifier(1)),
        ],
      ),
      act: (container) =>
          container.read(counterAsyncNotifierProvider(0).notifier).increment(),
      expect: () => [const AsyncData(2)],
    );

    providerTest(
      'expect [AsyncData(2)] when increment is called with seed: AsyncData(1)',
      provider: counterStreamNotifierProvider(0),
      containerBuilder: () => ProviderContainer(
        overrides: [
          counterStreamNotifierProvider(0)
              .overrideWith(() => CounterStreamNotifier(1)),
        ],
      ),
      act: (container) =>
          container.read(counterStreamNotifierProvider(0).notifier).increment(),
      expect: () => [const AsyncData(2)],
    );
  });
}

final counterProvider = Provider<int>((ref) => 0);

final counterNotifierProvider =
    NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

final counterAsyncNotifierProvider =
    AsyncNotifierProvider.family<CounterAsyncNotifier, int, int>(
        CounterAsyncNotifier.new);

final counterStreamNotifierProvider =
    StreamNotifierProvider.family<CounterStreamNotifier, int, int>(
        CounterStreamNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

class CounterAsyncNotifier extends AsyncNotifier<int> {
  CounterAsyncNotifier(this.initialValue);
  final int initialValue;
  @override
  FutureOr<int> build() {
    return initialValue;
  }

  void increment() => state = AsyncData(state.value! + 1);
}

class CounterStreamNotifier extends StreamNotifier<int> {
  CounterStreamNotifier(this.initialValue);

  final int initialValue;

  late final StreamController<int> _controller;
  late int _count;

  @override
  Stream<int> build() {
    _count = initialValue;
    _controller = StreamController<int>();

    ref.onDispose(() {
      _controller.close();
    });

    scheduleMicrotask(() {
      _controller.add(_count);
    });

    return _controller.stream;
  }

  void increment() {
    _count++;

    _controller.add(_count);
  }
}
