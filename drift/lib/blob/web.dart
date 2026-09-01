/// Blob byte backend for web platforms.
///
/// Chunks are persisted in a versioned IndexedDB database
/// ([kBlobBytesDatabaseName] / [kBlobBytesStoreName]) as binary
/// structured-clone typed-array values. A single final key's read-write
/// transaction is the atomic commit unit — there is no tmp-key / rename
/// dance, so [WebBlobByteBackend.orphanChunkPaths] is always empty.
///
/// Keys are `'$manifestDir/$index'`: [manifestDir] already carries the
/// logical root namespace plus scopeUid / cipherManifestId from the
/// Blob layer, and the chunk index completes the key. Encryption, hashing,
/// metadata, staged/committed state and refs stay entirely in the existing
/// Blob/UoW layers; this backend only does chunk byte CRUD.
///
/// Read misses map to [BlobNotFoundError]; transaction/request errors are
/// propagated as [IdbBlobStorageException] with the raw DOMException
/// name/message — never swallowed, never turned into empty-byte success.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

// Narrow import: BlobNotFoundError comes from the pure-Dart model layer.
// The persistence_core barrel would transitively import Flutter, which a
// plain dart2js compile (`dart test -p chrome`) cannot handle.
import 'package:persistence_core/model/blob_error.dart';
// The public `package:web/web.dart` barrel also exports the legacy helpers
// layer (`src/helpers/http.dart`) whose removed `jsify` API does not compile
// on the current SDK / DDC test compiler. This backend only needs the DOM
// surface (IndexedDB + window), which lives in the idl-generated `dom`
// library, so we import that narrower entry and document the exception.
// ignore: implementation_imports
import 'package:web/src/dom.dart' as web;

import 'blob_byte_backend_contract.dart';

/// Versioned IndexedDB database name (fixed by the design contract).
const String kBlobBytesDatabaseName = 'xuan_blob_bytes_v1';

/// Object store inside [kBlobBytesDatabaseName].
const String kBlobBytesStoreName = 'chunks';

/// Schema version of [kBlobBytesDatabaseName].
const int kBlobBytesDatabaseVersion = 1;

/// Failure carrying the original IndexedDB error (never swallowed).
final class IdbBlobStorageException implements Exception {
  const IdbBlobStorageException(this.message, {this.name});

  final String message;
  final String? name;

  @override
  String toString() => 'IdbBlobStorageException(name: $name, message: $message)';
}

/// IndexedDB-backed [BlobByteBackend].
final class WebBlobByteBackend implements BlobByteBackend {
  WebBlobByteBackend();

  Future<web.IDBDatabase>? _openFuture;

  /// Opens (and caches) the versioned database; `upgradeneeded` creates the
  /// object store exactly once.
  Future<web.IDBDatabase> _open() => _openFuture ??= _doOpen();

  Future<web.IDBDatabase> _doOpen() async {
    final request = web.window.indexedDB.open(
      kBlobBytesDatabaseName,
      kBlobBytesDatabaseVersion,
    );
    request.onupgradeneeded = ((web.Event event) {
      final db = request.result! as web.IDBDatabase;
      if (!db.objectStoreNames.contains(kBlobBytesStoreName)) {
        db.createObjectStore(kBlobBytesStoreName);
      }
    }).toJS;
    await _awaitRequest(request);
    return request.result! as web.IDBDatabase;
  }

  String _key(String manifestDir, int index) => '$manifestDir/$index';

  /// Exact manifest prefix, including the trailing separator, so adjacent
  /// manifest names (e.g. `m1` vs `m1-other`) never bleed into each other.
  String _prefix(String manifestDir) => '$manifestDir/';

  /// Completes with the request result on success; throws on error, carrying
  /// the raw DOMException name/message (requests inside an aborted
  /// transaction surface the same way).
  Future<JSAny?> _awaitRequest(web.IDBRequest request) {
    final completer = Completer<JSAny?>();
    request.onsuccess = ((web.Event event) {
      if (!completer.isCompleted) completer.complete(request.result);
    }).toJS;
    request.onerror = ((web.Event event) {
      if (completer.isCompleted) return;
      final error = request.error;
      completer.completeError(
        IdbBlobStorageException(
          error?.message ?? 'IndexedDB request failed',
          name: error?.name,
        ),
      );
    }).toJS;
    return completer.future;
  }

