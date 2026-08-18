import 'package:binno_app/features/auth/domain/auth_models.dart';
import 'package:binno_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:binno_app/features/auth/presentation/controllers/sessions_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('loads, revokes, and logs out sessions after repository ack', () async {
    final repository = FakeAuthRepository()
      ..sessions = [
        ActiveSession(
          id: 'one',
          deviceLabel: 'Phone',
          createdAt: DateTime.utc(2026),
          lastUsedAt: DateTime.utc(2026, 1, 2),
          isCurrent: false,
        ),
        ActiveSession(
          id: 'current',
          deviceLabel: 'Current',
          createdAt: DateTime.utc(2026),
          lastUsedAt: DateTime.utc(2026, 1, 3),
          isCurrent: true,
        ),
      ];
    final controller = SessionsController(AuthUseCases(repository));

    await controller.load();
    expect(controller.state.value, hasLength(2));

    await controller.revoke('one');
    expect(controller.state.value?.single.id, 'current');

    await controller.logoutAll();
    expect(controller.state.value, isEmpty);
  });
}
