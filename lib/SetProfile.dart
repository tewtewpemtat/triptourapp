import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/authen/login.dart';
import 'package:triptourapp/main.dart';

class SetProfilePage extends StatefulWidget {
  @override
  _SetProfilePageState createState() => _SetProfilePageState();
}

class _SetProfilePageState extends State<SetProfilePage> {
  File? _userProfileImage;
  String? _selectedGender;

  List<String> _genderOptions = ['ชาย', 'หญิง', 'เพศทางเลือก'];

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
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
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
                    : AssetImage('assets/cat.jpg'),
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
                decoration: InputDecoration(
                  labelText: "ชื่อเล่นของคุณ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
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
                onPressed: () {
                  // ทำงานเมื่อกดปุ่ม "ดำเนินการต่อ"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffdb923c),
                  onPrimary: Colors.white,
                  fixedSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "ดำเนินการต่อ",
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetProfilePage(),
                    ),
                  );
                },
                child: Text(
                  "ล้างข้อมูลเพื่อระบุข้อมูลการสร้างทริปใหม่",
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: SetProfilePage(),
    ),
  );
}
