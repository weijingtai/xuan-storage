# Seeker 解耦设计 spec

> **日期**: 2026-06-29
> **目标**: 将 Seeker 从旧 divination 耦合表中解耦，建立 scope 隔离的求测人管理
> **任务**: S0–S7（详见 `docs/superpowers/plans/2026-06-29-seeker-decoupling-act-plan.md`）

---

## 原始设计方案

Seeker 原计划在 `t_seekers` 表上补充 `scope_uid` 列并添加索引，通过 scope 过滤实现多账户隔离，保留旧表结构不变。

---

## 实现偏离说明 (seeker-as-record)

**实际实现**将 Seeker 作为统一记录模块接入 `t_record_meta`（module='seeker'），而非在 `t_seekers` 表补 `scope_uid`。

**原因**：
1. **天然继承 scope 隔离** — `t_record_meta` 已有完整的 scope_uid 过滤体系（所有查询经 `DriftRecordDataSource` 自动 scope 过滤），无需重复实现
2. **统一索引查询** — 复用 `t_record_search_index` 的 EAV 索引（seeker_name / gender / lunar_month），无需新建 seeker 专用索引表
3. **统一软删除/迁移/同步** — 复用 `BaseRecordBackedRepository` 的软删除语义、`SeekerMigration` 单向迁移、以及后续 C0–C7 云同步管道，无需为 seeker 单独开发
4. **与 8 个占测模块对齐** — seeker 作为第 9 个 record module，代码模式一致（codec + registry + repository），降低维护成本

**scope 隔离验证**：`drift/test/seeker/seeker_e2e_test.dart` 中的跨 scope 不可见测试通过，证明 seeker 记录在 scope A 创建后在 scope B 查询中不可见，隔离由 `DriftRecordDataSource.scopeUid` 保证。

**旧表保留**：`t_seekers` / `t_seeker_divination_mapper` 未删除，仅标记 `@Deprecated`（含迁移指引注释），`SeekerMigration` 提供单向迁移工具。
