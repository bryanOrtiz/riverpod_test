import 'package:riverpod/riverpod.dart';

final counterFamilyNotifierProvider = NotifierProvider.family<CounterFamilyNotifier, int, int>(
  CounterFamilyNotifier.new,
);

class CounterFamilyNotifier extends Notifier<int> {
  CounterFamilyNotifier(this.initialValue);
  final int initialValue;
  @override
  int build() => initialValue;

  void increment() => state++;
}
