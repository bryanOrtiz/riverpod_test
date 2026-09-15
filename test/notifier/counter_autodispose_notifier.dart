import 'package:riverpod/riverpod.dart';

final counterAutoDisposeNotifierProvider =
    NotifierProvider.autoDispose<CounterAutoDisposeNotifier, int>(
  CounterAutoDisposeNotifier.new,
);

class CounterAutoDisposeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
