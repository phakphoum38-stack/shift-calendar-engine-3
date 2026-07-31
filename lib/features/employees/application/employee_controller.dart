import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/entities/employee.dart';
import 'employee_application_service.dart';
import 'employee_query.dart';
import 'employee_state.dart';

/// Coordinates employee directory presentation state with application services.
class EmployeeController extends ChangeNotifier {
  EmployeeController({
    required this.service,
    EmployeeState initialState = const EmployeeState(),
  }) : _state = initialState;

  final EmployeeApplicationService service;
  EmployeeState _state;
  bool _disposed = false;

  EmployeeState get state => _state;

  Future<void> load() async {
    if (_state.loading) return;
    _setState(_state.copyWith(loading: true, clearError: true));

    final result = await service.search(_state.query);
    switch (result) {
      case Success<EmployeePage<Employee>>(value: final page):
        _setState(
          _state.copyWith(
            items: List<Employee>.unmodifiable(page.items),
            totalItems: page.totalItems,
            totalPages: page.totalPages,
            loading: false,
            clearError: true,
          ),
        );
      case Failure<EmployeePage<Employee>>():
        _setState(
          _state.copyWith(
            loading: false,
            errorMessage: result.message,
            fieldErrors: result is ValidationFailure<EmployeePage<Employee>>
                ? result.fieldErrors
                : const <String, String>{},
          ),
        );
    }
  }

  Future<void> search(String value) {
    final normalized = value.trim();
    if (_state.query.searchText == normalized && _state.query.page == 1) {
      return Future<void>.value();
    }
    _replaceQuery(
      _state.query.copyWith(searchText: normalized, page: 1),
      notify: false,
    );
    return load();
  }

  Future<void> setActiveOnly(bool value) {
    if (_state.query.activeOnly == value) return Future<void>.value();
    _replaceQuery(_state.query.copyWith(activeOnly: value, page: 1), notify: false);
    return load();
  }

  Future<void> setOrganization(String? organizationId) {
    _replaceQuery(
      _queryWith(
        organizationId: organizationId,
        branchId: null,
        departmentId: null,
        teamId: null,
        page: 1,
      ),
      notify: false,
    );
    return load();
  }

  Future<void> setBranch(String? branchId) {
    _replaceQuery(
      _queryWith(
        branchId: branchId,
        departmentId: null,
        teamId: null,
        page: 1,
      ),
      notify: false,
    );
    return load();
  }

  Future<void> setDepartment(String? departmentId) {
    _replaceQuery(
      _queryWith(departmentId: departmentId, teamId: null, page: 1),
      notify: false,
    );
    return load();
  }

  Future<void> setTeam(String? teamId) {
    _replaceQuery(_queryWith(teamId: teamId, page: 1), notify: false);
    return load();
  }

  Future<void> setPageSize(int pageSize) {
    if (pageSize <= 0 || _state.query.pageSize == pageSize) {
      return Future<void>.value();
    }
    _replaceQuery(
      _state.query.copyWith(pageSize: pageSize, page: 1),
      notify: false,
    );
    return load();
  }

  Future<void> goToPage(int page) {
    final maximum = _state.totalPages == 0 ? 1 : _state.totalPages;
    final target = page.clamp(1, maximum);
    if (_state.query.page == target) return Future<void>.value();
    _replaceQuery(_state.query.copyWith(page: target), notify: false);
    return load();
  }

  Future<void> nextPage() => goToPage(_state.query.page + 1);

  Future<void> previousPage() => goToPage(_state.query.page - 1);

  Future<bool> save(Employee employee) async {
    if (_state.saving) return false;
    _setState(_state.copyWith(saving: true, clearError: true));

    final result = await service.save(employee);
    switch (result) {
      case Success<Employee>():
        _setState(_state.copyWith(saving: false, clearError: true));
        await load();
        return true;
      case Failure<Employee>():
        _setState(
          _state.copyWith(
            saving: false,
            errorMessage: result.message,
            fieldErrors: result is ValidationFailure<Employee>
                ? result.fieldErrors
                : const <String, String>{},
          ),
        );
        return false;
    }
  }

  Future<bool> deactivate(Employee employee) {
    return save(employee.copyWith(active: false));
  }

  Future<bool> delete(String employeeId) async {
    if (_state.saving) return false;
    _setState(_state.copyWith(saving: true, clearError: true));

    final result = await service.delete(employeeId);
    switch (result) {
      case Success<void>():
        _setState(_state.copyWith(saving: false, clearError: true));
        await load();
        return true;
      case Failure<void>():
        _setState(
          _state.copyWith(
            saving: false,
            errorMessage: result.message,
            fieldErrors: result is ValidationFailure<void>
                ? result.fieldErrors
                : const <String, String>{},
          ),
        );
        return false;
    }
  }

  void clearError() {
    if (!_state.hasError && _state.fieldErrors.isEmpty) return;
    _setState(_state.copyWith(clearError: true));
  }

  EmployeeQuery _queryWith({
    String? organizationId,
    String? branchId,
    String? departmentId,
    String? teamId,
    int? page,
  }) {
    final current = _state.query;
    return EmployeeQuery(
      searchText: current.searchText,
      organizationId: organizationId ?? current.organizationId,
      branchId: branchId ?? current.branchId,
      departmentId: departmentId ?? current.departmentId,
      teamId: teamId ?? current.teamId,
      activeOnly: current.activeOnly,
      page: page ?? current.page,
      pageSize: current.pageSize,
    );
  }

  void _replaceQuery(EmployeeQuery query, {bool notify = true}) {
    _state = _state.copyWith(query: query, clearError: true);
    if (notify) notifyListeners();
  }

  void _setState(EmployeeState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
