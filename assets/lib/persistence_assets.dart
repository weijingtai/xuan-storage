/// persistence_assets — read-only asset/JSON repository implementations.
///
/// Module subtrees are added by per-module storage-refactor plans under
/// `lib/<module>/`. This barrel re-exports them as they are created.
library;

export 'qimendunjia/assets_qimendunjia_official_rule_repository.dart';
export 'tiebanshenshu/assets_tiao_wen_repository.dart';
export 'qizhengsiyu/assets_qizheng_official_data_repositories.dart';
export 'ziwei/assets_star_catalog_repository.dart';
export 'daliuren/assets_daliuren_repositories.dart';
export 'geo/geo_datasets.dart';
export 'geo/xrap_geo_location_repository.dart';
export 'geo/drift/geo_database.dart';
export 'geo/drift_dataset_installer.dart';
