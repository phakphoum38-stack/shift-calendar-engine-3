/// External source mapping used to identify an employee during imports.
class SourceProfile {
  const SourceProfile({
    this.sourceId = '',
    this.sheetName = '',
    this.rowKey = '',
    this.externalEmployeeId = '',
    this.googleAccountEmail = '',
  });

  final String sourceId;
  final String sheetName;
  final String rowKey;
  final String externalEmployeeId;
  final String googleAccountEmail;

  bool get isConfigured =>
      sourceId.trim().isNotEmpty ||
      rowKey.trim().isNotEmpty ||
      externalEmployeeId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceProfile &&
          sourceId == other.sourceId &&
          sheetName == other.sheetName &&
          rowKey == other.rowKey &&
          externalEmployeeId == other.externalEmployeeId &&
          googleAccountEmail == other.googleAccountEmail;

  @override
  int get hashCode => Object.hash(
    sourceId,
    sheetName,
    rowKey,
    externalEmployeeId,
    googleAccountEmail,
  );
}
