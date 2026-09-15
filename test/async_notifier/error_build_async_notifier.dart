import 'dart:async';
import 'package:riverpod/riverpod.dart';

final errorBuildAsyncNotifierProvider =
    AsyncNotifierProvider<ErrorBuildAsyncNotifier, int>(
        ErrorBuildAsyncNotifier.new);

class ErrorBuildAsyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => throw ErrorBuildAsyncNotifierError();
}

class ErrorBuildAsyncNotifierError extends Error {}
