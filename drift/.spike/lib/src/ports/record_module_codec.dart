import 'package:spike_typed_record_base/src/models/record_meta.dart';
import 'package:spike_typed_record_base/src/ports/record_search_tag_extractor.dart';

typedef EncodedRecord = ({
  RecordMeta meta,
  Map<String, dynamic>? moduleData,
});

abstract interface class RecordModuleCodec<TContract>
    implements RecordSearchTagExtractor {
  String get category;
  String get divinationType;
  String uuidOf(TContract contract);
  TContract withUuid(TContract contract, String uuid);
  EncodedRecord encode(TContract contract, {required String scopeUid});
  TContract decode(RecordMeta meta, Map<String, dynamic>? moduleData);
}

class RecordCodecMismatch implements Exception {
  final String message;
  const RecordCodecMismatch({required this.message});
  @override
  String toString() => 'RecordCodecMismatch: $message';
}
