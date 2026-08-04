/// blob 落地层的 drift 表定义（S1d，设计稿 §3.2 + §6.4）。
///
/// 三张表分工：
/// - [BlobMetas]：blob 元数据（一 blob 一行）。
/// - [BlobChunks]：chunk 持有集合（一 chunk 一行，「存在即持有」）。
/// - [BlobRefs]：引用计数（记录 × blob 的多对多关系）。
///
/// 设计要点（完整论证见 `docs/superpowers/specs/2026-08-03-s1d-blob-store-design.md`）：
/// - **字节不存这里。** 字节落文件系统，本表只存元数据与索引。
///   理由：SQLite 存大 BLOB 后删除不会缩小文件，回收需 `VACUUM`
///   （需等大临时空间 + 全程写锁），与 §6.4 的常规 GC 语义冲突。
/// - **`refCount` 不冗余存储**，实时由 [BlobRefs] 计数得出。
///   冗余计数器是引用计数错乱的头号来源，而引用计数错乱会导致误删用户数据。
library;

import 'package:drift/drift.dart';

import 'blob_datetime_converter.dart';

/// blob 元数据表。
///
/// 约定：
/// - 主键为 `cipher_manifest_id`（私有 blob 是随机 UUID，公开 blob 等于
///   `plaintextSha256`），**不是** `plaintextSha256` —— 后者按契约
///   `blob_types.dart:22` 永不作为对象名，此处保持同一思路。
/// - 时间列一律 UTC。
@DataClassName('BlobMetaRow')
class BlobMetas extends Table {
  @override
  String get tableName => 't_blob_meta';

  /// 密文清单 id。私有 blob 为随机 UUID；公开 blob 等于明文 sha256。
  TextColumn get cipherManifestId => text().named('cipher_manifest_id')();

  /// 作用域 uid，按用户隔离。
  TextColumn get scopeUid => text().named('scope_uid')();

  /// 明文 sha256（hex）。**仅作本地去重索引，永不作远端对象名。**
  TextColumn get plaintextSha256 => text().named('plaintext_sha256')();

  /// 解密时定位实现的 cipher 标识。
  TextColumn get cipherId => text().named('cipher_id')();

  /// 加密时的密钥版本，支持轮换后解旧数据。
  IntColumn get keyVersion => integer().named('key_version')();

  /// 明文总字节数。
  IntColumn get totalBytes => integer().named('total_bytes')();

  /// chunk 总数。
  IntColumn get chunkCount => integer().named('chunk_count')();

  /// MIME 类型。
  TextColumn get mimeType => text().named('mime_type')();

  /// 所在区：0 = sourceOfTruth（真相源，不可自动回收），1 = cache（可 LRU 清理）。
  IntColumn get tier => integer().named('tier')();

  /// 可见性：0 = private（真加密），1 = public（identity cipher）。
  IntColumn get visibility => integer().named('visibility')();

  /// 生命周期状态：0 = staged，1 = committed，2 = orphaned。
  ///
  /// 约定：`staged` 经 `reconcileRefs` 转 `committed`（契约规定这是唯一途径）。
  IntColumn get status =>
      integer().withDefault(const Constant(0)).named('status')();

  /// 进入 staged 的时刻（UTC），TTL 计时起点。
  DateTimeColumn get stagedAtUtc =>
      dateTime().map(const BlobUtcDateTimeConverter()).named('staged_at_utc')();

  /// 最近访问时刻（UTC），LRU 逐出的排序依据。
  DateTimeColumn get lastAccessAtUtc => dateTime()
      .map(const BlobUtcDateTimeConverter())
      .named('last_access_at_utc')();

  /// 业务外部 id（可空）。紧急下架按此逐出，因下发的黑名单是业务 id 而非句柄。
  TextColumn get externalId => text().nullable().named('external_id')();

  @override
  Set<Column> get primaryKey => {cipherManifestId};
}

/// blob 的 chunk 持有集合表。
///
/// 约定：
/// - **「存在即持有」**：行存在 == 该 chunk 已落盘且校验通过。
///   因此 `presentChunks` 是一次主键前缀扫描，差集为
///   `{0..chunkCount-1} - present`。
/// - 不用位图列：位图无法承载每 chunk 独立 sha256，而定位损坏
///   （`BlobCorrupt(Set<int> badChunks)` 要指出**哪些** chunk 坏了）需要它。
@DataClassName('BlobChunkRow')
class BlobChunks extends Table {
  @override
  String get tableName => 't_blob_chunk';

  /// 所属 blob 的密文清单 id。
  TextColumn get cipherManifestId => text().named('cipher_manifest_id')();

  /// chunk 序号，从 0 开始。
  IntColumn get chunkIndex => integer().named('chunk_index')();

  /// 该 chunk 的密文字节长度，写后校验用。
  IntColumn get cipherBytesLen => integer().named('cipher_bytes_len')();

  /// 该 chunk 的独立 sha256（hex），用于定位损坏到具体 chunk。
  TextColumn get chunkSha256 => text().named('chunk_sha256')();

  @override
  Set<Column> get primaryKey => {cipherManifestId, chunkIndex};
}

/// blob 引用计数表（记录 × blob）。
///
/// 约定：
/// - 主键 `(owner_record_uuid, cipher_manifest_id)` 使 `reconcileRefs` 的
///   **幂等性是结构性的**：全量声明 = 「把该 owner 的行集合替换为 handles」，
///   实现为单事务内 `DELETE WHERE owner=?` + 全量 `INSERT`，连调两次结果必然相同。
/// - 引用计数**不冗余存储**，实时 `COUNT(*) WHERE cipher_manifest_id=?` 得出。
/// - 本表**不含** peerId/deviceId 维度：引用计数是单设备本地语义。
///   跨设备引用计数不收敛是已知未解问题（设计稿 §6.4 末 + §10 待决），S1d 不解决。
@DataClassName('BlobRefRow')
class BlobRefs extends Table {
  @override
  String get tableName => 't_blob_ref';

  /// 持有引用的记录 uuid。
  TextColumn get ownerRecordUuid => text().named('owner_record_uuid')();

  /// 被引用 blob 的密文清单 id。
  TextColumn get cipherManifestId => text().named('cipher_manifest_id')();

  @override
  Set<Column> get primaryKey => {ownerRecordUuid, cipherManifestId};
}
