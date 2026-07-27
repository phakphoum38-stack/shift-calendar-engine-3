/// Supported report languages independent from Flutter widget localization.
enum ReportLanguage { english, thai }

/// Immutable options for one monthly A4 roster report.
class MonthlyRosterReportOptions {
  const MonthlyRosterReportOptions({
    required this.month,
    required this.language,
    this.departmentId,
    this.includeSummary = true,
    this.includeLegend = true,
  });

  final DateTime month;
  final ReportLanguage language;
  final String? departmentId;
  final bool includeSummary;
  final bool includeLegend;

  MonthlyRosterReportOptions copyWith({
    DateTime? month,
    ReportLanguage? language,
    String? departmentId,
    bool clearDepartment = false,
    bool? includeSummary,
    bool? includeLegend,
  }) {
    return MonthlyRosterReportOptions(
      month: month ?? this.month,
      language: language ?? this.language,
      departmentId: clearDepartment ? null : departmentId ?? this.departmentId,
      includeSummary: includeSummary ?? this.includeSummary,
      includeLegend: includeLegend ?? this.includeLegend,
    );
  }
}

/// Localized labels passed into non-widget report infrastructure.
class ReportLabels {
  const ReportLabels({
    required this.title,
    required this.noData,
    required this.employee,
    required this.department,
    required this.summary,
    required this.totalEmployees,
    required this.totalAssignments,
    required this.legend,
    required this.notes,
    required this.preparedBy,
    required this.checkedBy,
    required this.approvedBy,
    required this.generatedAt,
    required this.holiday,
  });

  final String title;
  final String noData;
  final String employee;
  final String department;
  final String summary;
  final String totalEmployees;
  final String totalAssignments;
  final String legend;
  final String notes;
  final String preparedBy;
  final String checkedBy;
  final String approvedBy;
  final String generatedAt;
  final String holiday;

  /// English labels for PDF generation without a BuildContext dependency.
  static const english = ReportLabels(
    title: 'Monthly Staff Schedule',
    noData: 'No schedule data',
    employee: 'Employee',
    department: 'Department',
    summary: 'Summary',
    totalEmployees: 'Employees',
    totalAssignments: 'Assignments',
    legend: 'Shift legend',
    notes: 'Notes',
    preparedBy: 'Prepared by',
    checkedBy: 'Checked by',
    approvedBy: 'Approved by',
    generatedAt: 'Generated',
    holiday: 'Holiday',
  );

  /// Thai labels backed by the bundled Thai-capable report font.
  static const thai = ReportLabels(
    title: 'ตารางเวรบุคลากรประจำเดือน',
    noData: 'ไม่มีข้อมูลตารางเวร',
    employee: 'บุคลากร',
    department: 'หน่วยงาน',
    summary: 'สรุป',
    totalEmployees: 'จำนวนบุคลากร',
    totalAssignments: 'จำนวนเวร',
    legend: 'คำอธิบายเวร',
    notes: 'หมายเหตุ',
    preparedBy: 'ผู้จัดทำ',
    checkedBy: 'ผู้ตรวจสอบ',
    approvedBy: 'ผู้อนุมัติ',
    generatedAt: 'สร้างเมื่อ',
    holiday: 'วันหยุด',
  );
}

/// Prepared value for one date cell in an employee report row.
class MonthlyRosterCell {
  const MonthlyRosterCell({
    required this.date,
    required this.shiftCodes,
    required this.locations,
    required this.remarks,
    required this.isWeekend,
    required this.holidayName,
  });

  final DateTime date;
  final List<String> shiftCodes;
  final List<String> locations;
  final List<String> remarks;
  final bool isWeekend;
  final String? holidayName;

  String get displayValue => shiftCodes.join('/');
}

/// Prepared deterministic employee row for the monthly grid.
class MonthlyRosterRow {
  const MonthlyRosterRow({
    required this.employeeId,
    required this.employeeName,
    required this.departmentName,
    required this.position,
    required this.cells,
    required this.assignmentCount,
  });

  final String employeeId;
  final String employeeName;
  final String departmentName;
  final String position;
  final List<MonthlyRosterCell> cells;
  final int assignmentCount;
}

/// One stable legend entry for a canonical shift type.
class MonthlyRosterLegendEntry {
  const MonthlyRosterLegendEntry({
    required this.shiftId,
    required this.code,
    required this.name,
    required this.colorValue,
  });

  final String shiftId;
  final String code;
  final String name;
  final int colorValue;
}

/// Statistics calculated independently from PDF layout.
class MonthlyRosterStatistics {
  const MonthlyRosterStatistics({
    required this.employeeCount,
    required this.assignmentCount,
    required this.assignmentsByShift,
    required this.assignmentsByDepartment,
  });

  final int employeeCount;
  final int assignmentCount;
  final Map<String, int> assignmentsByShift;
  final Map<String, int> assignmentsByDepartment;
}

/// Complete renderer-ready model for one monthly A4 roster.
class MonthlyRosterReport {
  const MonthlyRosterReport({
    required this.scheduleName,
    required this.month,
    required this.departmentName,
    required this.dates,
    required this.rows,
    required this.legend,
    required this.statistics,
    required this.notes,
    required this.labels,
    required this.options,
  });

  final String scheduleName;
  final DateTime month;
  final String? departmentName;
  final List<DateTime> dates;
  final List<MonthlyRosterRow> rows;
  final List<MonthlyRosterLegendEntry> legend;
  final MonthlyRosterStatistics statistics;
  final List<String> notes;
  final ReportLabels labels;
  final MonthlyRosterReportOptions options;
}
