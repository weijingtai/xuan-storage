import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'meihua_divinations_dao.dart';

Future<int> migrateMeihuaRecords({
  required MeiHuaDivinationsDao oldDao,
  required MeiHuaDivinationRecordRepository target,
}) async {
  final ctx = RequestContext(scopeUid: 'local-anonymous');
  final rows = await oldDao.getAllRecords();
  var migrated = 0;
  for (final row in rows) {
    // 幂等：已存在则跳过
    final existing = await target.get(row.uuid, ctx);
    switch (existing) {
      case Ok(:final value):
        if (value != null) continue;
      case Err():
        break;
    }
    final result = await target.put(MeiHuaDivinationRecordContract(
      uuid: row.uuid, divinationUuid: row.divinationUuid, question: row.question,
      originalUpperGua: row.originalUpperGua, originalLowerGua: row.originalLowerGua,
      changingYao: row.changingYao, changedUpperGua: row.changedUpperGua,
      changedLowerGua: row.changedLowerGua, huUpperGua: row.huUpperGua,
      huLowerGua: row.huLowerGua, method: row.method, paramsJson: row.paramsJson,
      createdAt: row.createdAt, updatedAt: row.updatedAt, deletedAt: row.deletedAt), ctx);
    switch (result) {
      case Ok():
        migrated++;
      case Err():
        break;
    }
  }
  return migrated;
}
