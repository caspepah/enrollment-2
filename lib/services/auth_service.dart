import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
        );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email & password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      
      // Store additional user data in Firestore
      await _firestore.collection('students').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'enrolledSubjects': [], // Initialize empty enrolled subjects array
        'totalCredits': 0,
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Weak Password';
      } else if (e.code == 'email-already-in-use') {
        throw 'That email already in user';
      } else if (e.code == 'invalid-email') {
        throw 'Invalid Email';
      }
      throw e.message ?? 'Error occured';
    }
  }

  //Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}