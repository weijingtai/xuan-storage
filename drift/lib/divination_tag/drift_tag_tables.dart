import 'package:drift/drift.dart';
import 'package:repository_interface_divination_tag/repository_interface_divination_tag.dart';

/// 公共标签维度表 — Drift schema for the shared tag dimension catalog.
///
/// These tables define where the dimension/tag vocabulary lives once a Drift
/// database wires them in. The phase-one adapter serves the built-in seed
/// vocabulary below synchronously (the port is synchronous), so the table
/// definitions and the seed constants are co-located here as one source of
/// truth (TDD-XG-05).
@DataClassName('DivinationTagDimensionRow')
class DivinationTagDimensions extends Table {
  @override
  String get tableName => 'divination_tag_dimensions';

  TextColumn get dimensionId => text().named('dimension_id')();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get applicableModulesJson =>
      text().nullable().named('applicable_modules_json')();
  IntColumn get version =>
      integer().withDefault(const Constant(1)).named('version')();

  @override
  Set<Column> get primaryKey => {dimensionId};
}

@DataClassName('DivinationTagRow')
class DivinationTags extends Table {
  @override
  String get tableName => 'divination_tags';

  TextColumn get tagId => text().named('tag_id')();
  TextColumn get dimensionId => text().named('dimension_id')();
  TextColumn get tagText => text().named('text')();
  IntColumn get version =>
      integer().withDefault(const Constant(1)).named('version')();
  IntColumn get sortOrder =>
      integer().withDefault(const Constant(0)).named('sort_order')();

  @override
  Set<Column> get primaryKey => {tagId};

  List<Index> get indexes => [
        Index(
          'idx_divination_tags_dimension',
          'CREATE INDEX idx_divination_tags_dimension '
          'ON divination_tags (dimension_id, sort_order);',
        ),
      ];
}

/// 一期内置种子维度：五行、吉凶。
const List<TagDimension> seedTagDimensions = [
  TagDimension(dimensionId: 'wu-xing', displayName: '五行'),
  TagDimension(dimensionId: 'ji-xiong', displayName: '吉凶'),
];

/// 一期内置种子标签：五行（金木水火土）、吉凶（吉凶平），按 sortOrder 排列。
const List<DimensionTag> seedDimensionTags = [
  DimensionTag(
      tagId: 'tag.wu-xing.jin',
      dimensionId: 'wu-xing',
      text: '金',
      sortOrder: 1),
  DimensionTag(
      tagId: 'tag.wu-xing.mu',
      dimensionId: 'wu-xing',
      text: '木',
      sortOrder: 2),
  DimensionTag(
      tagId: 'tag.wu-xing.shui',
      dimensionId: 'wu-xing',
      text: '水',
      sortOrder: 3),
  DimensionTag(
      tagId: 'tag.wu-xing.huo',
      dimensionId: 'wu-xing',
      text: '火',
      sortOrder: 4),
  DimensionTag(
      tagId: 'tag.wu-xing.tu',
      dimensionId: 'wu-xing',
      text: '土',
      sortOrder: 5),
  DimensionTag(
      tagId: 'tag.ji-xiong.ji',
      dimensionId: 'ji-xiong',
      text: '吉',
      sortOrder: 1),
  DimensionTag(
      tagId: 'tag.ji-xiong.xiong',
      dimensionId: 'ji-xiong',
      text: '凶',
      sortOrder: 2),
  DimensionTag(
      tagId: 'tag.ji-xiong.ping',
      dimensionId: 'ji-xiong',
      text: '平',
      sortOrder: 3),
];
