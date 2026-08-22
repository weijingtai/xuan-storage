import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'models/layout_template.dart';
import 'layout_template_local_data_source.dart';

class LayoutTemplateRepositoryImpl implements LayoutTemplateRepository {
  LayoutTemplateRepositoryImpl(
    this._localDataSource, {
    required AuthScopeProvider authScopeProvider,
  }) : _authScopeProvider = authScopeProvider;

  final LayoutTemplateLocalDataSource _localDataSource;
  final AuthScopeProvider _authScopeProvider;

  static const _defaultModuleType = 'four_zhu';

  LayoutTemplateContract _toContract(LayoutTemplate t) {
    return LayoutTemplateContract(
      uuid: t.id,
      name: t.name,
      description: t.description,
      moduleType: _defaultModuleType,
      collectionId: t.collectionId,
      version: t.version,
      templateJson: jsonEncode(t.toJson()),
      format: 'json',
      createdAt: t.updatedAt,
      updatedAt: t.updatedAt,
    );
  }

  LayoutTemplate _toDomain(LayoutTemplateContract c) {
    final decoded = jsonDecode(c.templateJson) as Map<String, dynamic>;
    return LayoutTemplate.fromJson(decoded).copyWith(
      id: c.uuid,
      name: c.name,
      description: c.description ?? '',
      collectionId: c.collectionId,
      version: c.version,
      updatedAt: c.updatedAt,
    );
  }

  @override
  Future<LayoutTemplateContract?> get(String id) async {
    final allDtos = await _localDataSource.loadAllTemplates();
    final target = allDtos
        .map((dto) => dto.toDomain())
        .firstWhereOrNull((template) => template.id == id);
    return target == null ? null : _toContract(target);
  }

  @override
  Future<String> put(LayoutTemplateContract template) async {
    final domain = _toDomain(template);
    final collectionId = domain.collectionId;
    final existingDtos = await _localDataSource.loadTemplates(collectionId);
    final index = existingDtos.indexWhere(
      (dto) => dto.template.id == domain.id,
    );
    final originalVersion = index >= 0
        ? existingDtos[index].template.version
        : 0;
    final updatedTemplate = domain.copyWith(
      version: originalVersion + 1,
      updatedAt: DateTime.now(),
    );

    final scopeUid = await _authScopeProvider.getScopeUid();

    await _localDataSource.upsertTemplate(
      updatedTemplate,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
    return template.uuid;
  }

  @override
  Future<List<LayoutTemplateContract>> query([Map<String, Object?>? criteria]) async {
    final collectionId = criteria?['collectionId'] as String?;
    if (collectionId != null) {
      final dtos = await _localDataSource.loadTemplates(collectionId);
      return dtos.map((dto) => _toContract(dto.toDomain())).toList(growable: false);
    }
    final allDtos = await _localDataSource.loadAllTemplates();
    return allDtos.map((dto) => _toContract(dto.toDomain())).toList(growable: false);
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
