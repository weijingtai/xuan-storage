import 'dart:convert';

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
  Future<int> getStrokeCount(String character) async {
    if (character.isEmpty) return 0;
    final row = await _database.queryCharacter(character);
    if (row == null || row.matchesJson == null) return 7;
    try {
      final List<dynamic> matches =
          jsonDecode(row.matchesJson!) as List<dynamic>;
      return matches.length;
    } catch (_) {
      return 7;
    }
  }

  @override
  Future<List<int>> getStrokeCounts(String text) async {
    final counts = <int>[];
    for (final char in text.split('')) {
      counts.add(await getStrokeCount(char));
    }
    return counts;
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
