import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/main.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _userProfileImage;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  String _selectedGender = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _showEditDialog(
      String fieldTitle, TextEditingController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แก้ไข $fieldTitle'),
          content: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: fieldTitle),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('บันทึก'),
              onPressed: () {
                // ดำเนินการบันทึกข้อมูลที่ได้รับจาก TextField
                // เช่นเก็บในตัวแปร, ส่งไปยังเซิร์ฟเวอร์, ฯลฯ
                // ตัวอย่างนี้ยังไม่ได้ดำเนินการใดๆ เพียงแค่ปิด Popup
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGenderDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกเพศ'),
          content: Column(
            children: [
              ListTile(
                title: Text('ชาย'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'ชาย';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('หญิง'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'หญิง';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('เพศทางเลือก'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'เพศทางเลือก';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('บันทึก'),
              onPressed: () {
                // ดำเนินการบันทึกข้อมูลที่ได้รับจากการเลือกเพศ
                // เช่นเก็บในตัวแปร, ส่งไปยังเซิร์ฟเวอร์, ฯลฯ
                // ตัวอย่างนี้ยังไม่ได้ดำเนินการใดๆ เพียงแค่ปิด Popup
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text("แก้ไขข้อมูลโปรไฟล์",
            style: GoogleFonts.ibmPlexSansThai(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
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
                  "เปลี่ยนรูปโปรไฟล์",
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'ชื่อจริง',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('ชยันโรต'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('ชื่อจริง', _firstNameController);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'นามสกุล',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('พงถาพร'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('นามสกุล', _lastNameController);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'ชื่อเล่น',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('จรา'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('ชื่อเล่น', _nicknameController);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'เบอร์ติดต่อ',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('123-456-7890'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('เบอร์ติดต่อ', _contactNumberController);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'เพศ',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                      _selectedGender.isNotEmpty ? _selectedGender : 'ไม่ระบุ'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showGenderDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EditProfilePage(),
  ));
}
