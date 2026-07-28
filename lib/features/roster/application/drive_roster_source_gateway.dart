import '../domain/drive_roster_source.dart';

abstract interface class DriveRosterSourceGateway {
  Future<List<DriveRosterSource>> listRecentlyModified();

  Future<DriveRosterSource?> loadLastImported();

  Future<void> loadSource(DriveRosterSource source);
}

/// Safe production default until an OAuth-backed Drive adapter is configured.
class UnconfiguredDriveRosterSourceGateway implements DriveRosterSourceGateway {
  const UnconfiguredDriveRosterSourceGateway();

  @override
  Future<List<DriveRosterSource>> listRecentlyModified() =>
      throw const DriveRosterSourceException('google_drive_not_configured');

  @override
  Future<DriveRosterSource?> loadLastImported() =>
      throw const DriveRosterSourceException('google_drive_not_configured');

  @override
  Future<void> loadSource(DriveRosterSource source) =>
      throw const DriveRosterSourceException('google_drive_not_configured');
}

class DriveRosterSourceException implements Exception {
  const DriveRosterSourceException(this.code);

  final String code;
}
