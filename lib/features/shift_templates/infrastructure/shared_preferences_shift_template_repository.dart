import '../../../core/result/result.dart';
import '../../../core/storage/atomic_string_store.dart';
import '../../../domain/entities/shift_template.dart';
import '../../../domain/repositories/shift_template_repository.dart';
import '../../foundation/infrastructure/canonical_json_codec.dart';

/// Atomic production repository for configurable shift templates.
class SharedPreferencesShiftTemplateRepository
    implements ShiftTemplateRepository {
  SharedPreferencesShiftTemplateRepository({
    AtomicStringStore? store,
    this.codec = const CanonicalJsonCodec(),
  }) : store = store ?? AtomicStringStore(keyPrefix: 'sce3.shift_templates.v1');

  final AtomicStringStore store;
  final CanonicalJsonCodec codec;

  @override
  Future<Result<void>> delete(String id) async {
    final loaded = await _load();
    if (loaded case Failure<List<ShiftTemplate>>()) {
      return PersistenceFailure(loaded.message, cause: loaded);
    }
    final values = (loaded as Success<List<ShiftTemplate>>).value
        .where((shift) => shift.id != id)
        .toList();
    final saved = await _saveAll(values);
    return switch (saved) {
      Success<List<ShiftTemplate>>() => const Success(null),
      Failure<List<ShiftTemplate>>() => PersistenceFailure(
        saved.message,
        cause: saved,
      ),
    };
  }

  @override
  Future<Result<List<ShiftTemplate>>> findAll({bool activeOnly = true}) async {
    final loaded = await _load();
    return switch (loaded) {
      Success<List<ShiftTemplate>>(value: final values) => Success(
        List.unmodifiable(values.where((shift) => !activeOnly || shift.active)),
      ),
      Failure<List<ShiftTemplate>>() => loaded,
    };
  }

  @override
  Future<Result<ShiftTemplate>> save(ShiftTemplate template) async {
    if (template.id.trim().isEmpty ||
        template.code.trim().isEmpty ||
        template.name.trim().isEmpty) {
      return const ValidationFailure('Shift template data is incomplete.');
    }
    final loaded = await _load();
    if (loaded case Failure<List<ShiftTemplate>>()) {
      return PersistenceFailure(loaded.message, cause: loaded);
    }
    final values = List<ShiftTemplate>.of(
      (loaded as Success<List<ShiftTemplate>>).value,
    );
    if (values.any(
      (value) =>
          value.id != template.id &&
          value.code.toLowerCase() == template.code.toLowerCase(),
    )) {
      return const ValidationFailure(
        'Shift code is already in use.',
        fieldErrors: {'code': 'duplicate'},
      );
    }
    final index = values.indexWhere((value) => value.id == template.id);
    if (index == -1) {
      values.add(template);
    } else {
      values[index] = template;
    }
    final saved = await _saveAll(values);
    return switch (saved) {
      Success<List<ShiftTemplate>>() => Success(template),
      Failure<List<ShiftTemplate>>() => PersistenceFailure(
        saved.message,
        cause: saved,
      ),
    };
  }

  Future<Result<List<ShiftTemplate>>> _load() async {
    try {
      final payload = await store.read();
      return Success(payload == null ? const [] : codec.decodeShifts(payload));
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not load shift templates.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Result<List<ShiftTemplate>>> _saveAll(
    List<ShiftTemplate> values,
  ) async {
    try {
      await store.write(codec.encodeShifts(values));
      return Success(List.unmodifiable(values));
    } on Object catch (error, stackTrace) {
      return PersistenceFailure(
        'Could not save shift templates.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
