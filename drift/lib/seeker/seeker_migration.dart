// ignore_for_file: deprecated_member_use_from_same_package — 迁移工具需读取旧表，此为有意使用
import 'package:repository_interface_record/repository_interface_record.dart';
import '../daos/seekers_dao.dart';
import 'seeker_record_codec.dart';

class SeekerMigration {
  final SeekersDao _oldDao;
  final ScopedRecordStore _store;
  final SeekerRecordCodec _codec;

  SeekerMigration(this._oldDao, this._store, this._codec);

  Future<int> migrateAll() async {
    final seekers = await _oldDao.getAllSeekers();
    final active = seekers.where((s) => s.deletedAt == null).toList();
    for (final s in active) {
      final existing = await _store.getRecord(s.uuid, module: 'seeker');
      if (existing != null) continue;
      final encoded = _codec.encode(s, scopeUid: _store.scopeUid);
      await _store.saveRecord(encoded.meta, moduleData: encoded.moduleData);
    }
    return active.length;
  }
}
