# ACT 协议文档 —— storage-s3c-c-preflight

> 生成于 2026-08-05，由 TDD 任务纪要 `tasks/claude-storage-s3c-c-preflight.md` 转译。
> 转译**未改动**验收标准区（A1–A10 逐字保留）。
> 执行体冷启动：读完本文件即可开工，不需要任何历史会话上下文。

```yaml
TASK_ID: "storage-s3c-c-preflight"
LANG: "Dart 3.11.0（Flutter 3.44.6 stable，SDK constraint '>=3.11.0 <4.0.0'）"
TARGET_FILE: |
  # 本任务是多文件工程任务，目标文件按阶段展开：
  # P3: core/lib/model/ice_server.dart            （新增，IceServerProvider 端口）
  # P4: core/test/ice_server_provider_guard_test.dart（新增，源码扫描守卫）
  # P5: 无代码改动，仅产出一份跨仓任务上报（见 P5 交付物）
  # P6: core/lib/test_support/peer_stream_contract_suite.dart（R5 变异自检，改动测试或注入点）
  # P7: 无新增文件，逐条变异自检记录写入 tasks/claude-storage-s3c-c-preflight.md 决定记录
  # P8: 收口，无新增文件

CONTEXT:
  DOMAIN: |
    S3c-c（WebRTC Transport 实现）依赖 S6（密钥配对，刚重启）。本轮不等 S6，
    交付 S6 完成当天 S3c-c 能立刻开工所需的全部前置：拆分裁定（已完成，D1 裁定丙）、
    TURN 选型（已完成，P2 文档已落盘）、平台配置定位（P5）、IceServerProvider 端口（P3）、
    扫描守卫（P4）、变异自检（P6/P7）、收口（P8）。
    规格唯一真相：docs/superpowers/specs/2026-07-31-storage-architecture-design.md
    （TURN 相关 :1057 仅 10–20% 走中继、:1073 托管服务、:1077 可见元数据风险）。
  STRATEGY: |
    IceServerProvider 必须是「能随时返回当前有效短期凭证」的异步接口，不是静态配置
    （三家候选都发短期 credential，凭证有时效）。服务商名零出现在 core 契约与注释里
    （供应商无关）。每条新测试必须先注入违规确认变红、再复原（变异自检），
    红在编译失败不算数。

DEPENDENCY_ALLOWANCE:
  IMPORTS: |
    - dart:async（Stream/Completer，R5 并发测试用）
    - 已存在的 core/lib/model/transport.dart（PeerIdentity/PeerSession/Transport）
    - 已存在的 core/lib/model/signaling.dart（SignalingChannel/SignalingSession）
    - 已存在的 core/lib/test_support/peer_stream_contract_suite.dart
    - 已存在的 core/lib/test_support/signaling_contract_suite.dart（11 条）
    - core/test/s1a_dartdoc_coverage_test.dart（dartdoc 下限抬高入口）
  EXTERNAL_LIBS: |
    - 禁止新增任何第三方依赖。core 的 pubspec.yaml 不得改动。
    - 禁止 flutter_webrtc（本轮不写真 WebRTC）。

SIGNATURE: |
  # P3 目标签名（落 core/lib/model/ice_server.dart，全部中文 dartdoc）：
  #
  # /// ICE 服务器描述。credential 是 Future<String> 而非 String ——
  # /// 表明它是运行时获取的短期凭证（有失效时间），不是常量字符串。
  # final class IceServer {
  #   final String urls;
  #   final String? username;
  #   final Future<String> Function() credential;
  #   const IceServer({required this.urls, this.username, required this.credential});
  # }
  #
  # /// ICE 服务器提供方端口。必须能随时返回当前有效凭证，不得缓存常量。
  # abstract interface class IceServerProvider {
  #   Future<List<IceServer>> iceServers();
  # }
  #
  # 约束：IceServer 的字段名与语义由执行体定，但必须满足——
  # (1) credential 是异步/延迟获取的短期凭证（体现时效性）；
  # (2) 文件内不得出现任何供应商名（Cloudflare/Twilio/Xirsys 等）；
  # (3) 新增公开声明全部有中文 dartdoc，且 s1a_dartdoc_coverage_test.dart 下限同步抬高。

GUARDRAILS:
  PROHIBITED:
    - "flutter_webrtc 及任何第三方依赖（core/pubspec.yaml 零改动）"
    - "真 WebRTC 代码、RTCPeerConnection、ICE candidate 真实现"
    - "供应商名（Cloudflare/Twilio/Xirsys/供应商无关字样的反例）出现在 core/lib/model/ 或 core/test/ 的契约与注释里"
    - "把 IceServer.credential 做成同步 String 常量（凭证时效性必须体现在签名里）"
    - "跨仓修改：xuan-qizhengsiyu（xuan-shell）的任何文件（P5 只写上报，不改仓）"
    - "修改 main 分支或 push 远端（本任务只在 agent/claude/storage-s3c-c-preflight 分支工作）"
    - "改动已完成的 P0/P1/P2 交付物（FakeTransport、transport_contract_test.dart、TURN 选型文档）"
    - "修改既有冻结门禁基线数字（S1a 57 条 / s1b core 57 / drift 145/146 / firebase 20/20 只读）"
  ABSOLUTELY_PROHIBITED:
    - "篡改验收标准区（A1–A10 逐字保留，一行不许改）"
    - "未做变异自检就宣称新测试通过（红在编译失败不算数，必须红在断言上）"
    - "git merge / git push / 切换分支（除非人类当次明确授权）"
    - "把 dartdoc 下限往下调（只允许随新增声明数量上调）"
    - "对 tasks/claude-storage-s3c-c-preflight.md 的验收标准打勾（勾选权在人类）"

ASSERTIONS:
  EXECENV: |
    flutter test（core 包）+ 三个 bash 门禁脚本（scripts/run_s1a_analyze_gate.sh、
    scripts/run_s1b_analyze_gate.sh、scripts/run_monorepo_convention_check.sh）
  CASES:
    - "P3: core/lib/model/ice_server.dart 存在且通过 dart analyze --fatal-infos；IceServer.credential 类型含异步获取语义（Future<String> Function() 或等价）；s1a_dartdoc_coverage_test.dart 下限已抬高且全绿"
    - "P4: core/test/ice_server_provider_guard_test.dart 扫描 ice_server.dart / transport.dart / signaling.dart，出现 Cloudflare / Twilio / Xirsys 字样即红（照抄 signaling_contract_test.dart 的 A2 后端无关手法）"
    - "P6: 在 peer_stream_contract_suite.dart 注入并发违规（如并发下水位无界上涨），确认 R5 测试变红且红在断言上，然后复原"
    - "P7: 逐条列出『注入了什么、红在哪条断言上』写入决定记录（A8 验收）"
    - "P8: 验收命令全绿：bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh && (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test)"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "源码改动以 diff/patch 形式提交；提交信息前缀 feat(s3c-c-preflight)/test(s3c-c-preflight)/docs(s3c-c-preflight)"

VERIFICATION: |
  可机器自动判断的通过条件：
  1. bash scripts/run_s1a_analyze_gate.sh && bash scripts/run_s1b_analyze_gate.sh && bash scripts/run_monorepo_convention_check.sh 全绿，且 S1a 冻结基线 57 未被抬高
  2. (cd core && flutter test) && (cd drift && flutter test) && (cd p2p && flutter test) && (cd firebase && flutter test) 全绿，四包测试只增不减（core 基线 211，P3/P4/P6 后应 ≥211）
  3. P3 的 s1a_dartdoc_coverage_test.dart 下限 ≥ 原 151，实测值 ≥ 原 161
  4. P5 跨仓上报文档存在，写明「哪个文件、哪个仓、缺哪一条」
  5. P6/P7 变异自检记录在 tasks/claude-storage-s3c-c-preflight.md 决定记录，每条含注入点与红色断言
  6. 未触碰禁止项清单中的任何文件/行为
```

