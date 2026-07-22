import 'package:persistence_core/model/ports.dart';
import 'package:xuan_four_zhu_card/features/four_zhu_editor/four_zhu_editor_dependencies.dart';

import 'daos/card_template_meta_dao.dart';
import 'daos/card_template_setting_dao.dart';
import 'daos/card_template_skill_usage_dao.dart';
import 'daos/market_template_installs_dao.dart';
import 'four_zhu_card_template_installer_adapter.dart';
import 'four_zhu_card_template_install_store_adapter.dart';
import 'four_zhu_card_template_meta_store_adapter.dart';
import 'four_zhu_card_template_repository_adapter.dart';
import 'four_zhu_card_template_setting_store_adapter.dart';
import 'four_zhu_card_template_usage_recorder_adapter.dart';
import 'layout_template_local_data_source.dart';

class FourZhuEditorDependenciesFactory {
  static FourZhuEditorDependencies create({
    required LayoutTemplateLocalDataSource localDataSource,
    required MarketTemplateInstallsDao installsDao,
    required CardTemplateMetaDao metaDao,
    required CardTemplateSettingDao settingDao,
    required CardTemplateSkillUsageDao usageDao,
    required AuthScopeProvider authScopeProvider,
  }) {
    return FourZhuEditorDependencies(
      templateRepository: FourZhuCardTemplateRepositoryAdapter(
        localDataSource,
        authScopeProvider: authScopeProvider,
      ),
      templateInstaller: FourZhuCardTemplateInstallerAdapter(
        localDataSource: localDataSource,
        installsDao: installsDao,
        authScopeProvider: authScopeProvider,
      ),
      installStore: FourZhuCardTemplateInstallStoreAdapter(installsDao),
      metaStore: FourZhuCardTemplateMetaStoreAdapter(metaDao),
      settingStore: FourZhuCardTemplateSettingStoreAdapter(settingDao),
      usageRecorder: FourZhuCardTemplateUsageRecorderAdapter(usageDao),
      authScopeProvider: authScopeProvider,
    );
  }
}
