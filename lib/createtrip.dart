import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/main.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tripmanage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  bool _isLoading = false;

  File? _userProfileImage;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  final TextEditingController _tripNameController = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  int? selectedParticipants = 1;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_userProfileImage != null) {
      String tripName = _tripNameController.text; // Get trip name
      String fileName =
          'trip/profiletrip/$uid/$tripName.jpg'; // Construct file name
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      await ref.putFile(_userProfileImage!);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } else {
      return 'assets/cat.jpg';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate : selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    String? imageUrl =
        await _uploadImage(); // Wait for image upload to complete

    if (imageUrl != null) {
      // Image upload successful, proceed to create trip
      String tripName = _tripNameController.text;
      // You can add more fields as per your requirements
      DateTime tripStartDate = selectedStartDate;
      DateTime tripEndDate = selectedEndDate;
      int tripLimit = selectedParticipants ?? 1;
      String tripStatus = "กำลังดำเนินการ";
      List<String> tripJoin = [];

      // Add trip data to Firestore
      await FirebaseFirestore.instance.collection('trips').add({
        'tripCreate': uid,
        'tripName': tripName,
        'tripProfileUrl': imageUrl,
        'tripStartDate': tripStartDate,
        'tripEndDate': tripEndDate,
        'tripLimit': tripLimit,
        'tripStatus': tripStatus,
        'tripJoin': tripJoin,
        // Add more fields as needed
      });

      // Navigate to TripmanagePage or any other page after trip creation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripmanagePage(),
        ),
      );
    } else {
      // Image upload failed, handle error or show message to user
      // You can handle error scenario here
      print("Image upload failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text("ระบุข้อมูลการสร้างทริป",
            style: GoogleFonts.ibmPlexSansThai(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
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
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: _userProfileImage != null
                        ? FileImage(_userProfileImage!)
                        : AssetImage('assets/cat.jpg') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 3),
              Text(
                "เพิ่มรูปทริป",
                style: GoogleFonts.ibmPlexSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _tripNameController,
                decoration: InputDecoration(
                  labelText: "ตั้งชื่อทริปของคุณ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "วันที่เริ่มเดินทาง",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "${selectedStartDate.toLocal()}".split(' ')[0],
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 16),
                            ),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "วันที่สิ้นสุดเดินทาง",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "${selectedEndDate.toLocal()}".split(' ')[0],
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 16),
                            ),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedParticipants,
                      onChanged: (value) {
                        setState(() {
                          selectedParticipants = value;
                        });
                      },
                      items: List.generate(
                        16,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: "จำนวนผู้ร่วมทริปสูงสุด",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_tripNameController.text.isEmpty) {
                          // Show error message if trip name is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'กรุณากรอกชื่อทริป',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Color.fromARGB(255, 2, 2, 2),
                            ),
                          );
                        } else {
                          // Proceed with trip creation if trip name is not empty
                          _createTrip();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffdb923c),
                  onPrimary: Colors.white,
                  fixedSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "ดำเนินการต่อ",
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )

              // SizedBox(height: 20),
              // InkWell(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) =>
              //               CreateTripPage()), // RegisterPage() คือหน้าที่คุณต้องไป
              //     );
              //   },
              //   child: Text(
              //     "ล้างข้อมูลเพื่อระบุข้อมูลการสร้างทริปใหม่",
              //     style: GoogleFonts.ibmPlexSansThai(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.blue,
              //       decoration: TextDecoration.underline,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CreateTripPage(),
  ));
}
