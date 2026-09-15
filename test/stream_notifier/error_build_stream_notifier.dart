import 'dart:async';
import 'package:riverpod/riverpod.dart';

final errorBuildStreamNotifierProvider =
    StreamNotifierProvider<ErrorBuildStreamNotifier, int>(
        ErrorBuildStreamNotifier.new);

class ErrorBuildStreamNotifier extends StreamNotifier<int> {
  @override
  Stream<int> build() => throw ErrorBuildStreamNotifierError();
}

class ErrorBuildStreamNotifierError extends Error {}
