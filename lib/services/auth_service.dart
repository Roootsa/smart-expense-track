import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserModel?> getUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Mengubah pesan error Firebase menjadi lebih user-friendly
      if (e.code == 'user-not-found') {
        throw 'Akun tidak ditemukan untuk email ini.';
      } else if (e.code == 'wrong-password') {
        throw 'Password salah. Silakan coba lagi.';
      } else if (e.code == 'invalid-credential') {
        throw 'Email atau password salah.';
      } else {
        throw 'Terjadi kesalahan. Silakan coba beberapa saat lagi.';
      }
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': displayName,
          'photoURL': null,
          'createdAt': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email ini sudah terdaftar.';
      } else {
        throw 'Gagal membuat akun. Silakan coba lagi.';
      }
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Akun tidak ditemukan untuk email ini.';
      } else {
        throw 'Gagal mengirim email. Silakan coba lagi.';
      }
    }
  }

  Future<void> updateProfile(String displayName) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // 1. Perbarui nama di Firebase Authentication
      await user.updateDisplayName(displayName);

      // 2. Perbarui nama di dokumen Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
      });
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}