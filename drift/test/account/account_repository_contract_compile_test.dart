import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/account/account_database.dart';
import 'package:persistence_drift/account/drift_account_identity_link_repository.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:repository_interface_account/repository_interface_account.dart';

void main() {
  test('Drift account identity links compile and execute public get/put', () async {
    final database = AccountDatabase(NativeDatabase.memory());
    final AccountIdentityLinkRepository repository =
        DriftAccountIdentityLinkRepository(database);
    final context = RequestContext(scopeUid: 'account-contract');
    final link = AccountIdentityLink(
      anonymousAppUserId: const AccountUserId('anon-contract'),
      registeredAppUserId: const AccountUserId('registered-contract'),
      providerId: 'contract-test',
      linkedAt: DateTime.utc(2026, 8, 28),
    );

    final putResult = await repository.put(link, context);
    expect(putResult, isA<Ok<Rev>>());
    expect((putResult as Ok<Rev>).value.value, 'anon-contract');

    final getResult = await repository.get('anon-contract', context);
    expect(getResult, isA<Ok<AccountIdentityLink?>>());
    final retrieved = (getResult as Ok<AccountIdentityLink?>).value;
    expect(retrieved, isNotNull);
    expect(retrieved!.anonymousAppUserId, link.anonymousAppUserId);
    expect(retrieved.registeredAppUserId, link.registeredAppUserId);
    expect(retrieved.providerId, link.providerId);
    expect(retrieved.linkedAt.isAtSameMomentAs(link.linkedAt), isTrue);

    await database.close();
  });
}
