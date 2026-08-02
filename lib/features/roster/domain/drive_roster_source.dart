/// Metadata required to choose and display a roster source from Google Drive.
class DriveRosterSource {
  const DriveRosterSource({
    required this.id,
    required this.name,
    required this.modifiedTime,
    required this.rosterMonth,
  });

  final String id;
  final String name;
  final DateTime modifiedTime;
  final DateTime rosterMonth;
}

/// Keeps one deterministic source per month.
///
/// When Drive contains several files for the same month, the earliest modified
/// file is the canonical source. Results are ordered by most recently modified
/// first for the "Recently modified" section.
class DriveRosterSourceSelector {
  const DriveRosterSourceSelector();

  List<DriveRosterSource> selectMonthlySources(
    Iterable<DriveRosterSource> sources,
  ) {
    final byMonth = <({int year, int month}), DriveRosterSource>{};
    for (final source in sources) {
      final key = (
        year: source.rosterMonth.year,
        month: source.rosterMonth.month,
      );
      final current = byMonth[key];
      if (current == null ||
          source.modifiedTime.isBefore(current.modifiedTime) ||
          (source.modifiedTime.isAtSameMomentAs(current.modifiedTime) &&
              source.name.compareTo(current.name) < 0)) {
        byMonth[key] = source;
      }
    }

    return byMonth.values.toList()..sort((a, b) {
      final byModified = b.modifiedTime.compareTo(a.modifiedTime);
      return byModified != 0 ? byModified : a.name.compareTo(b.name);
    });
  }
}
