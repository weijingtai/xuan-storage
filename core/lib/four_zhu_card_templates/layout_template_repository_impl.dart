import 'package:collection/collection.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:xuan_four_zhu_card/repositories/layout_template_repository.dart';

import '../models/layout_template.dart';

import 'layout_template_local_data_source.dart';

class LayoutTemplateRepositoryImpl implements LayoutTemplateRepository {
  LayoutTemplateRepositoryImpl(
    this._localDataSource, {
    required AuthScopeProvider authScopeProvider,
  }) : _authScopeProvider = authScopeProvider;

  final LayoutTemplateLocalDataSource _localDataSource;
  final AuthScopeProvider _authScopeProvider;

  @override
  Future<LayoutTemplate?> get(String id) async {
    final allDtos = await _localDataSource.loadAllTemplates();
    final target = allDtos
        .map((dto) => dto.toDomain())
        .firstWhereOrNull((template) => template.id == id);
    return target;
  }

  @override
  Future<String> put(LayoutTemplate template) async {
    final collectionId = template.collectionId;
    final existingDtos = await _localDataSource.loadTemplates(collectionId);
    final index = existingDtos.indexWhere(
      (dto) => dto.template.id == template.id,
    );
    final originalVersion = index >= 0
        ? existingDtos[index].template.version
        : 0;
    final updatedTemplate = template.copyWith(
      version: originalVersion + 1,
      updatedAt: DateTime.now(),
    );

    final scopeUid = await _authScopeProvider.getScopeUid();

    await _localDataSource.upsertTemplate(
      updatedTemplate,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
    return template.id;
  }

  @override
  Future<List<LayoutTemplate>> query([Map<String, Object?>? criteria]) async {
    final collectionId = criteria?['collectionId'] as String?;
    if (collectionId != null) {
      final dtos = await _localDataSource.loadTemplates(collectionId);
      return dtos.map((dto) => dto.toDomain()).toList(growable: false);
    }
    final allDtos = await _localDataSource.loadAllTemplates();
    return allDtos.map((dto) => dto.toDomain()).toList(growable: false);
  }

  @override
  Future<bool> delete(String id) async {
    final allDtos = await _localDataSource.loadAllTemplates();
    final target = allDtos.firstWhereOrNull((dto) => dto.template.id == id);
    if (target == null) return false;

    final scopeUid = await _authScopeProvider.getScopeUid();
    await _localDataSource.softDeleteTemplate(
      target.template.collectionId,
      id,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
    return true;
  }
}
