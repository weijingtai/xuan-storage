import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/tiebanshenshu/tieban_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

TiebanDivinationRecordContract _rec({String uuid = 'tb1', String birthGanZhi = 'gz1'}) => TiebanDivinationRecordContract(
      uuid: uuid,
      question: 'q',
      birthDatetimeJson: '{}',
      birthGanZhiJson: birthGanZhi,
      calculationResultJson: '{}',
      matchedTiaoWenIdsJson: '[]',
      paramsJson: '{}',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = TiebanRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    expect(encoded.meta.module, 'tiebanshenshu');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'tie_ban');

    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(_rec()));
  });

  test('decode with mismatched module throws', () {
    final encoded = codec.encode(_rec(), scopeUid: 's1');
    final badMeta = RecordMeta(
      uuid: encoded.meta.uuid,
      scopeUid: encoded.meta.scopeUid,
      module: 'mismatched',
      category: encoded.meta.category,
      divinationType: encoded.meta.divinationType,
      createdAt: encoded.meta.createdAt,
    );
    expect(() => codec.decode(badMeta, encoded.moduleData), throwsA(isA<RecordCodecMismatch>()));
  });

  test('extractSearchTags emits birthGanZhiJson', () {
    final encoded = codec.encode(_rec(birthGanZhi: 'jia-zi'), scopeUid: 's1');
    final tags = codec.extractSearchTags(encoded.meta, encoded.moduleData);
    expect(tags, contains(const SearchTag('birth_gan_zhi', 'jia-zi')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'tb1');
    final r2 = codec.withUuid(r, 'tb2');
    expect(codec.uuidOf(r2), 'tb2');
    expect(r2.birthGanZhiJson, 'gz1');
  });
}