  /// Runs [action] inside one transaction on the chunks store and waits for
  /// the transaction to finish; a failed transaction aborts the future.
  Future<T> _inTransaction<T>(
    String mode,
    Future<T> Function(web.IDBObjectStore store) action,
  ) async {
    final db = await _open();
    final tx = db.transaction(kBlobBytesStoreName.toJS, mode);
    final store = tx.objectStore(kBlobBytesStoreName);

    final completed = Completer<void>();
    void finish([Object? error]) {
      if (completed.isCompleted) return;
      if (error == null) {
        completed.complete();
      } else {
        completed.completeError(error);
      }
    }

    tx.oncomplete = ((web.Event event) => finish()).toJS;
    tx.onabort = ((web.Event event) {
      final e = tx.error;
      finish(
        IdbBlobStorageException(
          e?.message ?? 'IndexedDB transaction aborted',
          name: e?.name,
        ),
      );
    }).toJS;
    tx.onerror = ((web.Event event) {
      final e = tx.error;
      finish(
        IdbBlobStorageException(
          e?.message ?? 'IndexedDB transaction errored',
          name: e?.name,
        ),
      );
    }).toJS;

    // Attach the completion listeners before running the action so early
    // failures are captured. A write issuing multiple requests queues them
    // synchronously inside one transaction (single atomic commit).
    final value = await action(store);
    await completed.future;
    return value;
  }

  @override
  Future<void> writeChunk(String manifestDir, int index, List<int> bytes) async {
    await _inTransaction<void>('readwrite', (store) async {
      await _awaitRequest(
        store.put(
          (bytes is Uint8List ? bytes : Uint8List.fromList(bytes)).toJS,
          _key(manifestDir, index).toJS,
        ),
      );
    });
  }

  @override
  Future<List<int>> readChunk(String manifestDir, int index) async {
    final result = await _inTransaction<JSAny?>('readonly', (store) async {
      return _awaitRequest(store.get(_key(manifestDir, index).toJS));
    });
    if (result == null) {
      throw BlobNotFoundError();
    }
    return (result as JSUint8Array).toDart;
  }

  @override
  Future<void> deleteChunk(String manifestDir, int index) async {
    await _inTransaction<void>('readwrite', (store) async {
      await _awaitRequest(store.delete(_key(manifestDir, index).toJS));
    });
  }

  @override
  Future<Set<int>> listChunks(String manifestDir) async {
    final keys = await _inTransaction<JSArray>('readonly', (store) async {
      final result = await _awaitRequest(store.getAllKeys());
      return result! as JSArray;
    });
    final prefix = _prefix(manifestDir);
    final indices = <int>{};
    for (final key in keys.toDart) {
      final raw = (key as JSString).toDart;
      if (!raw.startsWith(prefix)) continue;
      final index = int.tryParse(raw.substring(prefix.length));
      if (index != null) indices.add(index);
    }
    return indices;
  }

  @override
  Future<void> deleteManifest(String manifestDir) async {
    await _inTransaction<void>('readwrite', (store) async {
      final keys = (await _awaitRequest(store.getAllKeys()))! as JSArray;
      final prefix = _prefix(manifestDir);
      for (final key in keys.toDart) {
        final raw = (key as JSString).toDart;
        if (!raw.startsWith(prefix)) continue;
        // Queue every delete synchronously: one transaction, one atomic
        // commit for the whole manifest.
        store.delete(raw.toJS);
      }
    });
  }

  @override
  Future<Set<String>> orphanChunkPaths(String rootDir) async => <String>{};

  @override
  Future<int> manifestSize(String manifestDir) async {
    // getAllKeys and getAll iterate the store in the same key order, so
    // zipping them keeps key/value alignment; filter by exact prefix.
    final keysAndValues = await _inTransaction<(JSArray, JSArray)>(
      'readonly',
      (store) async {
        final keysR = (await _awaitRequest(store.getAllKeys()))! as JSArray;
        final valuesR = (await _awaitRequest(store.getAll()))! as JSArray;
        return (keysR, valuesR);
      },
    );
    final prefix = _prefix(manifestDir);
    final keyList = keysAndValues.$1.toDart;
    final valueList = keysAndValues.$2.toDart;
    var total = 0;
    for (var i = 0; i < keyList.length; i++) {
      final raw = (keyList[i] as JSString).toDart;
      if (raw.startsWith(prefix)) {
        total += (valueList[i] as JSUint8Array).toDart.length;
      }
    }
    return total;
  }
}