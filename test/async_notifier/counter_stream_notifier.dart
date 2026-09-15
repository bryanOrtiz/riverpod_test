import 'dart:async';
import 'package:riverpod/riverpod.dart';

import 'async_notifier.dart';

final counterStreamNotifierProvider =
    StreamNotifierProvider.family<CounterStreamNotifier, int, int>(CounterStreamNotifier.new);

class CounterStreamNotifier extends StreamNotifier<int> {
  CounterStreamNotifier(this.initialValue);

  final int initialValue;

  late final StreamController<int> _controller;

  @override
  Stream<int> build() {
    _controller = StreamController<int>();

    ref.onDispose(() {
      _controller.close();
    });

    _controller.add(initialValue);

    return _controller.stream;
  }

  void increment() {
    _controller.add(value + 1);
  }
}
