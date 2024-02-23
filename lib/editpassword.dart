import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUser createState() => _EditUser();
}

class _EditUser extends State<EditUser> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String? uid;

  @override
  Widget build(BuildContext context) {
    uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "แก้ไขรหัสผ่าน",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'รหัสผ่านใหม่'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showEditDialog();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xffdb923c),
                          ),
                        ),
                        child: Text(
                          'บันทึก',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // ตัวกันระหว่างปุ่ม
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        child: Text(
                          'ยกเลิก',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog() async {
    String newPassword = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword.isNotEmpty && newPassword == confirmPassword) {
      try {
        // Update password
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

        // Password updated successfully
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('เสร็จสิ้น'),
              content: Text('เปลี่ยนรหัสผ่านสำเร็จ.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ),
                    );
                  },
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Handle error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ข้อผิดพลาด'),
              content: Text('เกิดปัญหาในการบันทึกรหัสผ่าน ${error.toString()}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show an error message or handle the case where passwords don't match
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('เเจ้งเตือน'),
            content: Text('โปรดกรอกรหัสผ่านให้ตรงกัน'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ตกลง'),
              ),
            ],
          );
        },
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: EditUser(),
  ));
}
