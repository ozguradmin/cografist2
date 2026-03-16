import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _auth      = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _google    = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authState => _auth.authStateChanges();

  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential?> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _ensureUserDoc(cred.user!);
    return cred;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;
    final googleAuth  = await googleUser.authentication;
    final credential  = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    await _ensureUserDoc(cred.user!);
    return cred;
  }

  static Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  static Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid':        user.uid,
        'email':      user.email,
        'displayName':user.displayName ?? '',
        'createdAt':  FieldValue.serverTimestamp(),
        'examMode':   'yks',
        'streak':     0,
        'badges':     [],
      });
    }
  }

  // Firestore senkronizasyonu
  static Future<void> syncProgress({
    required String uid,
    required int streak,
    required List<String> badges,
    required int totalAnswered,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'streak':        streak,
      'badges':        badges,
      'totalAnswered': totalAnswered,
      'lastSync':      FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
