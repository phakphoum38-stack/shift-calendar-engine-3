import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/entities/shift_template.dart';
import '../../../domain/repositories/shift_template_repository.dart';

/// Owns the persistent configurable shift-template catalog.
class ShiftTemplateController extends ChangeNotifier {
  ShiftTemplateController({required this.repository});

  final ShiftTemplateRepository repository;
  List<ShiftTemplate> _templates = const [];
  bool _loading = false;
  String? _error;

  List<ShiftTemplate> get templates => _templates;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    if (_loading) return;
    _setLoading();
    final result = await repository.findAll(activeOnly: false);
    switch (result) {
      case Success<List<ShiftTemplate>>(value: final values):
        if (values.isEmpty) {
          await _seedDefaults();
        } else {
          _templates = _ordered(values);
        }
      case Failure<List<ShiftTemplate>>():
        _error = result.message;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> save(ShiftTemplate template) async {
    _setLoading();
    final result = await repository.save(template);
    if (result case Success<ShiftTemplate>()) {
      final values = List<ShiftTemplate>.of(_templates);
      final index = values.indexWhere((value) => value.id == template.id);
      if (index == -1) {
        values.add(template);
      } else {
        values[index] = template;
      }
      _templates = _ordered(values);
    } else if (result case Failure<ShiftTemplate>()) {
      _error = result.message;
    }
    _loading = false;
    notifyListeners();
    return result.isSuccess;
  }

  Future<bool> deactivate(ShiftTemplate template) {
    return save(template.copyWith(active: false));
  }

  Future<void> _seedDefaults() async {
    final saved = <ShiftTemplate>[];
    for (final template in defaultShiftTemplates) {
      final result = await repository.save(template);
      if (result case Success<ShiftTemplate>(value: final value)) {
        saved.add(value);
      } else if (result case Failure<ShiftTemplate>()) {
        _error = result.message;
        break;
      }
    }
    _templates = _ordered(saved);
  }

  List<ShiftTemplate> _ordered(Iterable<ShiftTemplate> values) {
    final result = values.toList()..sort((a, b) => a.code.compareTo(b.code));
    return List.unmodifiable(result);
  }

  void _setLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }
}

/// Editable defaults seeded only when no shift templates exist.
const defaultShiftTemplates = [
  ShiftTemplate(
    id: 'morning',
    code: 'M',
    name: 'Morning',
    startTime: Duration(hours: 8),
    endTime: Duration(hours: 16),
    colorValue: 0xFF039BE5,
    workingHours: 8,
  ),
  ShiftTemplate(
    id: 'evening',
    code: 'E',
    name: 'Evening',
    startTime: Duration(hours: 16),
    endTime: Duration.zero,
    colorValue: 0xFFF6BF26,
    workingHours: 8,
  ),
  ShiftTemplate(
    id: 'night',
    code: 'N',
    name: 'Night',
    startTime: Duration.zero,
    endTime: Duration(hours: 8),
    colorValue: 0xFF7986CB,
    workingHours: 8,
  ),
];
