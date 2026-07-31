/// Filters and pagination used by the enterprise employee directory.
class EmployeeQuery {
  const EmployeeQuery({
    this.searchText = '',
    this.organizationId,
    this.branchId,
    this.departmentId,
    this.teamId,
    this.activeOnly = true,
    this.page = 1,
    this.pageSize = 25,
  }) : assert(page > 0),
       assert(pageSize > 0);

  static const Object _unset = Object();

  final String searchText;
  final String? organizationId;
  final String? branchId;
  final String? departmentId;
  final String? teamId;
  final bool activeOnly;
  final int page;
  final int pageSize;

  EmployeeQuery copyWith({
    String? searchText,
    Object? organizationId = _unset,
    Object? branchId = _unset,
    Object? departmentId = _unset,
    Object? teamId = _unset,
    bool? activeOnly,
    int? page,
    int? pageSize,
  }) {
    return EmployeeQuery(
      searchText: searchText ?? this.searchText,
      organizationId: identical(organizationId, _unset)
          ? this.organizationId
          : organizationId as String?,
      branchId: identical(branchId, _unset)
          ? this.branchId
          : branchId as String?,
      departmentId: identical(departmentId, _unset)
          ? this.departmentId
          : departmentId as String?,
      teamId: identical(teamId, _unset) ? this.teamId : teamId as String?,
      activeOnly: activeOnly ?? this.activeOnly,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  EmployeeQuery clearHierarchy({int page = 1}) {
    return copyWith(
      organizationId: null,
      branchId: null,
      departmentId: null,
      teamId: null,
      page: page,
    );
  }
}

/// One page of employee directory results.
class EmployeePage<T> {
  const EmployeePage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;

  int get totalPages => totalItems == 0 ? 0 : (totalItems / pageSize).ceil();
  bool get hasPreviousPage => page > 1;
  bool get hasNextPage => page < totalPages;
}
