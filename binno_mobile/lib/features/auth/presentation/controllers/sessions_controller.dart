import 'dart:async';

import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SessionsController
    extends StateNotifier<AsyncValue<List<ActiveSession>>> {
  SessionsController(this._useCases) : super(const AsyncValue.loading()) {
    unawaited(load());
  }

  final AuthUseCases _useCases;
  bool _mutationInFlight = false;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_useCases.getSessions);
  }

  Future<void> revoke(String id) async {
    if (_mutationInFlight) return;
    _mutationInFlight = true;
    try {
      await _useCases.revokeSession(id);
      await load();
    } finally {
      _mutationInFlight = false;
    }
  }

  Future<void> logoutAll() async {
    if (_mutationInFlight) return;
    _mutationInFlight = true;
    try {
      await _useCases.logoutAll();
      state = const AsyncValue.data([]);
    } finally {
      _mutationInFlight = false;
    }
  }
}
