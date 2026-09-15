import 'package:riverpod/riverpod.dart';

final initialCounterProvider = Provider<int>(
  (ref) => 0,
);

final counterNotifierProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(initialCounterProvider);

  void increment() => state++;
}
