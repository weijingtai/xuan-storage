import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/ai/ai_database.dart';
import 'package:persistence_drift/ai/persistence_drift_ai.dart';
import 'package:repository_interface_ai/repository_interface_ai.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AiDatabase db;
  late AiChatHistoryRepository repo;

  setUp(() {
    db = AiDatabase(NativeDatabase.memory());
    repo = DriftAiChatHistoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create session, add message, reload survives', () async {
    // A default persona is seeded by onCreate; fetch it to satisfy the FK.
    final persona = await db.aiPersonasDao.getDefault();
    expect(persona, isNotNull);

    final sessionUuid = await repo.createSession(
      personaUuid: persona!.uuid,
      title: 'test',
    );
    final msgUuid = await repo.addMessage(
      sessionUuid: sessionUuid,
      role: 'user',
      content: 'hello',
    );
    expect(msgUuid, isNotEmpty);

    final messages = await repo.getMessages(sessionUuid);
    expect(messages, hasLength(1));
    expect(messages.single.content, 'hello');

    final session = await repo.getSession(sessionUuid);
    expect(session, isNotNull);
    expect(session!.messageCount, 1);
  });
}
