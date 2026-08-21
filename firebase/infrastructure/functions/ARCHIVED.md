# ⚠ 本目录已归档（TypeScript 版 Cloud Functions）

**归档日期**：2026-08-20
**状态**：**已停止部署，代码保留**
**接替者**：`../functions-py/`（Python 3.11 版，功能等价）

---

## 这是什么

这是玄 playground 后端最初的 TypeScript 实现，共 25 个 callable + 3 个 trigger。
2026-08 分六轮（P1–P6）重写为 Python 后退役。

## 为什么保留而不删除

它是 Python 版正确性的**唯一独立参照物**。

Python 版的单元测试是照着这份 TS 源码写的——用它们证明 Python 正确等于自证。
真正的外部证据来自工作令 A（离线回放影子比对）：
同一批输入分别打到两版，比对返回值与 Firestore 副作用。
留着这份代码，A 随时可以重跑。

## 已经做了什么

- 从 `../firebase.json` 与 `../emulator/firebase.json` 的 `functions` 配置中
  **摘除了 `default` codebase** —— 不再部署、Emulator 也不再加载
- 源码**原样保留在仓库中**，未做任何删改
- 打了 tag：`ts-functions-final`

## 怎么临时启用它（比如要重跑 A）

把这一段加回 `emulator/firebase.json` 的 `functions` 数组：

```json
{ "source": "../functions", "codebase": "default" }
```

`lib/` 已编译、`node_modules/` 已安装。若缺失，在本目录跑 `npm ci && npm run build`。

## 验证结论（工作令 A，2026-08-20）

| 项 | 结果 |
|---|---|
| 回放样本 | 63 个（60 callable + 3 trigger），覆盖 25 个 callable 全部成功路径与主要错误路径 |
| 比对面 | HTTP 状态码 + 返回值 + 17 个集合的全库快照（占位符归一化，保引用拓扑） |
| 结果 | 63/63 等价，0 差异 |
| trigger | 因两版监听同一路径会双重触发，改用按 codebase 隔离的两阶段跑法比对 |

详见 `docs/dispatch/2026-08-20-faas-A-result.md`。

## 什么时候可以真删

等 Python 版在线上稳定运行一段时间后**另行决定**。
在那之前，删除这份代码 = 丢掉唯一的行为基准。

## 遗留问题去向

TS 侧的已知遗留缺陷 **L-1 ~ L-4 不在这里修**——TS 已冻结。
它们只在 Python 侧修复（C 阶段）。这意味着此后两版行为会**有意分叉**，
再跑 A 时需要把这些点排除在比对之外。
