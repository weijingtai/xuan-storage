import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:flutter_test/flutter_test.dart';

MeiHuaDivinationRecordContract _rec() => MeiHuaDivinationRecordContract(
      uuid: 'a', divinationUuid: 'd1', question: '出行?',
      originalUpperGua: 1, originalLowerGua: 2, changingYao: 3,
      changedUpperGua: 4, changedLowerGua: 5, huUpperGua: 6, huLowerGua: 7,
      method: 'time', paramsJson: '{}',
      createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

void main() {
  final a = MeihuaRecordAdapter(scopeUid: 's1');

  test('toRecord then fromRecord round-trips the contract', () {
    final r = a.toRecord(_rec());
    final back = a.fromRecord(r.meta, r.moduleData) as MeiHuaDivinationRecordContract;
    expect(back, equals(_rec()));
    expect(r.meta.module, 'meihua');
    expect(r.meta.divinationType, 'mei_hua');
    expect(r.meta.category, 'divination');
  });

  test('extractSearchTags emits gua + divination_uuid', () {
    final r = a.toRecord(_rec());
    final tags = a.extractSearchTags(r.meta, r.moduleData);
    expect(tags, contains(const SearchTag('upper_gua', '1')));
    expect(tags, contains(const SearchTag('divination_uuid', 'd1')));
  });
}
