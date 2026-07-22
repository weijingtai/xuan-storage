import 'dart:convert';
import 'package:repository_interface_four_zhu_card/repository_interface_four_zhu_card.dart';

import 'daos/card_template_setting_dao.dart';
import 'models/card_template_setting_dto.dart';

class FourZhuCardTemplateSettingStoreAdapter
    implements FourZhuCardTemplateSettingStore {
  FourZhuCardTemplateSettingStoreAdapter(this._dao);

  final CardTemplateSettingDao _dao;

  @override
  Future<CardTemplateSettingContract?> findByTemplateUuid(
    String templateUuid,
  ) async {
    final dto = await _dao.findByTemplateUuid(templateUuid);
    if (dto == null) return null;
    return CardTemplateSettingContract(
      uuid: dto.templateUuid,
      templateUuid: dto.templateUuid,
      settingKey: 'default',
      settingValue: jsonEncode(dto.toJson()),
      createdAt: dto.createdAt,
    );
  }

  @override
  Future<void> upsert(CardTemplateSettingContract setting) async {
    CardTemplateSettingDto dto;
    try {
      final json = jsonDecode(setting.settingValue) as Map<String, dynamic>;
      dto = CardTemplateSettingDto.fromJson(json);
    } catch (_) {
      dto = CardTemplateSettingDto(
        templateUuid: setting.templateUuid,
        createdAt: setting.createdAt,
        modifiedAt: DateTime.now(),
      );
    }
    await _dao.upsert(dto);
  }

  @override
  Future<void> softDelete(String templateUuid) async {
    await _dao.softDelete(templateUuid: templateUuid);
  }
}
