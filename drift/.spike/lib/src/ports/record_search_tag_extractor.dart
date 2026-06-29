import 'package:spike_typed_record_base/src/models/record_meta.dart';

abstract interface class RecordSearchTagExtractor {
  String get module;
  List<SearchTag> extractSearchTags(
    RecordMeta meta,
    Map<String, dynamic>? moduleData,
  );
}
