import 'dart:convert';

import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_meihuayishu/repository_interface_meihuayishu.dart';

import 'dictionary_database.dart';

/// Read-only Drift-backed implementation of [MeiHuaDictionaryRepository] over
/// the bundled, prebuilt `dictionary.db` asset.
class DriftMeiHuaDictionaryRepository implements MeiHuaDictionaryRepository {
  final DictionaryDatabase _database;

  DriftMeiHuaDictionaryRepository(this._database);

  @override
  Future<MeiHuaDictionaryCharacterContract?> queryCharacter(
      String character) async {
    final row = await _database.queryCharacter(character);
    if (row == null) return null;
    return MeiHuaDictionaryCharacterContract(
      id: row.id,
      character: row.character,
      definition: row.definition,
      radical: row.radical,
      decomposition: row.decomposition,
      matchesJson: row.matchesJson,
    );
  }

  @override
  Future<List<MeiHuaDictionaryPinyinContract>> queryPinyins(
      int characterId) async {
    final rows = await _database.queryPinyins(characterId);
    return rows
        .map((p) => MeiHuaDictionaryPinyinContract(
              id: p.id,
              characterId: p.characterId,
              pinyin: p.pinyin,
              pinyinWithToneNumber: p.pinyinWithToneNumber,
            ))
        .toList();
  }

  @override
  Future<Result<MeiHuaDictionaryCharacterContract?>> get(
    String id,
    RequestContext ctx,
  ) async {
    if (id.isEmpty) return const Ok(null);
    final row = await _database.queryCharacter(id);
    if (row == null) return const Ok(null);
    return Ok(MeiHuaDictionaryCharacterContract(
      id: row.id,
      character: row.character,
      definition: row.definition,
      radical: row.radical,
      decomposition: row.decomposition,
      matchesJson: row.matchesJson,
    ));
  }

  @override
  Future<Result<bool>> exists(String id, RequestContext ctx) async {
    final row = await _database.queryCharacter(id);
    return Ok(row != null);
  }

  @override
  Future<Result<Page<MeiHuaDictionaryCharacterContract>>> query(
    Map<String, Object?> spec,
    PageRequest page,
    RequestContext ctx,
  ) async {
    final text = spec['text'] as String? ?? '';
    final items = <MeiHuaDictionaryCharacterContract>[];
    for (final char in text.split('')) {
      final row = await _database.queryCharacter(char);
      if (row != null) {
        items.add(MeiHuaDictionaryCharacterContract(
          id: row.id,
          character: row.character,
          definition: row.definition,
          radical: row.radical,
          decomposition: row.decomposition,
          matchesJson: row.matchesJson,
        ));
      }
    }
    return Ok(Page(items: items, nextCursor: null));
  }

  @override
  Future<Result<int>> count(
    Map<String, Object?> spec,
    RequestContext ctx,
  ) async {
    final text = spec['text'] as String? ?? '';
    return Ok(text.length);
  }

  @override
  Future<Result<List<MeiHuaDictionaryCharacterContract>>> getByIndex(
    String field,
    Object? value,
    RequestContext ctx, {
    int limit = 200,
  }) async {
    return const Ok([]);
  }

  @override
  Stream<Result<List<MeiHuaDictionaryCharacterContract>>> watchByIndex(
    String field,
    Object? value,
    RequestContext ctx, {
    int limit = 200,
  }) {
    return const Stream.empty();
  }

  @override
  Future<int> getStrokeCount(String character) async {
    final char = await queryCharacter(character);
    return char?.matchesJson?.length ?? 0;
  }

  @override
  Future<List<int>> getStrokeCounts(String text) async {
    final list = <int>[];
    for (var i = 0; i < text.length; i++) {
      list.add(await getStrokeCount(text[i]));
    }
    return list;
  }

  @override
  Future<String?> getPinyin(String character) {
    return _database.getPinyin(character);
  }

  @override
  Future<String?> getPinyinWithToneNumber(String character) {
    return _database.getPinyinWithToneNumber(character);
  }

  @override
  Future<List<String>> getAllPinyinWithToneNumber(String character) {
    return _database.getAllPinyinWithToneNumber(character);
  }
}
