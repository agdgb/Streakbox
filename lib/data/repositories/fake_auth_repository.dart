import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';
import 'dart:async';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> signInAnonymously() async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}
