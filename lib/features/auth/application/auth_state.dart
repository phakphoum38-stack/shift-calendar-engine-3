import '../domain/auth_session.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.loading = false,
    this.errorMessage = '',
    this.fieldErrors = const <String, String>{},
  });

  final AuthStatus status;
  final AuthSession? session;
  final bool loading;
  final String errorMessage;
  final Map<String, String> fieldErrors;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;

  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  bool get hasError => errorMessage.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      loading: loading ?? this.loading,
      errorMessage: clearError ? '' : errorMessage ?? this.errorMessage,
      fieldErrors: clearError
          ? const <String, String>{}
          : fieldErrors ?? this.fieldErrors,
    );
  }
}