---

## 顺序化任务（DEPENDS_ON 线性）

| # | 任务 | 内容 | 门禁（通过才进入下一步） |
|---|---|---|---|
| P3 | `IceServerProvider` 端口 | 落 `core/lib/model/ice_server.dart`，凭证时效性体现于签名；中文 dartdoc；抬高 dartdoc 下限 | `cd core && dart analyze --fatal-infos` 绿 + `flutter test` 绿 + dartdoc 下限测试绿 |
| P4 | A5 源码扫描守卫 | `core/test/ice_server_provider_guard_test.dart` 扫三个 model 文件，供应商名即红 | 新测试绿；先注入供应商名确认红（变异自检）再复原 |
| P5 | 平台配置定位 + 上报 | `find` 查 AndroidManifest.xml / Info.plist / *.entitlements，确认均不在本仓、在 `xuan-qizhengsiyu`；**不跨仓改**，产出上报文档 | 上报文档写明「哪个文件、哪个仓、缺哪一条」 |
| P6 | R5 并发变异自检 | 给 `peer_stream_contract_suite.dart` 注入真并发违规（如 send 并发下水位无界上涨），确认 R5 红，复原 | 注入后 R5 红在断言上（非编译错误），复原后绿 |
| P7 | A8 逐条变异自检 | 每条新测试注入违规 → 确认红 → 复原，逐条写入决定记录 | 记录含注入点 + 红色断言，全部可复现 |
| P8 | 收口 | 四条门禁 + 四包测试全绿；核对 57 冻结基线未抬高；dartdoc 下限已抬高；决定记录收口 | 验收命令全绿（见 ASSERTIONS.CASES 最后一条） |

**依赖**：P3 → P4（P4 扫 P3 的文件，需先有目标文件）→ P5（独立）→ P6 → P7 → P8。P5 与 P6 可并行。

## 停止条件

1. 任一阶段门禁红灯 → 停下修复，修复后重跑该门禁，不得带红进入下一阶段。
2. 变异自检注入违规后**红在编译失败**（而非断言）→ 该测试不合格，停下重写测试。
3. 发现设计稿/契约本身有漏洞或歧义（如 D2/D3 同类问题）→ 在决定记录提异议并停下上报，不许擅自扩范围。
4. 任何需要合并 main / push 远端的动作 → 停下等人类当次授权。
5. 验收标准区（A1–A10）任何一条无法机械满足 → 停下上报，不许降级标准。

## 最终证据（收口时交付）

1. 验收命令完整输出（四条门禁 + 四包测试，退出码全 0）。
2. `git status` 变更清单（预期：P3/P4 新增文件、s1a_dartdoc_coverage_test.dart 抬高、任务纪要决定记录更新、P5 上报文档）。
3. 变异自检记录（P6/P7 逐条：注入了什么、红在哪条断言、如何复原）。
4. P5 跨仓上报文档（哪个文件、哪个仓、缺哪一条）。
5. dartdoc 实测值与下限值（均 ≥ 161 / 151）。

## 一句话启动语

> 启动 P3 开工：读 `tasks/claude-storage-s3c-c-preflight.md` 决定记录 → 落 `core/lib/model/ice_server.dart`（凭证时效性进签名，无供应商名）→ 抬高 dartdoc 下限 → P3 门禁绿后继续 P4。
