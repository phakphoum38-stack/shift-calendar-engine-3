import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'token_store.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository({
    required this._apiClient,
    required this._tokenStore,
  });

  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    try {
      final json = await _apiClient.post(
        '/api/v1/auth/login',
        authenticated: false,
        body: {
          'email': email.trim(),
          'password': password,
          'device_name': deviceName.trim(),
        },
      );

      final session = AuthSession.fromJson(json);

      if (session.accessToken.isEmpty) {
        return const NetworkFailure<AuthSession>(
          'The login response did not contain an access token.',
        );
      }

      await _tokenStore.write(session.accessToken);

      return Success(session);
    } on ApiException catch (error, stackTrace) {
      return NetworkFailure<AuthSession>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<AuthSession>(
        'Unable to sign in.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<AuthUser>> currentUser() async {
    try {
      final json = await _apiClient.get('/api/v1/auth/user');
      final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});

      return Success(AuthUser.fromJson(data));
    } on ApiException catch (error, stackTrace) {
      return NetworkFailure<AuthUser>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      return NetworkFailure<AuthUser>(
        'Unable to load the signed-in user.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout');
      await _tokenStore.clear();

      return const Success<void>(null);
    } on ApiException catch (error, stackTrace) {
      await _tokenStore.clear();

      return NetworkFailure<void>(
        error.message,
        statusCode: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      await _tokenStore.clear();

      return NetworkFailure<void>(
        'Unable to sign out.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
