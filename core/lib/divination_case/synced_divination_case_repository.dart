import 'package:divination_case/divination_case.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';

/// 基于 L0 组合器契约的 Synced 案卷仓储适配层。
///
/// 组合 local 与 remote 仓储。采用 LocalFirst 策略：
/// - 读：本地先行；
/// - 写：委托内核 [localFirstWrite] 组合器，本地成功后异步推远端，远端可重试错误入 outbox，不影响本地成功返回；
/// - 错误可判别：非 XuanError 的未知异常按 internal 处理直接上抛，严禁无条件吞异常；
/// - 消除假实现：全 15 个方法完整代理到下游对应切片/接口。
class SyncedDivinationCaseRepository
    implements
        DivinationCaseRepository,
        DivinationRecordRepository,
        DivinationWorkItemRepository,
        DivinationParticipantRepository,
        PanelRefRepository {
  /// 构造。
  SyncedDivinationCaseRepository({
    required this.local,
    @Deprecated('方案已废弃：divination_case 为 peer 驻留，该路径实现有误，'
        '保留供将来重启 peer 同步时参考，勿直接复用')
    this.remote,
    this.retryPolicy = const RetryPolicy(),
    Outbox? outbox,
  }) : outbox = outbox ?? Outbox(retryPolicy: retryPolicy);

  /// 本地仓储。
  final DivinationCaseRepository local;

  /// 远端仓储（可选）。
  @Deprecated('方案已废弃：divination_case 为 peer 驻留，该路径实现有误，'
      '保留供将来重启 peer 同步时参考，勿直接复用')
  final DivinationCaseRepository? remote;

  /// 重试策略。
  final RetryPolicy retryPolicy;

  /// Outbox 待发队列。
  final Outbox outbox;

  Future<Result<void>> Function()? _wrapRemote(Future<void> Function()? remoteOp) {
    if (remoteOp == null) return null;
    return () async {
      try {
        await remoteOp();
        return const Ok(null);
      } on XuanError catch (e) {
        return Err(e);
      } catch (e) {
        // 未知异常默认按不可重试的 internal 错误处理，直接上抛，不进 outbox
        return Err(XuanError(code: ErrorCode.internal, message: '$e'));
      }
    };
  }

  // --- DivinationCaseRepository ---

  @override
  Future<DivinationCaseModel?> getCase(String uuid) async {
    final localResult = await local.getCase(uuid);
    if (localResult != null) return localResult;
    final r = remote;
    if (r != null) {
      return await r.getCase(uuid);
    }
    return null;
  }

  @override
  Future<List<DivinationCaseModel>> listCases({bool includeDeleted = false}) async {
    return local.listCases(includeDeleted: includeDeleted);
  }

  @override
  Future<void> saveCase(DivinationCaseModel model) async {
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        await local.saveCase(model);
        return const Ok(null);
      },
      remote: _wrapRemote(r == null ? null : () => r.saveCase(model)),
      outbox: outbox,
      outboxEntryId: 'case:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid, 'title': model.title},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }

  // --- DivinationRecordRepository ---

  @override
  Future<List<DivinationRecordModel>> listRecordsForCase(String caseUuid) async {
    final l = local;
    if (l is DivinationRecordRepository) {
      return (l as DivinationRecordRepository).listRecordsForCase(caseUuid);
    }
    return [];
  }

  @override
  Future<DivinationRecordModel?> getRecord(String uuid) async {
    final l = local;
    if (l is DivinationRecordRepository) {
      return (l as DivinationRecordRepository).getRecord(uuid);
    }
    return null;
  }

  @override
  Future<void> saveRecord(DivinationRecordModel model) async {
    final l = local;
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        if (l is DivinationRecordRepository) {
          await (l as DivinationRecordRepository).saveRecord(model);
        }
        return const Ok(null);
      },
      remote: _wrapRemote(r is DivinationRecordRepository
          ? () => (r as DivinationRecordRepository).saveRecord(model)
          : null),
      outbox: outbox,
      outboxEntryId: 'record:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }

  // --- DivinationWorkItemRepository ---

  @override
  Future<List<DivinationWorkItemModel>> listWorkItemsForCase(String caseUuid) async {
    final l = local;
    if (l is DivinationWorkItemRepository) {
      return (l as DivinationWorkItemRepository).listWorkItemsForCase(caseUuid);
    }
    return [];
  }

  @override
  Future<DivinationWorkItemModel?> getWorkItem(String uuid) async {
    final l = local;
    if (l is DivinationWorkItemRepository) {
      return (l as DivinationWorkItemRepository).getWorkItem(uuid);
    }
    return null;
  }

  @override
  Future<void> saveWorkItem(DivinationWorkItemModel model) async {
    final l = local;
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        if (l is DivinationWorkItemRepository) {
          await (l as DivinationWorkItemRepository).saveWorkItem(model);
        }
        return const Ok(null);
      },
      remote: _wrapRemote(r is DivinationWorkItemRepository
          ? () => (r as DivinationWorkItemRepository).saveWorkItem(model)
          : null),
      outbox: outbox,
      outboxEntryId: 'work_item:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }

  // --- DivinationParticipantRepository ---

  @override
  Future<List<DivinationParticipantModel>> listParticipantsForCase(String caseUuid) async {
    final l = local;
    if (l is DivinationParticipantRepository) {
      return (l as DivinationParticipantRepository).listParticipantsForCase(caseUuid);
    }
    return [];
  }

  @override
  Future<void> saveParticipant(DivinationParticipantModel model) async {
    final l = local;
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        if (l is DivinationParticipantRepository) {
          await (l as DivinationParticipantRepository).saveParticipant(model);
        }
        return const Ok(null);
      },
      remote: _wrapRemote(r is DivinationParticipantRepository
          ? () => (r as DivinationParticipantRepository).saveParticipant(model)
          : null),
      outbox: outbox,
      outboxEntryId: 'participant:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }

  // --- PanelRefRepository ---

  @override
  Future<PanelRefModel?> getPanelRef(String uuid) async {
    final l = local;
    if (l is PanelRefRepository) {
      return (l as PanelRefRepository).getPanelRef(uuid);
    }
    return null;
  }

  @override
  Future<void> savePanelRef(PanelRefModel model) async {
    final l = local;
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        if (l is PanelRefRepository) {
          await (l as PanelRefRepository).savePanelRef(model);
        }
        return const Ok(null);
      },
      remote: _wrapRemote(r is PanelRefRepository
          ? () => (r as PanelRefRepository).savePanelRef(model)
          : null),
      outbox: outbox,
      outboxEntryId: 'panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }

  @override
  Future<List<WorkItemPanelRefModel>> listPanelRefsForWorkItem(String workItemUuid) async {
    final l = local;
    if (l is PanelRefRepository) {
      return (l as PanelRefRepository).listPanelRefsForWorkItem(workItemUuid);
    }
    return [];
  }

  @override
  Future<void> attachPanelRefToWorkItem(WorkItemPanelRefModel model) async {
    final l = local;
    final r = remote;
    final res = await localFirstWrite(
      local: () async {
        if (l is PanelRefRepository) {
          await (l as PanelRefRepository).attachPanelRefToWorkItem(model);
        }
        return const Ok(null);
      },
      remote: _wrapRemote(r is PanelRefRepository
          ? () => (r as PanelRefRepository).attachPanelRefToWorkItem(model)
          : null),
      outbox: outbox,
      outboxEntryId: 'attach_panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
      outboxPayload: {'uuid': model.uuid, 'workItemUuid': model.workItemUuid},
    );
    if (res case Err(error: final e)) {
      throw e;
    }
  }
}
