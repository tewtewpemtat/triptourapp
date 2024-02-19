import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
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
        Fluttertoast.showToast(msg: 'อีเมลหรือรหัสผ่านผิดพลาด');
      } else {
        Fluttertoast.showToast(msg: 'โปรดกรอกข้อมูลให้ถูกต้อง');
      }
    }
    return null;
  }
}
