import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> loginUser(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> updateUser(String newEmail, String newPassword) async {
    final user = _auth.currentUser;
    await user?.updateEmail(newEmail);
    await user?.updatePassword(newPassword);
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    await user?.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
