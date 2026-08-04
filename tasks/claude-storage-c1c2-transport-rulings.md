# 任务: storage-c1c2-transport-rulings
负责: claude ｜ 分支: agent/claude/storage-c1c2-transport-rulings ｜ 开工: 2026-08-04
状态: 待验收合并

## 目标
把人类 2026-08-04 对 C1/C2/C3 三条传输层裁定落进设计总纲，消除设计稿内部两处自相矛盾，并把第三方选型（一律不手搓）写进规格。

## 计划
- [x] T1 C1：裁掉「WebRTC 只为 blob 而建」，改为 oplog 与 blob 共用连接（新增 §6.3.1）
- [x] T2 C2：S3b 作为独立子系统取消，降为 S3c 的 `LocalSignaling`（新增 §9.5，改 §9 排期表）
- [x] T3 C3：信令走 `SignalingChannel` 接口，RTDB 只是首个实现（改 §6.3）
- [x] T4 第三方选型表（bonsoir / flutter_webrtc ICE / cryptography / flutter_secure_storage）写进 §9.5
- [x] T5 残留矛盾自查：「只为 blob」「信令复用 Firestore」全稿清除

## 验收标准
- [x] A1 设计稿内不再有「WebRTC 只为 blob 而建」的现行主张（仅 §6.3.1 引述历史）
- [x] A2 设计稿内不再有「信令复用 Firestore」的现行主张
- [x] A3 §9 排期表的 S3b 行标记为取消并给出去向
- [x] A4 §6.3 明确「不得让 WebRTC 实现直接 import firebase_database」
- [x] A5 第三方选型均标注实查版本号，且注明 multicast_dns 不可用（只查不播）
- [x] A6 纯文档改动，不碰任何 .dart，三条既有门禁保持绿

验收命令: bash scripts/run_s1a_analyze_gate.sh && (cd core && flutter test) && bash scripts/run_policy_negative_check.sh

## 当前状态
- [x] 五项全部完成，纯文档改动（仅 1 个 .md），零代码变更
- [x] 三条既有门禁复跑全绿：analyze 门禁 58=58 / core 94 测试 / 负测试 8 行
- 下一步：合并后 S3b/S3c 的五条准入条件全绿，可立即派人开工

## 决定记录
- 2026-08-04 裁定C1（人类采纳推荐）: oplog 与 blob 共用同一条 P2P 连接，三级降级对两者一致适用。理由: 原判断不自洽 —— 若 oplog 只走云端，完全离线的局域网里两台设备能传完 500MB 照片却传不了「这照片属于哪次占卦」的记录，搬运了 blob 却搬不动指向它的引用。另: `StreamKind.oplog` 会变死代码（§3.5 层级论证建立在「一条连接两个消费者」上）；连接已为 blob 建好，oplog 是搭便车、边际成本近零；oplog 走云端会持续泄露「哪条记录存在、何时改、改几次」的元数据。
- 2026-08-04 裁定C2（人类选方案 C）: S3b 作为独立子系统取消，降为 S3c 的 `LocalSignaling` 实现。理由: S3b 唯一独有能力是「完全离线的局域网可用」，而该能力只需「信令不走云」即可获得 —— bonsoir 发现对端 IP:port 后直连交换几 KB 的 SDP，再建 WebRTC DataChannel，全程零外网。走裸 socket 则帧协议/心跳/多路复用/拥塞控制/分片重组全要手写，违反「不手搓」；DataChannel 白送这些。
- 2026-08-04 裁定C3（人类在推荐上加严）: 信令定义 `SignalingChannel` 接口，**RTDB 只是第一个实现**，不得让 Transport 实现直接 import `firebase_database`。理由: 与本仓「Repository + 可切换 RemoteDataSource」既有风格一致，后续可换其他实时数据库或自建服务。选 RTDB 作首实现是因为它有 `onDisconnect()`（掉线自动摘除信令节点，Firestore 无原生等价物），且 SDP/ICE 是高频短写入、按流量计费更合适；`firebase_database` 已在依赖里，零新增。
- 2026-08-04 澄清（已写进 §6.3 供后人）: 信令只传「怎么连」（SDP + ICE candidate），不传任何用户数据，连上后即失效。故信令后端的隐私敏感度远低于数据通道。人类曾问能否存 preference —— 不能，preference 是本机存储，而信令本质是「把连接信息交给另一台设备」，是会合点问题不是存储问题。
- 2026-08-04 NAT 打洞不单独选型: 它就是 `flutter_webrtc` 内建的 ICE 层（STUN 探公网映射 → 候选对同时打洞 → 打不通降 TURN 中继），三步全在库里。唯一需自备的是 TURN，且只有 10–20% 连接会走到。
- 2026-08-04 版本实查（非记忆，curl pub.dev API）: bonsoir 7.1.4 / flutter_webrtc 1.6.0（S6 原锁 1.5.2 已过期，派工前须重锁）/ cryptography 2.9.0 / cryptography_flutter 2.3.4 / flutter_secure_storage 10.3.1 / nsd 5.0.1。

## 踩坑墓地
- 2026-08-04: `multicast_dns 0.3.3+1` **只能查询不能广播**，其源码留有 `// TODO(dnfield): Support queries coming in for published entries.`，包描述亦写明 "performing mDNS **queries**"。用它做设备广播是死路，必须用 bonsoir 或 nsd。已写进 §9.5 防后人再选。

## 冷冻快照
<仅在搁置时由 /hibernate 填写>
