import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/privatechat.dart';

class ShowProfilePage extends StatefulWidget {
  final String friendUid;
  ShowProfilePage({required this.friendUid});

  @override
  _ShowProfilePageState createState() => _ShowProfilePageState();
}

class _ShowProfilePageState extends State<ShowProfilePage> {
  File? _userProfileImage;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  String _selectedGender = '';
  String? uid;
  String _profileImageUrl = '';
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    uid = widget.friendUid;

    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          _firstNameController.text = userSnapshot['firstName'];
          _lastNameController.text = userSnapshot['lastName'];
          _nicknameController.text = userSnapshot['nickname'];
          _contactNumberController.text = userSnapshot['contactNumber'];
          _selectedGender = userSnapshot['gender'];
          _profileImageUrl = userSnapshot['profileImageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });

      String storagePath = 'profilepic/$uid/profile.jpg';
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .putFile(_userProfileImage!);

      task.whenComplete(() async {
        String downloadUrl =
            await FirebaseStorage.instance.ref(storagePath).getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImageUrl': downloadUrl,
        });
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
              onPressed: () async {
                String fieldName = _getFieldName(fieldTitle);

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({fieldName: controller.text});

                await _fetchUserData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getFieldName(String fieldTitle) {
    switch (fieldTitle) {
      case 'ชื่อจริง':
        return 'firstName';
      case 'นามสกุล':
        return 'lastName';
      case 'ชื่อเล่น':
        return 'nickname';
      case 'เบอร์ติดต่อ':
        return 'contactNumber';
      default:
        return fieldTitle.toLowerCase();
    }
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
                  _updateGender('ชาย');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('หญิง'),
                onTap: () {
                  _updateGender('หญิง');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('เพศทางเลือก'),
                onTap: () {
                  _updateGender('เพศทางเลือก');
                  Navigator.of(context).pop();
                },
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
          ],
        );
      },
    );
  }

  Future<void> _updateGender(String selectedGender) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'gender': selectedGender});

    setState(() {
      _selectedGender = selectedGender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "ข้อมูลโปรไฟล์",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 100.0,
                  backgroundImage: _userProfileImage != null
                      ? FileImage(_userProfileImage!)
                      : _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                              as ImageProvider<Object>?
                          : AssetImage('assets/profile.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  "รูปโปรไฟล์",
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อจริง',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _firstNameController.text,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'นามสกุล',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _lastNameController.text,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อเล่น',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _nicknameController.text,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'เบอร์ติดต่อ',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _contactNumberController.text,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เพศ',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_selectedGender.isNotEmpty
                            ? _selectedGender
                            : 'ไม่ระบุ'),
                      ],
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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ShowProfilePage(
      friendUid: '',
    ),
  ));
}
