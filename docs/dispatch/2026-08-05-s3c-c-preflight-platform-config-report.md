# S3c-c-preflight P5：平台配置定位报告（跨仓任务）

> 生成于 2026-08-05，来源 ACT `docs/opsx/changes/s3c-c-preflight/ACT-Protocol-Document.md` P5。
> 本报告只**定位**，不修改任何消费方仓库文件（铁律：不跨仓改）。

## 结论

**本仓（xuan-storage）零命中**：`AndroidManifest.xml` / `Info.plist` / `*.entitlements`
三类文件在本仓一个都没有 —— 平台网络配置全在消费方 app 仓。

**三处配置的真实位置**：全部在消费方 app 仓 **`xuan-qizhengsiyu`（即 xuan-shell）**。

## 逐条明细

### 1. Android：网络权限不全（WebRTC 建连必需）

| 项 | 位置 | 现状 | 缺口 |
|---|---|---|---|
| 基础联网 | `.android/app/src/main/AndroidManifest.xml:9` | ✅ 已有 `android.permission.INTERNET` | — |
| 网络状态感知 | 同一文件 | ❌ 无 `android.permission.ACCESS_NETWORK_STATE` | WebRTC ICE 需要查询网络状态，缺失可能导致候选收集异常 |
| Wi-Fi / mDNS 发现 | 同一文件 | ❌ 无 `android.permission.ACCESS_WIFI_STATE`、`android.permission.CHANGE_WIFI_MULTICAST_STATE` | S3b 局域网发现（mDNS/Bonjour）在 Android 上需要组播权限，缺失则发现不到 LAN peer |

> 注：`.android/` 是 Flutter 的 android 壳工程；`example/android/` 与
> `companion_system/android/` 是同一仓库内的其他工程，主 app 以 `.android/` 为准。

### 2. iOS：本地网络权限完全缺失（iOS 14+ 硬性要求）

| 项 | 位置 | 现状 | 缺口 |
|---|---|---|---|
| 本地网络弹窗文案 | `.ios/Runner/Info.plist` | ❌ 无 `NSLocalNetworkUsageDescription` | iOS 14+ 访问本地网络（LAN peer 直连 / mDNS）必须弹窗说明，缺失则**权限弹窗不出现、连接静默失败** |
| Bonjour 服务类型 | 同一文件 | ❌ 无 `NSBonjourServices` 数组 | mDNS 服务发现需要声明服务类型（如 `_xuan._tcp`），缺失则发现不了 LAN peer |
| ATS 本地网络例外 | 同一文件 | ❌ 无 `NSAppTransportSecurity` → `NSAllowsLocalNetworking` | 直连非 HTTPS 本地端点时 ATS 可能拦截 |

> 注：`.ios/` 是 Flutter 的 iOS 壳工程（主配置），`example/ios/`、`companion_system/ios/`
> 为同仓其他工程。

### 3. macOS：沙盒网络权限不对称

| 项 | 位置 | 现状 | 缺口 |
|---|---|---|---|
| Debug 沙盒网络 | `example/macos/Runner/DebugProfile.entitlements:9-11` | ✅ 已有 `com.apple.security.network.server` + `com.apple.security.network.client` | — |
| Release 沙盒网络 | `example/macos/Runner/Release.entitlements:9` | ⚠️ 只有 `com.apple.security.network.client` | 缺 `network.server` —— 发布版无法监听入站连接（LAN peer 直连需要） |

## 建议的跨仓任务清单（供人类派发，本任务不做）

1. **xuan-qizhengsiyu**：`.android/app/src/main/AndroidManifest.xml` 补
   `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE` / `CHANGE_WIFI_MULTICAST_STATE` 三条权限。
2. **xuan-qizhengsiyu**：`.ios/Runner/Info.plist` 补 `NSLocalNetworkUsageDescription`（中文文案）、
   `NSBonjourServices`（服务类型待 S3b 定）、ATS `NSAllowsLocalNetworking` 例外。
3. **xuan-qizhengsiyu**：`example/macos/Runner/Release.entitlements` 补
   `com.apple.security.network.server`，与 DebugProfile 对齐。
4. 时机建议：与 S3b（局域网发现）/ S3c-c（WebRTC 实现）开工前处理；S6 交付前不阻塞。

## 验证方式

```bash
# 在 xuan-qizhengsiyu 仓库复现本报告结论：
find . -path ./.git -prune -o -name AndroidManifest.xml -print | head
find . -path ./.git -prune -o -name Info.plist -print | head
find . -path ./.git -prune -o -name '*.entitlements' -print | head
grep -n 'uses-permission' .android/app/src/main/AndroidManifest.xml
grep -n 'NSLocalNetworkUsageDescription\|NSBonjourServices' .ios/Runner/Info.plist   # 预期零命中
grep -n 'network.server\|network.client' example/macos/Runner/Release.entitlements  # 预期只命中 client
```
