import 'package:binno_api/binno_api.dart';
import 'package:binno_app/app/binno_app.dart';
import 'package:binno_app/app/flavors/app_flavor.dart';
import 'package:binno_app/app/router/app_router.dart';
import 'package:binno_app/core/api/binno_interceptor.dart';
import 'package:binno_app/core/api/dio_factory.dart';
import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/core/auth_session/session_storage.dart';
import 'package:binno_app/features/auth/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void bootstrap(AppEnvironment environment) {
  WidgetsFlutterBinding.ensureInitialized();
  const secureStorage = FlutterSecureStorage();
  const sessionStorage = SecureSessionStorage(secureStorage);
  final session = AuthSession(sessionStorage);
  final refreshClient = BinnoApi(
    dio: DioFactory.createBare(environment.apiBaseUrl),
  );
  final interceptor = BinnoInterceptor(
    session: session,
    storage: sessionStorage,
    refreshApi: GeneratedTokenRefreshApi(refreshClient.getAuthApi()),
  );
  final dio = DioFactory.create(
    baseUrl: environment.apiBaseUrl,
    interceptor: interceptor,
  );
  final generatedClient = BinnoApi(dio: dio);
  final router = createRouter(session);
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          createAuthRepository(generatedClient.getAuthApi()),
        ),
        authSessionProvider.overrideWithValue(session),
      ],
      child: BinnoApp(router: router),
    ),
  );
}
