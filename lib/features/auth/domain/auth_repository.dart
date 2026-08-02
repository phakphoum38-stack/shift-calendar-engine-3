import '../../../core/result/result.dart';
import 'auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  });

  Future<Result<AuthUser>> currentUser();

  Future<Result<void>> logout();
}
