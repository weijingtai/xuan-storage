import 'package:repository_interface_liuyao/repository_interface_liuyao.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:persistence_drift/liuyao/liuyao_record_codec.dart';
import 'package:flutter_test/flutter_test.dart';

SixYaoDivinationRecord _rec({String uuid = 'ly1', int originalGuaId = 1, int? changedGuaId}) => SixYaoDivinationRecord(
      uuid: uuid,
      question: '出行?',
      yaoResults: const [
        SixYaoYaoResult(index: 0, yaoType: YaoType.shaoyang),
        SixYaoYaoResult(index: 1, yaoType: YaoType.shaoyin),
        SixYaoYaoResult(index: 2, yaoType: YaoType.laoyang),
        SixYaoYaoResult(index: 3, yaoType: YaoType.laoyin),
        SixYaoYaoResult(index: 4, yaoType: YaoType.shaoyang),
        SixYaoYaoResult(index: 5, yaoType: YaoType.shaoyin),
      ],
      originalGuaId: originalGuaId,
      changedGuaId: changedGuaId,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    );

void main() {
  final codec = LiuYaoRecordCodec();

  test('encode then decode round-trips the contract', () {
    final encoded = codec.encode(_rec(changedGuaId: 2), scopeUid: 's1');
    expect(encoded.meta.module, 'liuyao');
    expect(encoded.meta.scopeUid, 's1');
    expect(encoded.meta.category, 'divination');
    expect(encoded.meta.divinationType, 'liu_yao');

    final decoded = codec.decode(encoded.meta, encoded.moduleData);
    expect(decoded, equals(_rec(changedGuaId: 2)));
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

  test('extractSearchTags emits original_gua_id and optionally changed_gua_id', () {
    final encoded1 = codec.encode(_rec(originalGuaId: 3), scopeUid: 's1');
    final tags1 = codec.extractSearchTags(encoded1.meta, encoded1.moduleData);
    expect(tags1, contains(const SearchTag('original_gua_id', '3')));
    expect(tags1.where((t) => t.key == 'changed_gua_id'), isEmpty);

    final encoded2 = codec.encode(_rec(originalGuaId: 3, changedGuaId: 4), scopeUid: 's1');
    final tags2 = codec.extractSearchTags(encoded2.meta, encoded2.moduleData);
    expect(tags2, contains(const SearchTag('original_gua_id', '3')));
    expect(tags2, contains(const SearchTag('changed_gua_id', '4')));
  });

  test('uuidOf and withUuid operations', () {
    final r = _rec();
    expect(codec.uuidOf(r), 'ly1');
    final r2 = codec.withUuid(r, 'ly2');
    expect(codec.uuidOf(r2), 'ly2');
    expect(r2.originalGuaId, 1);
  });
}
