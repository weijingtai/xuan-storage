# DTLS 指纹探路报告（S3c-c 前置① · 最大未知数探明）

> 探路子任务：框架计划 §五 ｜ 执行日期：2026-08-07 ｜ 分支：`feat/s3c-c-webrtc-impl`
> 结论先行：**③ 观测指纹可得，步骤 3 不阻断**。三个指纹全部实测取到（Chrome 平台）。

## 一、探什么

flutter_webrtc 能否取到三个指纹（决定步骤 3 channel binding 成败）：

| # | 指纹 | 来源 | 探路前确定性 |
|---|---|---|---|
| ① | 本端 DTLS 证书指纹 | 本端 SDP `a=fingerprint` 行 | 高（SDP 必有） |
| ② | 对端**声明**的证书指纹 | 对端 answer SDP `a=fingerprint` 行 | 高（SDP 必有） |
| ③ | DTLS 握手后**观测到**的对端证书指纹 | getStats 的 certificate 报告 | **低（最大未知数）** |

## 二、环境与依赖

- `flutter_webrtc 1.6.0`（2026-07-29 发布，pub.dev 最新稳定版；框架计划标注的 1.5.2 已过期）
- 实测平台：macOS Chrome（`flutter test --platform chrome`）
- 原生实现核实：Android 走 libwebrtc `RTCStatsReport`（`PeerConnectionObserver.handleStatsReport`
  透传全部 stats 成员，含 certificate 类型）；Web 走浏览器原生 `RTCStatsReport`
  （dart_webrtc 全字段透传）；iOS/macOS 同 libwebrtc 体系

## 三、API 签名（实测/源码核实）

```dart
// webrtc_interface 1.5.1（flutter_webrtc 1.6.0 依赖）
Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [Map<String, dynamic> constraints]);
Future<RTCSessionDescription?> getLocalDescription();
Future<RTCSessionDescription?> getRemoteDescription();
Future<List<StatsReport>> getStats([MediaStreamTrack? track]);

// StatsReport（rtc_stats_report.dart）：type 字段区分报告类型
class StatsReport {
  final String id;
  final String type;          // 'transport' / 'certificate' / ...
  final double timestamp;
  final Map<dynamic, dynamic> values;  // 全字段透传
}
```

## 四、取值路径与时机（实测证据）

**① 本端指纹**：`getLocalDescription().sdp` 解析 `a=fingerprint:` 行。
时机：`createOffer` + `setLocalDescription` 后即可取（SDP 阶段）。

**② 对端声明指纹**：`getRemoteDescription().sdp` 解析 `a=fingerprint:` 行。
时机：收到对端 answer 并 `setRemoteDescription` 后即可取（SDP 阶段）。

**③ 观测指纹**：`getStats()` → 找 `type == 'transport'` 报告的
`values['remoteCertificateId']` → 找 `id == remoteCertificateId` 的
`type == 'certificate'` 报告 → 其 `values['fingerprint']`。
时机：**必须等 `connectionState == connected`（DTLS 握手完成）之后**，
否则 transport/certificate 报告未产出。

### 实测输出（Chrome，两条 RTCPeerConnection 经 DataChannel 握手）

```
SPIKE ① 本端指纹: sha-256 37:79:12:23:EA:8D:1C:82:5B:DF:48:02:74:4E:FA:ED:...
SPIKE ② 对端声明指纹: sha-256 28:E6:8F:57:49:C2:EB:C3:2A:56:5D:4E:78:26:14:29:...
SPIKE ③ 观测指纹: sha-256 28:E6:8F:57:49:C2:EB:C3:2A:56:5D:4E:78:26:14:29:...
SPIKE stats types: {certificate, candidate-pair, data-channel, local-candidate,
                    remote-candidate, peer-connection, transport}
```

- ③ 与 ② 一致：无 MITM 时观测 == 声明（符合预期；MITM 时攻击者改 SDP 声明，
  但 DTLS 实际证书指纹（③）不会被攻击者控制，比对即可发现）
- stats types 集合含 `certificate` + `transport`，两条路径均实测可用

## 五、格式注意（契约合规）

- SDP `a=fingerprint` 行格式：`a=fingerprint:sha-256 AA:BB:...`（**带**算法名前缀）
- stats `certificate.fingerprint` 值：**纯** `AA:BB:...`（**不带**算法名，
  算法名在 `values['fingerprintAlgorithm']`，实测为 `sha-256`）
- **实现必须**用 `'$fingerprintAlgorithm $fingerprint'` 拼成
  `'sha-256 AA:BB:...'`，才能填进 `ChannelBinding.localCertificateFingerprint`
  （契约格式：算法名内联，Q3 v2 已删 algorithm 字段）

## 六、结论与对步骤 3 的落点

1. **③ 可得，步骤 3 不阻断**（框架计划 §八 第一停止条件不触发）
2. 无需新增 platform channel：`getStats()` 即现成 API（原生走 flutter_webrtc 既有
   method channel，Web 走浏览器 stats）
3. 步骤 3 实现要点：
   - 声明指纹取 `PairingResult.peerDeclaredCertificateFingerprint`（配对验签结果，
     人类裁定），**不取** SDP 明文
   - 观测指纹按本报告 §四 ③ 路径取（握手完成后），拼上算法名前缀
   - 本端指纹（①）填 `ChannelBinding.localCertificateFingerprint`，供配对签名用
4. spike 测试落位 `p2p/test/dtls_fingerprint_spike_test.dart`
   （`@Tags(['integration'])` 默认跳过；人工触发：
   `cd p2p && flutter test --platform chrome --run-skipped test/dtls_fingerprint_spike_test.dart`）

## 七、风险与残余未知

- 本实测在 **Web（Chrome）** 平台；Android/iOS/macOS 的原生 stats 结构经源码核实
  （libwebrtc RTCStatsReport 同样含 certificate + transport），但**未实机验证**。
  步骤 2/3 在原生平台联调时若 `remoteCertificateId` 缺位，须按框架计划停止条件上报
- 非 trickle 交换（等 ICE gathering complete）在本 spike 可用；生产实现应支持
  trickle ICE（`IceCandidateEnvelope` 语义），时序见信令契约套件
