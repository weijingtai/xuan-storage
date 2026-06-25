import 'package:repository_interface_record/repository_interface_record.dart';

class RecordAdapterRegistry {
  final Map<String, ModuleRecordAdapter> _byModule;
  RecordAdapterRegistry(List<ModuleRecordAdapter> adapters)
      : _byModule = {for (final a in adapters) a.module: a} {
    if (_byModule.length != adapters.length) {
      throw StateError('Duplicate module in RecordAdapterRegistry');
    }
  }
  ModuleRecordAdapter? forModule(String module) => _byModule[module];
}
