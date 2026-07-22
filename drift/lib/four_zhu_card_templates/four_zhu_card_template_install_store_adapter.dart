import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'daos/market_template_installs_dao.dart';

class FourZhuCardTemplateInstallStoreAdapter
    implements FourZhuCardTemplateInstallStore {
  FourZhuCardTemplateInstallStoreAdapter(this._dao);

  final MarketTemplateInstallsDao _dao;

  @override
  Future<void> upsertInstall({
    required String localTemplateUuid,
    required String marketTemplateId,
    required String marketVersionId,
    required DateTime installedAt,
    required DateTime lastCheckedAt,
  }) async {
    await _dao.upsertInstall(
      localTemplateUuid: localTemplateUuid,
      marketTemplateId: marketTemplateId,
      marketVersionId: marketVersionId,
      installedAt: installedAt,
      lastCheckedAt: lastCheckedAt,
    );
  }

  @override
  Future<void> removeInstall(String localTemplateUuid) async {
    await _dao.softDeleteByLocalTemplateUuid(localTemplateUuid);
  }
}
