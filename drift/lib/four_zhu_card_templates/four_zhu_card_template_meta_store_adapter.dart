import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'daos/card_template_meta_dao.dart';

class FourZhuCardTemplateMetaStoreAdapter
    implements FourZhuCardTemplateMetaStore {
  FourZhuCardTemplateMetaStoreAdapter(this._dao);

  final CardTemplateMetaDao _dao;

  @override
  Future<void> touchModifiedAt({
    required String templateUuid,
    required DateTime modifiedAt,
    bool? isCustomized,
  }) async {
    await _dao.touchModifiedAt(
      templateUuid: templateUuid,
      modifiedAt: modifiedAt,
      isCustomized: isCustomized,
    );
  }
}
