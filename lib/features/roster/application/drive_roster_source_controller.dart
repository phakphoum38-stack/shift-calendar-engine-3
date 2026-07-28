import 'package:flutter/foundation.dart';

import '../domain/drive_roster_source.dart';
import 'drive_roster_source_gateway.dart';

class DriveRosterSourceController extends ChangeNotifier {
  DriveRosterSourceController({
    required this.gateway,
    this.selector = const DriveRosterSourceSelector(),
  });

  final DriveRosterSourceGateway gateway;
  final DriveRosterSourceSelector selector;

  List<DriveRosterSource> _recentSources = const [];
  DriveRosterSource? _lastImported;
  DriveRosterSource? _selectedSource;
  bool _loading = false;
  String? _errorCode;

  List<DriveRosterSource> get recentSources => _recentSources;
  DriveRosterSource? get lastImported => _lastImported;
  DriveRosterSource? get selectedSource => _selectedSource;
  bool get loading => _loading;
  String? get errorCode => _errorCode;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        gateway.listRecentlyModified(),
        gateway.loadLastImported(),
      ]);
      _recentSources = selector.selectMonthlySources(
        results[0] as List<DriveRosterSource>,
      );
      _lastImported = results[1] as DriveRosterSource?;
      if (_selectedSource != null &&
          !_recentSources.any((source) => source.id == _selectedSource!.id)) {
        _selectedSource = null;
      }
    } on DriveRosterSourceException catch (error) {
      _errorCode = error.code;
    } catch (_) {
      _errorCode = 'google_drive_load_failed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void select(DriveRosterSource? source) {
    if (identical(source, _selectedSource)) return;
    _selectedSource = source;
    _errorCode = null;
    notifyListeners();
  }

  Future<bool> loadCurrentSource() async {
    final source = _selectedSource;
    if (source == null || _loading) return false;
    _loading = true;
    _errorCode = null;
    notifyListeners();
    try {
      await gateway.loadSource(source);
      _lastImported = source;
      return true;
    } on DriveRosterSourceException catch (error) {
      _errorCode = error.code;
      return false;
    } catch (_) {
      _errorCode = 'google_drive_load_failed';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
