import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:metaphysics_core/enums/enum_gender.dart';
import '../record/base_record_backed_repository.dart';

class RecordBackedSeekerRepository
    extends BaseRecordBackedRepository<SeekerModel> {
  RecordBackedSeekerRepository({
    required super.store,
    required super.codec,
    super.uuid,
  });

  Future<String> saveSeeker(SeekerModel seeker) => save(seeker);
  Future<SeekerModel?> getSeekerByUuid(String uuid) => getByUuid(uuid);
  Future<List<SeekerModel>> getAllSeekers() => getAll();
  Future<bool> softDeleteSeeker(String uuid) => softDelete(uuid);
  Future<SeekerModel?> findByName(String name) =>
      getFirstByIndex('seeker_name', name);

  Future<List<SeekerModel>> findByUsername(String name) =>
      getAllByIndex('seeker_name', name);
  Future<List<SeekerModel>> findByGender(Gender gender) =>
      getAllByIndex('gender', gender.name);
  Future<List<SeekerModel>> findByLunarMonth(int month) =>
      getAllByIndex('lunar_month', '$month');
}
