import 'package:persistence_drift/persistence_drift.dart';
import 'package:drift/drift.dart';

class DaYunRecordRepository {
  final PersistenceDriftDatabase db;
  late final DaYunRecordsDao _dao;

  DaYunRecordRepository(this.db) : _dao = DaYunRecordsDao(db);

  Future<int> insert(Insertable<DaYunRecord> record) {
    return _dao.insertRecord(record);
  }

  Future<List<DaYunRecord>> queryByDivinationId(String divinationId) {
    return _dao.getBySource(divinationId);
  }
}
