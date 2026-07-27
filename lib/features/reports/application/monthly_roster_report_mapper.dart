import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/shift_assignment.dart';
import '../domain/monthly_roster_report.dart';

/// Maps the canonical schedule into deterministic renderer-ready report data.
class MonthlyRosterReportMapper {
  const MonthlyRosterReportMapper();

  MonthlyRosterReport map(
    Schedule schedule,
    MonthlyRosterReportOptions options,
  ) {
    final month = schedule.month(options.month);
    final assignmentsByEmployee = <String, List<_DatedAssignment>>{};
    final holidayByDate = <DateTime, String?>{};
    final notes = <String>{};

    for (final day in month?.days ?? const []) {
      final date = _dateOnly(day.date);
      holidayByDate[date] = day.holidayName;
      for (final assignment in day.assignments) {
        if (options.departmentId != null &&
            assignment.employee.department.id != options.departmentId) {
          continue;
        }
        assignmentsByEmployee
            .putIfAbsent(assignment.employee.id, () => [])
            .add(_DatedAssignment(date, assignment));
        final remark = assignment.remark?.trim();
        if (remark != null && remark.isNotEmpty) notes.add(remark);
      }
    }

    final dates = _monthDates(options.month);
    final rows =
        [
          for (final entries in assignmentsByEmployee.values)
            _row(entries, dates, holidayByDate),
        ]..sort((a, b) {
          final department = a.departmentName.compareTo(b.departmentName);
          if (department != 0) return department;
          final name = a.employeeName.compareTo(b.employeeName);
          return name != 0 ? name : a.employeeId.compareTo(b.employeeId);
        });

    final assignments = assignmentsByEmployee.values
        .expand((value) => value)
        .map((value) => value.assignment)
        .toList(growable: false);
    final legendById = {
      for (final assignment in assignments)
        assignment.shift.id: MonthlyRosterLegendEntry(
          shiftId: assignment.shift.id,
          code: assignment.shift.code,
          name: assignment.shift.name,
          colorValue: assignment.shift.colorValue,
        ),
    };
    final legend = legendById.values.toList()
      ..sort((a, b) {
        final code = a.code.compareTo(b.code);
        return code != 0 ? code : a.shiftId.compareTo(b.shiftId);
      });

    final departmentName = options.departmentId == null || rows.isEmpty
        ? null
        : rows.first.departmentName;
    return MonthlyRosterReport(
      scheduleName: schedule.name,
      month: DateTime(options.month.year, options.month.month),
      departmentName: departmentName,
      dates: List.unmodifiable(dates),
      rows: List.unmodifiable(rows),
      legend: List.unmodifiable(legend),
      statistics: _statistics(rows, assignments),
      notes: List.unmodifiable(notes.toList()..sort()),
      labels: options.language == ReportLanguage.thai
          ? ReportLabels.thai
          : ReportLabels.english,
      options: options,
    );
  }

  MonthlyRosterRow _row(
    List<_DatedAssignment> entries,
    List<DateTime> dates,
    Map<DateTime, String?> holidayByDate,
  ) {
    final employee = entries.first.assignment.employee;
    final byDate = <DateTime, List<ShiftAssignment>>{};
    for (final entry in entries) {
      byDate.putIfAbsent(entry.date, () => []).add(entry.assignment);
    }
    return MonthlyRosterRow(
      employeeId: employee.id,
      employeeName: employee.displayName,
      departmentName: employee.department.name,
      position: employee.position,
      cells: [
        for (final date in dates)
          _cell(date, byDate[date] ?? const [], holidayByDate[date]),
      ],
      assignmentCount: entries.length,
    );
  }

  MonthlyRosterCell _cell(
    DateTime date,
    List<ShiftAssignment> assignments,
    String? holidayName,
  ) {
    final ordered = List<ShiftAssignment>.of(assignments)
      ..sort((a, b) {
        final code = a.shift.code.compareTo(b.shift.code);
        return code != 0 ? code : a.id.compareTo(b.id);
      });
    return MonthlyRosterCell(
      date: date,
      shiftCodes: List.unmodifiable(ordered.map((value) => value.shift.code)),
      locations: List.unmodifiable(
        ordered
            .map((value) => value.location?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toSet(),
      ),
      remarks: List.unmodifiable(
        ordered
            .map((value) => value.remark?.trim())
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toSet(),
      ),
      isWeekend:
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
      holidayName: holidayName,
    );
  }

  MonthlyRosterStatistics _statistics(
    List<MonthlyRosterRow> rows,
    List<ShiftAssignment> assignments,
  ) {
    final byShift = <String, int>{};
    final byDepartment = <String, int>{};
    for (final assignment in assignments) {
      byShift.update(
        assignment.shift.code,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      byDepartment.update(
        assignment.employee.department.name,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return MonthlyRosterStatistics(
      employeeCount: rows.length,
      assignmentCount: assignments.length,
      assignmentsByShift: Map.unmodifiable(_sortedMap(byShift)),
      assignmentsByDepartment: Map.unmodifiable(_sortedMap(byDepartment)),
    );
  }

  Map<String, int> _sortedMap(Map<String, int> source) {
    final keys = source.keys.toList()..sort();
    return {for (final key in keys) key: source[key]!};
  }

  List<DateTime> _monthDates(DateTime month) {
    final count = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var day = 1; day <= count; day++)
        DateTime(month.year, month.month, day),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _DatedAssignment {
  const _DatedAssignment(this.date, this.assignment);

  final DateTime date;
  final ShiftAssignment assignment;
}
