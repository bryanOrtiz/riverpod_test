import 'dart:async';
import 'package:riverpod/riverpod.dart';

import '../provider/provider.dart';
import 'async_notifier.dart';

final sideEffectAsyncNotifierProvider =
    AsyncNotifierProvider.family<SideEffectAsyncNotifier, int, int>(
        SideEffectAsyncNotifier.new);

class SideEffectAsyncNotifier extends AsyncNotifier<int> {
  SideEffectAsyncNotifier(this.initialValue);

  final int initialValue;
  Repository get repository => ref.watch(repositoryProvider);

  @override
  FutureOr<int> build() {
    return initialValue;
  }

  void increment() {
    repository.sideEffect();
    state = AsyncData(value + 1);
  }

  void incrementByRepository() =>
      state = AsyncData(repository.incrementCounter());
}
