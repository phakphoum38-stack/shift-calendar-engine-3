import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this.repository,
    AuthState initialState = const AuthState(),
  }) : _state = initialState;

  final AuthRepository repository;

  AuthState _state;
  bool _disposed = false;
  int _requestVersion = 0;

  AuthState get state => _state;

  Future<void> initialize() async {
    if (_state.loading) {
      return;
    }

    final requestVersion = ++_requestVersion;

    _setState(_state.copyWith(loading: true, clearError: true));

    final result = await repository.currentUser();

    if (_disposed || requestVersion != _requestVersion) {
      return;
    }

    switch (result) {
      case Success<AuthUser>(value: final user):
        final existingSession = _state.session;

        _setState(
          AuthState(
            status: AuthStatus.authenticated,
            session: AuthSession(
              tokenType: existingSession?.tokenType ?? 'Bearer',
              accessToken: existingSession?.accessToken ?? '',
              abilities: existingSession?.abilities ?? const <String>[],
              user: user,
            ),
          ),
        );

      case NetworkFailure<AuthUser>(statusCode: 401):
        _setState(const AuthState(status: AuthStatus.unauthenticated));

      case Failure<AuthUser>():
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: result.message,
          ),
        );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    String deviceName = 'shift-calendar-engine',
  }) async {
    if (_state.loading) {
      return false;
    }

    final normalizedEmail = email.trim();

    final fieldErrors = <String, String>{};

    if (normalizedEmail.isEmpty) {
      fieldErrors['email'] = 'Email is required.';
    }

    if (password.isEmpty) {
      fieldErrors['password'] = 'Password is required.';
    }

    if (fieldErrors.isNotEmpty) {
      _setState(
        _state.copyWith(
          status: AuthStatus.unauthenticated,
          loading: false,
          errorMessage: 'Please complete the required fields.',
          fieldErrors: fieldErrors,
        ),
      );

      return false;
    }

    final requestVersion = ++_requestVersion;

    _setState(_state.copyWith(loading: true, clearError: true));

    final result = await repository.login(
      email: normalizedEmail,
      password: password,
      deviceName: deviceName,
    );

    if (_disposed || requestVersion != _requestVersion) {
      return false;
    }

    switch (result) {
      case Success<AuthSession>(value: final session):
        _setState(
          AuthState(status: AuthStatus.authenticated, session: session),
        );

        return true;

      case Failure<AuthSession>():
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: result.message,
            fieldErrors: result is ValidationFailure<AuthSession>
                ? result.fieldErrors
                : const <String, String>{},
          ),
        );

        return false;
    }
  }

  Future<void> logout() async {
    if (_state.loading) {
      return;
    }

    final requestVersion = ++_requestVersion;

    _setState(_state.copyWith(loading: true, clearError: true));

    final result = await repository.logout();

    if (_disposed || requestVersion != _requestVersion) {
      return;
    }

    switch (result) {
      case Success<void>():
        _setState(const AuthState(status: AuthStatus.unauthenticated));

      case Failure<void>():
        _setState(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: result.message,
          ),
        );
    }
  }

  void clearError() {
    if (!_state.hasError && _state.fieldErrors.isEmpty) {
      return;
    }

    _setState(_state.copyWith(clearError: true));
  }

  void _setState(AuthState value) {
    if (_disposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
