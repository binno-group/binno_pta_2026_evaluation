import 'package:binno_api/binno_api.dart' as api;
import 'package:binno_app/features/auth/data/datasources/generated_auth_remote_data_source.dart';
import 'package:binno_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:binno_app/features/auth/domain/auth_repository.dart';

export 'data/generated_token_refresh_api.dart' show GeneratedTokenRefreshApi;
export 'domain/auth_models.dart' show ActiveSession;
export 'presentation/controllers/auth_providers.dart'
    show authRepositoryProvider, authSessionProvider;
export 'presentation/screens/phone_screen.dart' show PhoneScreen;
export 'presentation/screens/sessions_screen.dart' show SessionsScreen;

AuthRepository createAuthRepository(api.AuthApi client) {
  return AuthRepositoryImpl(GeneratedAuthRemoteDataSource(client));
}
