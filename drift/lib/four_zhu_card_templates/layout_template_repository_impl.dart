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
  Future<List<LayoutTemplateContract>> getAllTemplates(
    String collectionId,
  ) async {
    final dtos = await _localDataSource.loadTemplates(collectionId);
    return dtos.map((dto) => _toContract(dto.toDomain())).toList(
      growable: false,
    );
  }

  @override
  Future<LayoutTemplateContract?> getTemplateById(
    String collectionId,
    String templateId,
  ) async {
    final dtos = await _localDataSource.loadTemplates(collectionId);
    final target = dtos
        .map((dto) => dto.toDomain())
        .firstWhereOrNull((template) => template.id == templateId);
    return target == null ? null : _toContract(target);
  }

  @override
  Future<void> saveTemplate(LayoutTemplateContract template) async {
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
  }

  @override
  Future<void> deleteTemplate(String collectionId, String templateId) async {
    final scopeUid = await _authScopeProvider.getScopeUid();
    await _localDataSource.softDeleteTemplate(
      collectionId,
      templateId,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
  }
}
