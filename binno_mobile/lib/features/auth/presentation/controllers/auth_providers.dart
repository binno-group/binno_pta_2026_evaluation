import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/auth_repository.dart';
import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:binno_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:binno_app/features/auth/presentation/controllers/sessions_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw StateError('AuthRepository override is required'),
);

final authSessionProvider = Provider<AuthSession>(
  (ref) => throw StateError('AuthSession override is required'),
);

final authUseCasesProvider = Provider<AuthUseCases>(
  (ref) => AuthUseCases(ref.watch(authRepositoryProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authUseCasesProvider),
    ref.watch(authSessionProvider),
  );
});

final sessionsControllerProvider =
    StateNotifierProvider<SessionsController, AsyncValue<List<ActiveSession>>>(
        (ref) {
  return SessionsController(ref.watch(authUseCasesProvider));
});
