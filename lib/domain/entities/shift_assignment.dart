import 'employee.dart';
import 'shift_template.dart';

/// One employee assigned to one shift on a schedule day.
class ShiftAssignment {
  const ShiftAssignment({
    required this.id,
    required this.employee,
    required this.shift,
    this.location,
    this.remark,
    this.approved = true,
  });

  final String id;
  final Employee employee;
  final ShiftTemplate shift;
  final String? location;
  final String? remark;
  final bool approved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAssignment &&
          id == other.id &&
          employee == other.employee &&
          shift == other.shift &&
          location == other.location &&
          remark == other.remark &&
          approved == other.approved;

  @override
  int get hashCode =>
      Object.hash(id, employee, shift, location, remark, approved);
}
