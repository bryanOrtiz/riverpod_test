// ignore_for_file: invalid_use_of_protected_member

import 'package:riverpod/riverpod.dart';

extension AsyncNotifierIntValueExtension on AsyncNotifier<int> {
  int get value => state.hasValue ? state.value! : 0;
}

extension StreamNotifierIntValueExtension on StreamNotifier<int> {
  int get value => state.hasValue ? state.value! : 0;
}
