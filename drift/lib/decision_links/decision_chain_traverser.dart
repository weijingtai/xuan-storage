import '../persistence_drift.dart';

class DecisionChainTraverser {
  final DecisionLinksDao _dao;

  DecisionChainTraverser(this._dao);

  /// BFS 遍历从 [rootUuid] 出发的全部下游 link。
  Future<List<DecisionLinkRow>> getFullChain(String rootUuid, String scopeUid) async {
    final visited = <String>{};
    final result = <DecisionLinkRow>[];
    final queue = <String>[rootUuid];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current)) continue;
      final links = await _dao.listBySource(current, scopeUid);
      for (final link in links) {
        result.add(link);
        queue.add(link.targetUuid);
      }
    }
    return result;
  }

  /// 查询某记录的所有分叉 (link_type='fork')。
  Future<List<DecisionLinkRow>> getForks(String sourceUuid, String scopeUid) =>
      _dao.listByType(sourceUuid, 'fork', scopeUid);

  /// 查询合并到某记录的所有源 (link_type='merge')。
  Future<List<DecisionLinkRow>> getMergeSources(String targetUuid, String scopeUid) =>
      _dao.listByTarget(targetUuid, scopeUid)
          .then((links) => links.where((l) => l.linkType == 'merge').toList());

  /// 查询指向某记录的所有推断 (link_type='inference' 或 'inference_ambiguous')。
  Future<List<DecisionLinkRow>> getInferenceChain(String targetUuid, String scopeUid) async {
    final links = await _dao.listByTarget(targetUuid, scopeUid);
    return links.where((l) => l.linkType == 'inference' || l.linkType == 'inference_ambiguous').toList();
  }

  /// 递归追踪 merge 链（取最后一条 merge link 继续追踪）。
  Future<List<DecisionLinkRow>> getMergeChain(String startUuid, String scopeUid) async {
    final results = <DecisionLinkRow>[];
    var current = startUuid;
    while (true) {
      final links = await _dao.listBySource(current, scopeUid);
      final mergeLinks = links.where((l) => l.linkType == 'merge').toList();
      if (mergeLinks.isEmpty) break;
      results.addAll(mergeLinks);
      current = mergeLinks.last.targetUuid;
    }
    return results;
  }
}
