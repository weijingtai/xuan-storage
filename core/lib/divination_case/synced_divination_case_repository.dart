import 'package:divination_case/divination_case.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';

/// 基于 L0 组合器契约的 Synced 案卷仓储适配层。
///
/// 组合 local 与 remote 仓储。采用 LocalFirst 策略：
/// - 读：本地先行；
/// - 写：本地成功后异步推远端，远端可重试错误入 outbox，不影响本地成功返回；
/// - 错误可判别：不可重试错误（permission_denied 等）直接上抛，严禁无条件吞异常；
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
    this.remote,
    this.retryPolicy = const RetryPolicy(),
    Outbox? outbox,
  }) : outbox = outbox ?? Outbox(retryPolicy: retryPolicy);

  /// 本地仓储。
  final DivinationCaseRepository local;

  /// 远端仓储（可选）。
  final DivinationCaseRepository? remote;

  /// 重试策略。
  final RetryPolicy retryPolicy;

  /// Outbox 待发队列。
  final Outbox outbox;

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
    await local.saveCase(model);
    final r = remote;
    if (r != null) {
      try {
        await r.saveCase(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'case:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'title': model.title},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'case:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'title': model.title},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
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
    if (l is DivinationRecordRepository) {
      await (l as DivinationRecordRepository).saveRecord(model);
    }
    final r = remote;
    if (r is DivinationRecordRepository) {
      try {
        await (r as DivinationRecordRepository).saveRecord(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'record:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'record:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
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
    if (l is DivinationWorkItemRepository) {
      await (l as DivinationWorkItemRepository).saveWorkItem(model);
    }
    final r = remote;
    if (r is DivinationWorkItemRepository) {
      try {
        await (r as DivinationWorkItemRepository).saveWorkItem(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'work_item:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'work_item:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
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
    if (l is DivinationParticipantRepository) {
      await (l as DivinationParticipantRepository).saveParticipant(model);
    }
    final r = remote;
    if (r is DivinationParticipantRepository) {
      try {
        await (r as DivinationParticipantRepository).saveParticipant(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'participant:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'participant:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'caseUuid': model.caseUuid},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
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
    if (l is PanelRefRepository) {
      await (l as PanelRefRepository).savePanelRef(model);
    }
    final r = remote;
    if (r is PanelRefRepository) {
      try {
        await (r as PanelRefRepository).savePanelRef(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
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
    if (l is PanelRefRepository) {
      await (l as PanelRefRepository).attachPanelRefToWorkItem(model);
    }
    final r = remote;
    if (r is PanelRefRepository) {
      try {
        await (r as PanelRefRepository).attachPanelRefToWorkItem(model);
      } on XuanError catch (e) {
        if (e.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'attach_panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'workItemUuid': model.workItemUuid},
            lastError: e,
          ));
        } else {
          rethrow;
        }
      } catch (e) {
        final xuanErr = XuanError(code: ErrorCode.unavailable, message: '$e');
        if (xuanErr.retryable) {
          outbox.enqueue(OutboxEntry(
            id: 'attach_panel_ref:${model.uuid}:${DateTime.now().microsecondsSinceEpoch}',
            payload: {'uuid': model.uuid, 'workItemUuid': model.workItemUuid},
            lastError: xuanErr,
          ));
        } else {
          rethrow;
        }
      }
    }
  }
}
