import 'package:riverpod/riverpod.dart';

final counterAutoDisposeFamilyNotifierProvider =
    NotifierProvider.autoDispose.family<CounterAutoDisposeFamilyNotifier, int, int>(
  (intialValue) => CounterAutoDisposeFamilyNotifier(intialValue),
);

class CounterAutoDisposeFamilyNotifier extends Notifier<int> {
  CounterAutoDisposeFamilyNotifier(this.initialValue);
  final int initialValue;
  @override
  int build() => initialValue;

  void increment() => state++;
}
