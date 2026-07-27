// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shift Calendar Engine';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get roster => 'Roster';

  @override
  String get employees => 'Employees';

  @override
  String get exchange => 'Exchange';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get nextShift => 'Next shift';

  @override
  String get monthlyAssignments => 'Assignments this month';

  @override
  String get estimatedIncome => 'Estimated income';

  @override
  String get pendingRequests => 'Pending requests';

  @override
  String get calendarStatus => 'Calendar status';

  @override
  String get notConnected => 'Not connected';

  @override
  String get noSchedule => 'No schedule data';

  @override
  String get noScheduleDescription => 'Import or create a roster to begin.';

  @override
  String get createRoster => 'Create roster';

  @override
  String get importRoster => 'Import roster';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get monthOverview => 'Month overview';

  @override
  String get employeeDirectory => 'Employee directory';

  @override
  String get employeeDirectoryDescription =>
      'Manage people used by roster assignments.';

  @override
  String get noEmployees => 'No employees yet';

  @override
  String get exchangeRequests => 'Shift exchange requests';

  @override
  String get exchangeDescription =>
      'Requests, approvals, and history will use the canonical roster.';

  @override
  String get noRequests => 'No exchange requests';

  @override
  String get reportCenter => 'Report center';

  @override
  String get reportDescription => 'Printable and exportable schedule reports.';

  @override
  String get noReports => 'No report data';

  @override
  String get workspaceSettings => 'Workspace settings';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow system';

  @override
  String get english => 'English';

  @override
  String get thai => 'Thai';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get demoMode => 'Demo mode';

  @override
  String get demoModeDescription =>
      'Use deterministic sample data without external accounts.';

  @override
  String get phaseStatus => 'SCE 3.0 foundation';

  @override
  String get phaseStatusDescription =>
      'Canonical roster, explicit dependencies, responsive navigation, localization, and tests are active.';
}
