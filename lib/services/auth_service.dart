import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  User? get currentUser => _auth?.currentUser;
  String? get userId => _auth?.currentUser?.uid;

  Future<void> signInAnonymously() async {
    final auth = _auth;
    if (auth == null || auth.currentUser != null) return;
    await auth.signInAnonymously();
  }
}
