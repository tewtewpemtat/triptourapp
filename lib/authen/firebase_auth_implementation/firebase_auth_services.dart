import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'profileStatus': "None",
      });
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'อีเมลนี้ถูกใช้ไปเเล้ว');
      } else {
        Fluttertoast.showToast(msg: 'โปรดกรอกข้อมูลให้ถูกต้อง');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      } else {
        Fluttertoast.showToast(msg: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
      }
    }
    return null;
  }
}
