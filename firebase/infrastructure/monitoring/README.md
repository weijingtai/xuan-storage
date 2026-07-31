# 监控告警配置

## GCP Cloud Monitoring 告警通道配置

### Slack 通知通道

1. 进入 GCP Console → Cloud Monitoring → Alerting → Notification Channels
2. 点击 "Add Notification Channel" → Slack
3. 授权 GCP 访问 Slack 工作区
4. 选择目标频道（如 `#xuan-alerts`）
5. 保存通道

### Email 通知通道

1. 进入 GCP Console → Cloud Monitoring → Alerting → Notification Channels
2. 点击 "Add Notification Channel" → Email
3. 输入接收告警的邮箱地址
4. 保存通道（每个邮箱会收到验证邮件，需点击确认）

### 告警策略部署

使用 `gcloud` CLI 部署 `alerts.yaml` 中定义的告警策略：

```bash
gcloud monitoring policies create \
  --policy-from-file=monitoring/policy.json \
  --notification-channels=CHANNEL_ID
```

或通过 Terraform 管理（推荐），参见 `terraform/` 目录。

### 告警级别说明

| 级别     | 含义           | 响应要求         |
| -------- | -------------- | ---------------- |
| critical | 服务可能中断   | 立即响应，5 分钟内 |
| warning  | 接近阈值/异常  | 30 分钟内调查     |

### 预算告警

`budget_alerts` 部分用于 GCP Billing → Budgets & alerts，创建预算时设置对应阈值百分比。
