import '../../../domain/entities/employee.dart';
import 'employee_query.dart';

/// Immutable presentation state for the enterprise employee directory.
class EmployeeState {
  const EmployeeState({
    this.query = const EmployeeQuery(),
    this.items = const <Employee>[],
    this.totalItems = 0,
    this.totalPages = 0,
    this.loading = false,
    this.saving = false,
    this.errorMessage,
    this.fieldErrors = const <String, String>{},
  });

  final EmployeeQuery query;
  final List<Employee> items;
  final int totalItems;
  final int totalPages;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  bool get hasError => errorMessage != null;
  bool get isEmpty => !loading && items.isEmpty;
  bool get hasPreviousPage => query.page > 1;
  bool get hasNextPage => query.page < totalPages;

  EmployeeState copyWith({
    EmployeeQuery? query,
    List<Employee>? items,
    int? totalItems,
    int? totalPages,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
    Map<String, String>? fieldErrors,
  }) {
    return EmployeeState(
      query: query ?? this.query,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      fieldErrors: clearError
          ? const <String, String>{}
          : fieldErrors ?? this.fieldErrors,
    );
  }
}
