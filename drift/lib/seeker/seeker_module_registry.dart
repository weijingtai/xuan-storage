import 'package:metaphysics_core/datamodel/seeker_model.dart';
import 'package:repository_interface_record/repository_interface_record.dart';
import 'package:uuid/uuid.dart';
import 'seeker_record_codec.dart';
import 'record_backed_seeker_repository.dart';

class SeekerModuleRegistry {
  static RecordModuleCodec<SeekerModel> codec() => SeekerRecordCodec();

  static RecordBackedSeekerRepository repository({
    required ScopedRecordStore store,
    Uuid? uuid,
  }) => RecordBackedSeekerRepository(store: store, codec: codec(), uuid: uuid);
}
