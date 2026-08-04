import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' show AuthClient;
import 'package:shared_preferences/shared_preferences.dart';

import '../application/drive_roster_source_gateway.dart';
import '../domain/drive_roster_source.dart';

/// Google Drive implementation used by the Flutter-only application.
///
/// The adapter reads roster source files directly from the signed-in user's
/// Drive. It never sends Google tokens or roster data to an application server.
class GoogleDriveRosterSourceGateway implements DriveRosterSourceGateway {
  GoogleDriveRosterSourceGateway({
    GoogleSignIn? googleSignIn,
    this.googleClientId = const String.fromEnvironment('GOOGLE_CLIENT_ID'),
    this.googleServerClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const List<String> _scopes = <String>[
    drive.DriveApi.driveReadonlyScope,
  ];

  static const String _lastImportedKey =
      'shift_calendar_engine.drive.last_imported';

  final GoogleSignIn _googleSignIn;
  final String googleClientId;
  final String googleServerClientId;

  Future<void>? _initialization;

  @override
  Future<List<DriveRosterSource>> listRecentlyModified() {
    return _withDrive((api) async {
      final sources = <DriveRosterSource>[];
      String? pageToken;

      do {
        final response = await api.files.list(
          q: _supportedFileQuery,
          orderBy: 'modifiedTime desc',
          pageSize: 100,
          pageToken: pageToken,
          spaces: 'drive',
          $fields:
              'nextPageToken,files(id,name,mimeType,modifiedTime,createdTime)',
        );

        for (final file in response.files ?? const <drive.File>[]) {
          final source = _mapFile(file);
          if (source != null) {
            sources.add(source);
          }
        }

        pageToken = response.nextPageToken;
      } while (pageToken != null && pageToken.isNotEmpty);

      return List<DriveRosterSource>.unmodifiable(sources);
    });
  }

  @override
  Future<DriveRosterSource?> loadLastImported() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_lastImportedKey);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final json = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return DriveRosterSource(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        modifiedTime: DateTime.parse(json['modifiedTime'].toString()),
        rosterMonth: DateTime.parse(json['rosterMonth'].toString()),
      );
    } on Object {
      await preferences.remove(_lastImportedKey);
      return null;
    }
  }

  @override
  Future<void> loadSource(DriveRosterSource source) async {
    if (source.id.trim().isEmpty) {
      throw const DriveRosterSourceException('google_drive_invalid_source');
    }

    await _withDrive((api) async {
      final metadata = await api.files.get(
        source.id,
        downloadOptions: drive.DownloadOptions.metadata,
        $fields: 'id,mimeType',
      );

      if (metadata is! drive.File) {
        throw const DriveRosterSourceException('google_drive_invalid_source');
      }

      final Object media;
      if (metadata.mimeType == 'application/vnd.google-apps.spreadsheet') {
        media = await api.files.export(
          source.id,
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      } else {
        media = await api.files.get(
          source.id,
          downloadOptions: drive.DownloadOptions.fullMedia,
        );
      }

      if (media is! drive.Media) {
        throw const DriveRosterSourceException('google_drive_download_failed');
      }

      await media.stream.fold<int>(0, (length, chunk) => length + chunk.length);
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastImportedKey,
      jsonEncode(<String, String>{
        'id': source.id,
        'name': source.name,
        'modifiedTime': source.modifiedTime.toIso8601String(),
        'rosterMonth': source.rosterMonth.toIso8601String(),
      }),
    );
  }

  Future<T> _withDrive<T>(Future<T> Function(drive.DriveApi api) action) async {
    if (!_isSupportedPlatform) {
      throw const DriveRosterSourceException(
        'google_drive_platform_unsupported',
      );
    }

    try {
      await (_initialization ??= _googleSignIn.initialize(
        clientId: googleClientId.trim().isEmpty ? null : googleClientId.trim(),
        serverClientId: googleServerClientId.trim().isEmpty
            ? null
            : googleServerClientId.trim(),
      ));

      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      final authorization =
          await account.authorizationClient.authorizationForScopes(_scopes) ??
          await account.authorizationClient.authorizeScopes(_scopes);
      final AuthClient client = authorization.authClient(scopes: _scopes);

      try {
        return await action(drive.DriveApi(client));
      } finally {
        client.close();
      }
    } on GoogleSignInException catch (error) {
      throw DriveRosterSourceException(
        error.code == GoogleSignInExceptionCode.canceled
            ? 'google_drive_sign_in_cancelled'
            : 'google_drive_sign_in_failed',
      );
    } on DriveRosterSourceException {
      rethrow;
    } on Object {
      throw const DriveRosterSourceException('google_drive_load_failed');
    }
  }

  DriveRosterSource? _mapFile(drive.File file) {
    final id = file.id?.trim() ?? '';
    final name = file.name?.trim() ?? '';
    final modifiedTime = file.modifiedTime ?? file.createdTime;

    if (id.isEmpty || name.isEmpty || modifiedTime == null) {
      return null;
    }

    return DriveRosterSource(
      id: id,
      name: name,
      modifiedTime: modifiedTime,
      rosterMonth: _rosterMonthFromName(name, modifiedTime),
    );
  }

  DateTime _rosterMonthFromName(String name, DateTime fallback) {
    final yearFirst = RegExp(
      r'(?<!\d)(25\d{2}|20\d{2})[-_ .](0?[1-9]|1[0-2])(?!\d)',
    ).firstMatch(name);
    if (yearFirst != null) {
      return _normalizedMonth(yearFirst.group(1)!, yearFirst.group(2)!);
    }

    final monthFirst = RegExp(
      r'(?<!\d)(0?[1-9]|1[0-2])[-_ .](25\d{2}|20\d{2})(?!\d)',
    ).firstMatch(name);
    if (monthFirst != null) {
      return _normalizedMonth(monthFirst.group(2)!, monthFirst.group(1)!);
    }

    return DateTime(fallback.year, fallback.month);
  }

  DateTime _normalizedMonth(String rawYear, String rawMonth) {
    var year = int.parse(rawYear);
    if (year >= 2400) {
      year -= 543;
    }
    return DateTime(year, int.parse(rawMonth));
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) {
      return true;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  String get _supportedFileQuery =>
      "trashed = false and ("
      "mimeType = 'application/vnd.google-apps.spreadsheet' or "
      "mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' or "
      "mimeType = 'text/csv' or "
      "mimeType = 'application/json')";
}
