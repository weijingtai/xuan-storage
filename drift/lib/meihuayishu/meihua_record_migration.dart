import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'meihua_divinations_dao.dart';

Future<int> migrateMeihuaRecords({
  required MeiHuaDivinationsDao oldDao,
  required MeiHuaDivinationRecordRepository target,
}) async {
  final rows = await oldDao.getAllRecords();
  var migrated = 0;
  for (final row in rows) {
    if (await target.getRecordByUuid(row.uuid) != null) continue; // 幂等
    await target.saveRecord(MeiHuaDivinationRecordContract(
      uuid: row.uuid, divinationUuid: row.divinationUuid, question: row.question,
      originalUpperGua: row.originalUpperGua, originalLowerGua: row.originalLowerGua,
      changingYao: row.changingYao, changedUpperGua: row.changedUpperGua,
      changedLowerGua: row.changedLowerGua, huUpperGua: row.huUpperGua,
      huLowerGua: row.huLowerGua, method: row.method, paramsJson: row.paramsJson,
      createdAt: row.createdAt, updatedAt: row.updatedAt, deletedAt: row.deletedAt));
    migrated++;
  }
  return migrated;
}
