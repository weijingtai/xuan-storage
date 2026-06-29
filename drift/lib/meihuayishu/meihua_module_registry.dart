import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'meihua_record_adapter.dart';
import 'record_backed_meihua_repository.dart';

/// 梅花易数模块注册 — 提供 Codec + Repository 实例供 DI 组装。
class MeiHuaModuleRegistry {
  static RecordModuleCodec<MeiHuaDivinationRecordContract> codec({required String scopeUid}) =>
      MeihuaRecordAdapter(scopeUid: scopeUid);

  static MeiHuaDivinationRecordRepository repository({
    required ScopedRecordStore store,
    required String scopeUid,
  }) =>
      RecordBackedMeiHuaRepository(store, codec(scopeUid: scopeUid));
}
