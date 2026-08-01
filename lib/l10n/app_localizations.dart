import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Calendar Engine'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @roster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get roster;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @organizationManagement.
  ///
  /// In en, this message translates to:
  /// **'Organization management'**
  String get organizationManagement;

  /// No description provided for @organizationManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse organizations, branches, departments, and teams.'**
  String get organizationManagementDescription;

  /// No description provided for @organizationHierarchy.
  ///
  /// In en, this message translates to:
  /// **'Organization hierarchy'**
  String get organizationHierarchy;

  /// No description provided for @organizations.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get organizations;

  /// No description provided for @branches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branches;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @selectOrganization.
  ///
  /// In en, this message translates to:
  /// **'Select an organization to view its hierarchy.'**
  String get selectOrganization;

  /// No description provided for @noOrganizations.
  ///
  /// In en, this message translates to:
  /// **'No organizations yet'**
  String get noOrganizations;

  /// No description provided for @noBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches in this organization'**
  String get noBranches;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @nextShift.
  ///
  /// In en, this message translates to:
  /// **'Next shift'**
  String get nextShift;

  /// No description provided for @monthlyAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments this month'**
  String get monthlyAssignments;

  /// No description provided for @estimatedIncome.
  ///
  /// In en, this message translates to:
  /// **'Estimated income'**
  String get estimatedIncome;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get pendingRequests;

  /// No description provided for @calendarStatus.
  ///
  /// In en, this message translates to:
  /// **'Calendar status'**
  String get calendarStatus;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule data'**
  String get noSchedule;

  /// No description provided for @noScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Import or create a roster to begin.'**
  String get noScheduleDescription;

  /// No description provided for @createRoster.
  ///
  /// In en, this message translates to:
  /// **'Create roster'**
  String get createRoster;

  /// No description provided for @importRoster.
  ///
  /// In en, this message translates to:
  /// **'Import roster'**
  String get importRoster;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @monthOverview.
  ///
  /// In en, this message translates to:
  /// **'Month overview'**
  String get monthOverview;

  /// No description provided for @employeeDirectory.
  ///
  /// In en, this message translates to:
  /// **'Employee directory'**
  String get employeeDirectory;

  /// No description provided for @employeeDirectoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage people used by roster assignments.'**
  String get employeeDirectoryDescription;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get noEmployees;

  /// No description provided for @exchangeRequests.
  ///
  /// In en, this message translates to:
  /// **'Shift exchange requests'**
  String get exchangeRequests;

  /// No description provided for @exchangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Requests, approvals, and history will use the canonical roster.'**
  String get exchangeDescription;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No exchange requests'**
  String get noRequests;

  /// No description provided for @reportCenter.
  ///
  /// In en, this message translates to:
  /// **'Report center'**
  String get reportCenter;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Printable and exportable schedule reports.'**
  String get reportDescription;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No report data'**
  String get noReports;

  /// No description provided for @workspaceSettings.
  ///
  /// In en, this message translates to:
  /// **'Workspace settings'**
  String get workspaceSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @demoModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use deterministic sample data without external accounts.'**
  String get demoModeDescription;

  /// No description provided for @phaseStatus.
  ///
  /// In en, this message translates to:
  /// **'SCE 3.0 foundation'**
  String get phaseStatus;

  /// No description provided for @phaseStatusDescription.
  ///
  /// In en, this message translates to:
  /// **'Canonical roster, explicit dependencies, responsive navigation, localization, and tests are active.'**
  String get phaseStatusDescription;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployee;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee code'**
  String get employeeCode;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @departmentCode.
  ///
  /// In en, this message translates to:
  /// **'Department code'**
  String get departmentCode;

  /// No description provided for @departmentName.
  ///
  /// In en, this message translates to:
  /// **'Department name'**
  String get departmentName;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @shiftTemplates.
  ///
  /// In en, this message translates to:
  /// **'Shift templates'**
  String get shiftTemplates;

  /// No description provided for @shiftTemplatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure reusable shift codes, times, colors, hours, and rates.'**
  String get shiftTemplatesDescription;

  /// No description provided for @addShiftTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add shift template'**
  String get addShiftTemplate;

  /// No description provided for @editShiftTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit shift template'**
  String get editShiftTemplate;

  /// No description provided for @shiftCode.
  ///
  /// In en, this message translates to:
  /// **'Shift code'**
  String get shiftCode;

  /// No description provided for @shiftName.
  ///
  /// In en, this message translates to:
  /// **'Shift name'**
  String get shiftName;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @manualRosterEditor.
  ///
  /// In en, this message translates to:
  /// **'Manual roster editor'**
  String get manualRosterEditor;

  /// No description provided for @addAssignment.
  ///
  /// In en, this message translates to:
  /// **'Add assignment'**
  String get addAssignment;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @previewChanges.
  ///
  /// In en, this message translates to:
  /// **'Preview changes'**
  String get previewChanges;

  /// No description provided for @catalogRequired.
  ///
  /// In en, this message translates to:
  /// **'Add active employees and shift templates first.'**
  String get catalogRequired;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved.'**
  String get scheduleSaved;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the storage operation.'**
  String get storageError;

  /// No description provided for @reportMonth.
  ///
  /// In en, this message translates to:
  /// **'Report month'**
  String get reportMonth;

  /// No description provided for @allDepartments.
  ///
  /// In en, this message translates to:
  /// **'All departments'**
  String get allDepartments;

  /// No description provided for @previewReport.
  ///
  /// In en, this message translates to:
  /// **'Preview report'**
  String get previewReport;

  /// No description provided for @previewReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose report options, then generate an A4 preview.'**
  String get previewReportDescription;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printReport;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @reportGenerationError.
  ///
  /// In en, this message translates to:
  /// **'The PDF report could not be generated.'**
  String get reportGenerationError;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @googleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @googleDriveDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the roster source to load from Google Drive.'**
  String get googleDriveDescription;

  /// No description provided for @openGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get openGoogleDrive;

  /// No description provided for @recentlyModified.
  ///
  /// In en, this message translates to:
  /// **'Recently Modified'**
  String get recentlyModified;

  /// No description provided for @lastImported.
  ///
  /// In en, this message translates to:
  /// **'Last Imported'**
  String get lastImported;

  /// No description provided for @loadCurrentSource.
  ///
  /// In en, this message translates to:
  /// **'Load Current Source'**
  String get loadCurrentSource;

  /// No description provided for @noDriveRosterFiles.
  ///
  /// In en, this message translates to:
  /// **'No roster files have been loaded from Google Drive.'**
  String get noDriveRosterFiles;

  /// No description provided for @noLastImportedSource.
  ///
  /// In en, this message translates to:
  /// **'No source has been imported yet.'**
  String get noLastImportedSource;

  /// No description provided for @googleDriveNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google Drive is not configured. Add an OAuth-backed Drive gateway to connect an account.'**
  String get googleDriveNotConfigured;

  /// No description provided for @googleDriveLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Google Drive source.'**
  String get googleDriveLoadFailed;

  /// No description provided for @driveSourceLoaded.
  ///
  /// In en, this message translates to:
  /// **'The current source was loaded.'**
  String get driveSourceLoaded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
