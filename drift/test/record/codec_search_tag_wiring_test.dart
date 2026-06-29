import 'package:drift/native.dart';
import 'package:persistence_drift/persistence_drift.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:test/test.dart';
import 'package:persistence_drift/qizhengsiyu/qizheng_record_codec.dart';

void main() {
  test('saveRecord extract search tags via RecordModuleCodec registry', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ds = DriftRecordDataSource(db, scopeUid: 's1');
    
    // Wire up the registry with QiZhengRecordCodec (which is a RecordModuleCodec, i.e., RecordSearchTagExtractor)
    final codec = QiZhengRecordCodec();
    final registry = RecordAdapterRegistry([codec]);
    final repo = LocalRecordRepository(ds, registry);
    
    final contract = QiZhengSiYuPanContract(
      uuid: 'q1',
      createdAt: DateTime.utc(2026),
      lastUpdatedAt: DateTime.utc(2026),
      deletedAt: null,
      divinationRequestInfoUuid: 'req-123',
      divinationDatetimeJson: '{}',
      panelConfigJson: '{}',
      panelModelJson: '{}',
    );
    
    final encoded = codec.encode(contract, scopeUid: 's1');
    
    await repo.saveRecord(encoded.meta, moduleData: encoded.moduleData);
    
    // Find by the index field "divination_request_info_uuid"
    final results = await repo.findByIndex(
      module: 'qizhengsiyu',
      indexKey: 'divination_request_info_uuid',
      indexValue: 'req-123',
      limit: 10,
    );
    
    expect(results, hasLength(1));
    expect(results.first.uuid, 'q1');
  });
}
