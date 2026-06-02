import 'dart:convert';

import 'four_zhu_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'models/layout_template.dart';
import 'connection.dart' as impl;

import 'daos/card_template_skill_usage_dao.dart';
import 'daos/card_template_meta_dao.dart';
import 'daos/card_template_setting_dao.dart';
import 'daos/layout_templates_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DaYunRecords,
    TaiYuanRecords,
    LayoutTemplates,
    CardTemplateMetas,
    CardTemplateSettings,
    CardTemplateSkillUsages,
    MarketTemplateInstalls,
  ],
  daos: [
    CardTemplateMetaDao,
    CardTemplateSettingDao,
    CardTemplateSkillUsageDao,
    LayoutTemplatesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e, bool loadInitialData = true])
      : _loadInitialData = loadInitialData,
        super(
          e ??
              driftDatabase(
                name: 'app_database',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      if (kDebugMode) {
                        debugPrint(
                          'Using ${result.chosenImplementation} due to unsupported '
                          'browser features: ${result.missingFeatures}',
                        );
                      }
                    }
                  },
                ),
              ),
        );

  final bool _loadInitialData;

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        if (_loadInitialData) {
          await _executeSqlScript('assets/sql/initial_data.sql');
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(layoutTemplates);
        }
        if (from < 3) {
          await m.createTable(cardTemplateSkillUsages);
        }
        if (from < 4) {
          await m.createTable(cardTemplateMetas);
        }
        if (from < 5) {
          await m.createTable(cardTemplateSettings);
        }
        if (from < 7) {
          await m.createTable(marketTemplateInstalls);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // Create a bunch of default values so the app doesn't look too empty
          // on the first start.
        }

        // This follows the recommendation to validate that the database schema
        // matches what drift expects
        await impl.validateDatabaseSchema(this);

        await _seedPublicLayoutTemplatesIfMissing();
      },
    );
  }

  Future<void> _executeSqlScript(String scriptPath) async {
    final sqlScript = await rootBundle.loadString(scriptPath);
    final statements = sqlScript
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  Future<void> _seedPublicLayoutTemplatesIfMissing() async {
    const publicCollectionId = '__public_default__';

    final existing = await layoutTemplatesDao.getAllByCollection(
      publicCollectionId,
    );
    if (existing.isNotEmpty) return;

    const assetPaths = <String>[
      'assets/templates/default_template.json',
      'assets/templates/chinese/outbox_payload_ink_minimal.json',
      'assets/templates/chinese/outbox_payload_vermilion_palace.json',
      'assets/templates/chinese/outbox_payload_blue_porcelain.json',
      'assets/templates/chinese/outbox_payload_bamboo_green.json',
    ];

    final resolvedKeys = await _resolveAssetKeys(assetPaths);

    final templates = <LayoutTemplate>[];
    for (final path in assetPaths) {
      try {
        final raw = await _loadSeedAsset(resolvedKeys[path] ?? path);
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        final templateObj = decoded['template'];
        if (templateObj is! Map) continue;
        final template = LayoutTemplate.fromJson(
          Map<String, dynamic>.from(templateObj as Map),
        ).copyWith(collectionId: publicCollectionId);
        templates.add(template);
      } catch (_) {
        continue;
      }
    }

    if (templates.isEmpty) return;
    await layoutTemplatesDao.upsertAllTemplates(templates);
  }

  Future<String> _loadSeedAsset(String relativePath) async {
    try {
      if (relativePath.startsWith('packages/xuan_four_zhu_card/')) {
        return rootBundle.loadString(relativePath);
      }
      return await rootBundle.loadString('packages/xuan_four_zhu_card/$relativePath');
    } catch (_) {
      return rootBundle.loadString(relativePath);
    }
  }

  Future<Map<String, String>> _resolveAssetKeys(
    List<String> desiredRelativePaths,
  ) async {
    try {
      final raw = await rootBundle.loadString('AssetManifest.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const <String, String>{};
      }

      final keys = decoded.keys.toList(growable: false);
      final resolved = <String, String>{};
      for (final desired in desiredRelativePaths) {
        final match = keys.firstWhere(
          (k) => k.endsWith(desired),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          resolved[desired] = match;
        }
      }
      return resolved;
    } catch (_) {
      return const <String, String>{};
    }
  }
}
