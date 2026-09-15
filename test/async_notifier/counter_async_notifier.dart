import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final counterAsyncNotifierProvider =
    AsyncNotifierProvider.family<CounterAsyncNotifier, int, int>(
        CounterAsyncNotifier.new);

class CounterAsyncNotifier extends AsyncNotifier<int> {
  CounterAsyncNotifier(this.initialValue);
  final int initialValue;
  @override
  FutureOr<int> build() {
    return initialValue;
  }

  void increment() => state = AsyncData(value + 1);
}
