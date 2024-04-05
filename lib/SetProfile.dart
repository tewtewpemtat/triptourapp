import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:triptourapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetProfilePage extends StatefulWidget {
  @override
  _SetProfilePageState createState() => _SetProfilePageState();
}

class _SetProfilePageState extends State<SetProfilePage> {
  File? _userProfileImage;
  String? _selectedGender;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  List<String> _genderOptions = ['ชาย', 'หญิง', 'เพศทางเลือก'];
  bool _isSigningUp = false;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "สร้างโปรไฟล์ของคุณ",
          style: GoogleFonts.ibmPlexSansThai(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 100.0,
                backgroundImage: _userProfileImage != null
                    ? FileImage(_userProfileImage!) as ImageProvider<Object>?
                    : AssetImage('assets/profile.jpg'),
                child: InkWell(
                  onTap: _pickImage,
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "เพิ่มรูปโปรไฟล์",
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                style: GoogleFonts.ibmPlexSansThai(),
                decoration: InputDecoration(
                  labelText: "ชื่อ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                style: GoogleFonts.ibmPlexSansThai(),
                decoration: InputDecoration(
                  labelText: "นามสกุล ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: "ชื่อเล่นของคุณ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contactNumberController,
                style: GoogleFonts.ibmPlexSansThai(),
                decoration: InputDecoration(
                  labelText: "เบอร์ติดต่อ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "เพศของคุณ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _updateProfileStatus();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffdb923c),
                  onPrimary: Colors.white,
                  fixedSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSigningUp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "ดำเนินการต่อ",
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  Future<void> _updateProfileStatus() async {
    try {
      if (_userProfileImage == null ||
          _selectedGender == 'null' ||
          _firstNameController.text.isEmpty ||
          _nicknameController.text.isEmpty ||
          _contactNumberController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'โปรดกรอกข้อมูลให้ครบถ้วน');
      } else if (!isNumeric(_contactNumberController.text)) {
        Fluttertoast.showToast(msg: 'โปรดกรอกเบอร์ติดต่อเป็นตัวเลข');
      } else {
        setState(() {
          _isSigningUp = true;
        });
        _uploadImage();
        String? uid = FirebaseAuth.instance.currentUser?.uid;
        // Update profile data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'nickname': _nicknameController.text,
          'contactNumber': _contactNumberController.text,
          'gender': _selectedGender,
          'triplist': 0,
          'friendList': [],
          'profileStatus': 'Completed',
        });
        setState(() {
          _isSigningUp = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> _uploadImage() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      // กำหนด path ใน Firebase Storage
      String storagePath = 'profilepic/$uid/profile.jpg';

      // สร้าง Reference สำหรับอ้างถึง storagePath
      Reference storageReference = FirebaseStorage.instance.ref(storagePath);

      if (_userProfileImage != null) {
        // อัปโหลดไฟล์รูปภาพ
        await storageReference.putFile(_userProfileImage!);

        // ดึง URL ของรูปภาพที่อัปโหลด
        final String imageUrl = await storageReference.getDownloadURL();

        // ทำอะไรกับ imageUrl ต่อไป

        // Update the user document with the image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'profileImageUrl': imageUrl});
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: SetProfilePage(),
    ),
  );
}
