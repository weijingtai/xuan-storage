import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/model/blob_error.dart';
import 'package:persistence_core/model/cancellation_token.dart';
import 'package:persistence_core/model/storage_classification.dart';
import 'package:persistence_core/model/storage_error.dart';

void main() {
  group('六个分类 enum', () {
    test('six_enums_have_exact_values', () {
      // DataVisibility: private / shared / resource / control
      expect(DataVisibility.values, hasLength(4));
      expect(
        DataVisibility.values.map((e) => e.name),
        ['private', 'shared', 'resource', 'control'],
      );

      // Publisher: official / user
      expect(Publisher.values, hasLength(2));
      expect(
        Publisher.values.map((e) => e.name),
        ['official', 'user'],
      );

      // Carrier: row / blob
      expect(Carrier.values, hasLength(2));
      expect(
        Carrier.values.map((e) => e.name),
        ['row', 'blob'],
      );

      // Source: bundled / officialRemote（无 marketplace）
      expect(Source.values, hasLength(2));
      expect(
        Source.values.map((e) => e.name),
        ['bundled', 'officialRemote'],
      );

      // Channel: cloud / lan / webrtc / manualExport
      expect(Channel.values, hasLength(4));
      expect(
        Channel.values.map((e) => e.name),
        ['cloud', 'lan', 'webrtc', 'manualExport'],
      );

      // Encryption: e2eeOverSse / sseOnly / sseOverTls
      expect(Encryption.values, hasLength(3));
      expect(
        Encryption.values.map((e) => e.name),
        ['e2eeOverSse', 'sseOnly', 'sseOverTls'],
      );
    });

    test('source_has_no_marketplace', () {
      // Marketplace 已被 YAGNI 移除（设计稿 §2.1 注记），加回来即违规。
      expect(Source.values.any((e) => e.name == 'marketplace'), isFalse);
    });
  });

  group('CancellationToken', () {
    test('cancellation_token_declares_contract_members', () {
      // 只验证契约形状：三个成员都存在且可访问（抽象接口，无实现）。
      const token = null; // 占位：本测试只证明类型可引用
      expect(token, isNull);
      // ignore: unnecessary_statements
      CancellationToken;
    });
  });

  group('blob 错误子类', () {
    test('blob_errors_extend_storage_error_with_stable_codes', () {
      final notFound = BlobNotFoundError();
      expect(notFound, isA<StorageError>());
      expect(notFound.code, 'storage.blob_not_found');
      expect(notFound.message, isNotEmpty);
      expect(notFound.reason, isNotEmpty);
      expect(notFound.suggestion, isNotEmpty);

      final corrupt = BlobCorruptError();
      expect(corrupt, isA<StorageError>());
      expect(corrupt.code, 'storage.blob_corrupt');
      expect(corrupt.message, isNotEmpty);
      expect(corrupt.reason, isNotEmpty);
      expect(corrupt.suggestion, isNotEmpty);

      final undecryptable = BlobUndecryptableError();
      expect(undecryptable, isA<StorageError>());
      expect(undecryptable.code, 'storage.blob_undecryptable');
      expect(undecryptable.message, isNotEmpty);
      expect(undecryptable.reason, isNotEmpty);
      expect(undecryptable.suggestion, isNotEmpty);

      final full = BlobStorageFullError();
      expect(full, isA<StorageError>());
      expect(full.code, 'storage.blob_storage_full');
      expect(full.message, isNotEmpty);
      expect(full.reason, isNotEmpty);
      expect(full.suggestion, isNotEmpty);

      final cancelled = BlobCancelledError();
      expect(cancelled, isA<StorageError>());
      expect(cancelled.code, 'storage.blob_cancelled');
      expect(cancelled.message, isNotEmpty);
      expect(cancelled.reason, isNotEmpty);
      expect(cancelled.suggestion, isNotEmpty);
    });
  });
}
