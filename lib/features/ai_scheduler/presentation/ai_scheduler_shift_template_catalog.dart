import '../../../domain/entities/shift_template.dart';

/// Produces the deterministic active shift-template view used by AI Scheduler.
///
/// The catalog never creates or mutates templates. Persistence and default
/// seeding remain owned by the canonical shift-template feature.
final class AiSchedulerShiftTemplateCatalog {
  const AiSchedulerShiftTemplateCatalog._();

  static List<ShiftTemplate> active(
    Iterable<ShiftTemplate> templates,
  ) {
    final values = templates.where((template) => template.active).toList()
      ..sort(_compare);
    return List.unmodifiable(values);
  }

  static int _compare(ShiftTemplate left, ShiftTemplate right) {
    final startOrder = left.startTime.compareTo(right.startTime);
    if (startOrder != 0) {
      return startOrder;
    }

    final codeOrder = left.code.compareTo(right.code);
    if (codeOrder != 0) {
      return codeOrder;
    }

    return left.id.compareTo(right.id);
  }
}
