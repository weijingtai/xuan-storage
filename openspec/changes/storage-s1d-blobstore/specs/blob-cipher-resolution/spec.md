## ADDED Requirements

### Requirement: Asynchronous cipher resolution
resolver SHALL 异步按 scope 与 visibility 返回 cipher；public SHALL 返回 identity，private SHALL 使用注入的安全密钥实现或明确失败。

#### Scenario: Public identity cipher
- **WHEN** 调用方 await public resolver 并加解密 chunk
- **THEN** 字节不变且返回列表不与输入共享可变引用

#### Scenario: Private key unavailable
- **WHEN** private scope 的密钥不可用
- **THEN** 读取返回 undecryptable 而不是 corrupt 或 absent
