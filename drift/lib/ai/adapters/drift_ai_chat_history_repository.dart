import 'package:repository_interface_ai/repository_interface_ai.dart';
import 'package:uuid/uuid.dart';

import '../ai_database.dart';

/// Drift-backed AiChatHistoryRepository over the relocated AiDatabase.
class DriftAiChatHistoryRepository implements AiChatHistoryRepository {
  DriftAiChatHistoryRepository(this._db);

  final AiDatabase _db;

  AiChatSessionContract _sessionToContract(AiChatSession s) =>
      AiChatSessionContract(
        uuid: s.uuid,
        title: s.title,
        personaUuid: s.personaUuid,
        divinationUuid: s.divinationUuid,
        status: s.status,
        contextJson: s.contextJson,
        messageCount: s.messageCount,
        createdAt: s.createdAt,
        lastMessageAt: s.lastMessageAt,
      );

  AiChatMessageContract _messageToContract(AiChatMessage m) =>
      AiChatMessageContract(
        uuid: m.uuid,
        sessionUuid: m.sessionUuid,
        role: m.role,
        content: m.content,
        sequence: m.sequence,
        createdAt: m.createdAt,
        isStreaming: m.isStreaming,
        streamCompletedAt: m.streamCompletedAt,
        toolCallId: m.toolCallId,
        toolCallsJson: m.toolCallsJson,
        usageJson: m.usageJson,
        apiCallUuid: m.apiCallUuid,
      );

  @override
  Future<String> createSession({
    required String personaUuid,
    String? divinationUuid,
    String? title,
    String? contextJson,
  }) async {
    final uuid = const Uuid().v4();
    await _db.aiChatSessionsDao.createSession(
      uuid: uuid,
      personaUuid: personaUuid,
      divinationUuid: divinationUuid,
      title: title,
      contextJson: contextJson,
    );
    return uuid;
  }

  @override
  Future<AiChatSessionContract?> getSession(String uuid) async {
    final s = await _db.aiChatSessionsDao.getByUuid(uuid);
    return s == null ? null : _sessionToContract(s);
  }

  @override
  Future<List<AiChatSessionContract>> listActiveSessions() async {
    final rows = await _db.aiChatSessionsDao.getAllActive();
    return rows.map(_sessionToContract).toList();
  }

  @override
  Future<List<AiChatSessionContract>> listSessionsForDivination(
      String divinationUuid) async {
    final rows = await _db.aiChatSessionsDao.getByDivination(divinationUuid);
    return rows.map(_sessionToContract).toList();
  }

  @override
  Future<String> addMessage({
    required String sessionUuid,
    required String role,
    required String content,
    bool isStreaming = false,
    String? toolCallId,
    String? toolCallsJson,
    String? apiCallUuid,
  }) async {
    final uuid = const Uuid().v4();
    final sequence = await _db.aiChatMessagesDao.getNextSequence(sessionUuid);
    await _db.aiChatMessagesDao.insertMessage(
      uuid: uuid,
      sessionUuid: sessionUuid,
      role: role,
      content: content,
      sequence: sequence,
      isStreaming: isStreaming,
      toolCallId: toolCallId,
      toolCallsJson: toolCallsJson,
      apiCallUuid: apiCallUuid,
    );
    await _db.aiChatSessionsDao.incrementMessageCount(sessionUuid);
    return uuid;
  }

  @override
  Future<List<AiChatMessageContract>> getMessages(String sessionUuid) async {
    final rows = await _db.aiChatMessagesDao.getBySession(sessionUuid);
    return rows.map(_messageToContract).toList();
  }

  @override
  Future<List<AiChatMessageContract>> getLastMessages(
      String sessionUuid, int count) async {
    final rows = await _db.aiChatMessagesDao.getLastN(sessionUuid, count);
    return rows.map(_messageToContract).toList();
  }

  @override
  Stream<List<AiChatMessageContract>> watchMessages(String sessionUuid) {
    return _db.aiChatMessagesDao
        .watchBySession(sessionUuid)
        .map((rows) => rows.map(_messageToContract).toList());
  }

  @override
  Future<void> updateMessageContent(String messageUuid, String content) =>
      _db.aiChatMessagesDao.updateContent(messageUuid, content);

  @override
  Future<void> appendToMessage(String messageUuid, String content) =>
      _db.aiChatMessagesDao.appendContent(messageUuid, content);

  @override
  Future<void> completeStreamingMessage(String messageUuid,
          {String? usageJson}) =>
      _db.aiChatMessagesDao
          .completeStreaming(messageUuid, usageJson: usageJson);

  @override
  Future<void> updateSessionTitle(String sessionUuid, String title) =>
      _db.aiChatSessionsDao.updateTitle(sessionUuid, title);

  @override
  Future<void> updateSessionPersona(String sessionUuid, String personaUuid) =>
      _db.aiChatSessionsDao.updatePersona(sessionUuid, personaUuid);

  @override
  Future<void> archiveSession(String sessionUuid) =>
      _db.aiChatSessionsDao.archive(sessionUuid);

  @override
  Future<void> deleteSession(String sessionUuid) async {
    await _db.aiChatMessagesDao.deleteBySession(sessionUuid);
    await _db.aiChatSessionsDao.softDelete(sessionUuid);
  }
}
