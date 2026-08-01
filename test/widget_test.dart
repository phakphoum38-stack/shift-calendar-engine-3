import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_calendar_engine/app/app.dart';
import 'package:shift_calendar_engine/app/app_controller.dart';
import 'package:shift_calendar_engine/app/app_dependencies.dart';
import 'package:shift_calendar_engine/core/result/result.dart';
import 'package:shift_calendar_engine/domain/entities/app_settings.dart';
import 'package:shift_calendar_engine/features/auth/application/auth_controller.dart';
import 'package:shift_calendar_engine/features/auth/application/auth_state.dart';
import 'package:shift_calendar_engine/features/auth/domain/auth_repository.dart';
import 'package:shift_calendar_engine/features/auth/domain/auth_session.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/memory_schedule_repository.dart';
import 'package:shift_calendar_engine/features/foundation/infrastructure/memory_settings_repository.dart';

void main() {
  testWidgets('phone layout shows localized navigation', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authController = _authenticatedAuthController();
    addTearDown(authController.dispose);

    await tester.pumpWidget(
      ShiftCalendarEngineApp(
        authController: authController,
        dependencies: AppDependencies(
          settingsRepository: MemorySettingsRepository(
            initialSettings: const AppSettings(locale: LocalePreference.thai),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ภาพรวม'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('desktop layout uses navigation rail in English', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authController = _authenticatedAuthController();
    addTearDown(authController.dispose);

    await tester.pumpWidget(
      ShiftCalendarEngineApp(
        authController: authController,
        dependencies: AppDependencies(
          settingsRepository: MemorySettingsRepository(
            initialSettings: const AppSettings(
              locale: LocalePreference.english,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.assessment_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Report center'), findsOneWidget);
    expect(find.text('Preview report'), findsOneWidget);
  });

  testWidgets('settings can enable deterministic demo schedule', (
    tester,
  ) async {
    final scheduleRepository = MemoryScheduleRepository();
    final settingsRepository = MemorySettingsRepository(
      initialSettings: const AppSettings(locale: LocalePreference.english),
    );

    final controller = AppController(
      scheduleRepository: scheduleRepository,
      settingsRepository: settingsRepository,
    );

    final authController = _authenticatedAuthController();

    addTearDown(controller.dispose);
    addTearDown(authController.dispose);

    await tester.pumpWidget(
      ShiftCalendarEngineApp(
        controller: controller,
        authController: authController,
        dependencies: AppDependencies(
          scheduleRepository: scheduleRepository,
          settingsRepository: settingsRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.settings.demoMode, isTrue);
    expect(controller.schedule.assignments, hasLength(1));
  });
}

AuthController _authenticatedAuthController() {
  return AuthController(
    repository: const _FakeAuthRepository(),
    initialState: const AuthState(
      status: AuthStatus.authenticated,
      session: AuthSession(
        tokenType: 'Bearer',
        accessToken: 'test-token',
        abilities: <String>['*'],
        user: AuthUser(
          id: 'test-user',
          name: 'Test User',
          email: 'test@example.com',
        ),
      ),
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    return const Success<AuthSession>(
      AuthSession(
        tokenType: 'Bearer',
        accessToken: 'test-token',
        abilities: <String>['*'],
        user: AuthUser(
          id: 'test-user',
          name: 'Test User',
          email: 'test@example.com',
        ),
      ),
    );
  }

  @override
  Future<Result<AuthUser>> currentUser() async {
    return const Success<AuthUser>(
      AuthUser(id: 'test-user', name: 'Test User', email: 'test@example.com'),
    );
  }

  @override
  Future<Result<void>> logout() async {
    return const Success<void>(null);
  }
}
