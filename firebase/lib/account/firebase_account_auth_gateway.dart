import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:repository_interface_account/repository_interface_account.dart';

/// Firebase-backed AccountAuthGateway that resolves appUserId through
/// the injected AppUserIdResolver.
final class FirebaseAccountAuthGateway implements AccountAuthGateway {
  FirebaseAccountAuthGateway({
    required fb.FirebaseAuth firebaseAuth,
    required AppUserIdResolver appUserIdResolver,
  })  : _auth = firebaseAuth,
        _resolver = appUserIdResolver;

  final fb.FirebaseAuth _auth;
  final AppUserIdResolver _resolver;

  @override
  Stream<AccountSession?> watchSession() {
    return _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) return null;
      return _buildSession(user);
    });
  }

  @override
  Future<AccountSession> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.unknown,
          message: 'FirebaseAuth returned null user',
        );
      }
      return _buildSession(user);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<AccountSession> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.unknown,
          message: 'FirebaseAuth returned null user',
        );
      }
      return _buildSession(user);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<AccountSession> createUserWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.unknown,
          message: 'FirebaseAuth returned null user',
        );
      }
      return _buildSession(user);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<AccountSession> linkAnonymousToEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final user = _auth.currentUser;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.userNotFound,
          message: 'No anonymous user to link',
        );
      }
      final result = await user.linkWithCredential(credential);
      final linkedUser = result.user;
      if (linkedUser == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.unknown,
          message: 'Link returned null user',
        );
      }
      return _buildSession(linkedUser);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.userNotFound,
          message: 'No current user to update password',
        );
      }
      await user.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  @override
  Future<void> deleteCurrentAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AccountRepositoryError(
          code: AccountErrorCode.userNotFound,
          message: 'No current user to delete',
        );
      }
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw _translateError(e);
    }
  }

  Future<AccountSession> _buildSession(fb.User user) async {
    final appUserId = await _resolver.resolve(
      providerUserId: ProviderUserId(user.uid),
      providerId: 'firebase',
    );

    return AccountSession(
      appUserId: appUserId,
      providerUserId: ProviderUserId(user.uid),
      kind: user.isAnonymous ? AccountKind.anonymous : AccountKind.registered,
      providerId: 'firebase',
      issuedAt: DateTime.now().toUtc(),
      email: user.email,
      lastRefreshedAt: DateTime.now().toUtc(),
    );
  }

  AccountRepositoryError _translateError(fb.FirebaseAuthException e) {
    AccountErrorCode code;
    switch (e.code) {
      case 'user-not-found':
        code = AccountErrorCode.userNotFound;
        break;
      case 'wrong-password':
      case 'invalid-credential':
        code = AccountErrorCode.invalidCredential;
        break;
      case 'email-already-in-use':
        code = AccountErrorCode.emailAlreadyInUse;
        break;
      case 'network-request-failed':
        code = AccountErrorCode.networkUnavailable;
        break;
      case 'requires-recent-login':
        code = AccountErrorCode.recentLoginRequired;
        break;
      default:
        code = AccountErrorCode.unknown;
    }
    return AccountRepositoryError(
      code: code,
      message: e.message ?? e.code,
      cause: e,
    );
  }
}
