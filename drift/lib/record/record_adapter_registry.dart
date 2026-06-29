import 'package:repository_interface_record/repository_interface_record.dart';

class RecordAdapterRegistry {
  final Map<String, RecordSearchTagExtractor> _byModule;
  RecordAdapterRegistry(List<RecordSearchTagExtractor> extractors)
      : _byModule = {for (final e in extractors) e.module: e} {
    if (_byModule.length != extractors.length) {
      throw StateError('Duplicate module in RecordAdapterRegistry');
    }
  }
  RecordSearchTagExtractor? forModule(String module) => _byModule[module];
}
