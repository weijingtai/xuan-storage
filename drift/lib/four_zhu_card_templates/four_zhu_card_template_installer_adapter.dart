import 'package:flutter/material.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'daos/market_template_installs_dao.dart';
import 'layout_template_local_data_source.dart';
import 'models/layout_template.dart';

class FourZhuCardTemplateInstallerAdapter
    implements FourZhuCardTemplateInstaller {
  FourZhuCardTemplateInstallerAdapter({
    required LayoutTemplateLocalDataSource localDataSource,
    required MarketTemplateInstallsDao installsDao,
    required AuthScopeProvider authScopeProvider,
  })  : _localDataSource = localDataSource,
        _installsDao = installsDao,
        _authScopeProvider = authScopeProvider;

  final LayoutTemplateLocalDataSource _localDataSource;
  final MarketTemplateInstallsDao _installsDao;
  final AuthScopeProvider _authScopeProvider;

  @override
  Future<LayoutTemplateContract> installTemplate({
    required String collectionId,
    required String marketTemplateId,
    required String marketVersionId,
    String? nameOverride,
  }) async {
    final now = DateTime.now();
    final template = LayoutTemplate(
      id: marketTemplateId,
      name: nameOverride ?? marketTemplateId,
      collectionId: collectionId,
      cardStyle: CardStyle(
        dividerType: BorderType.none,
        dividerColorHex: '#FF000000',
        dividerThickness: 1,
        globalFontFamily: 'System',
        globalFontSize: 14,
        globalFontColorHex: '#FF000000',
        contentPadding: const EdgeInsets.all(12),
      ),
      chartGroups: const [],
      rowConfigs: const [],
      updatedAt: now,
    );

    final scopeUid = await _authScopeProvider.getScopeUid();
    await _localDataSource.upsertTemplate(
      template,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );

    await _installsDao.upsertInstall(
      localTemplateUuid: marketTemplateId,
      marketTemplateId: marketTemplateId,
      marketVersionId: marketVersionId,
      installedAt: now,
      lastCheckedAt: now,
    );

    return LayoutTemplateContract(
      uuid: marketTemplateId,
      name: template.name,
      description: template.description,
      moduleType: 'four_zhu',
      collectionId: collectionId,
      version: 1,
      templateJson: '{}',
      format: 'json',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> uninstallTemplate(String templateUuid) async {
    final scopeUid = await _authScopeProvider.getScopeUid();
    await _localDataSource.softDeleteTemplate(
      'four_zhu_templates',
      templateUuid,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
    await _installsDao.softDeleteByLocalTemplateUuid(templateUuid);
  }
}
