import 'package:flutter/foundation.dart';

import '../../../domain/entities/shift_template.dart';
import '../application/ai_scheduler_request_factory.dart';

/// Owns the explicit shift slots requested by the user before generation.
///
/// This controller does not inspect existing roster assignments and does not
/// make scheduling decisions. It only maintains deterministic request input.
final class AiSchedulerShiftInputController extends ChangeNotifier {
  final List<AiSchedulerShiftInput> _inputs = [];

  List<AiSchedulerShiftInput> get inputs => List.unmodifiable(_inputs);

  bool get isEmpty => _inputs.isEmpty;

  AiSchedulerShiftInput add({
    required DateTime date,
    required ShiftTemplate shift,
    String departmentId = '',
    String location = '',
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final input = AiSchedulerShiftInput(
      id: _nextId(normalizedDate, shift.id),
      date: normalizedDate,
      shift: shift,
      departmentId: departmentId.trim(),
      location: location.trim(),
    );

    _inputs.add(input);
    _sort();
    notifyListeners();
    return input;
  }

  bool remove(String id) {
    final index = _inputs.indexWhere((input) => input.id == id);
    if (index < 0) {
      return false;
    }

    _inputs.removeAt(index);
    notifyListeners();
    return true;
  }

  void clear() {
    if (_inputs.isEmpty) {
      return;
    }

    _inputs.clear();
    notifyListeners();
  }

  String _nextId(DateTime date, String shiftId) {
    final base = '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}-${shiftId.trim()}';
    var candidate = base;
    var sequence = 2;

    while (_inputs.any((input) => input.id == candidate)) {
      candidate = '$base-$sequence';
      sequence += 1;
    }
    return candidate;
  }

  void _sort() {
    _inputs.sort((left, right) {
      final dateOrder = left.date.compareTo(right.date);
      if (dateOrder != 0) {
        return dateOrder;
      }

      final startOrder = left.shift.startTime.compareTo(right.shift.startTime);
      if (startOrder != 0) {
        return startOrder;
      }

      return left.id.compareTo(right.id);
    });
  }
}
