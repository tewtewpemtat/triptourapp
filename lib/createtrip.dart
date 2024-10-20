import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/main.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<String?> _uploadImage(String documentId) async {
    if (_userProfileImage != null) {
      String fileName = 'trip/profiletrip/$documentId.jpg';
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
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (combinedDateTime.isAfter(now)) {
          setState(() {
            if (isStartDate) {
              selectedStartDate = combinedDateTime;
              if (selectedEndDate.isBefore(selectedStartDate)) {
                selectedEndDate = selectedStartDate;
              }
            } else {
              selectedEndDate = combinedDateTime;
              if (selectedEndDate.isBefore(selectedStartDate)) {
                selectedStartDate = selectedEndDate;
              }
            }
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('เวลาไม่ถูกต้อง'),
                content: Text('กรุณาเลือกวันที่และเวลาที่มากกว่าเวลาปัจจุบัน'),
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
  }

  Future<void> _createTrip() async {
    setState(() {
      _isLoading = true;
    });

    if (_userProfileImage != null) {
      String tripName = _tripNameController.text;

      DateTime tripStartDate = selectedStartDate;
      DateTime tripEndDate = selectedEndDate;
      int tripLimit = selectedParticipants ?? 1;
      String tripStatus = "ยังไม่เริ่มต้น";
      List<String> tripJoin = [];
      if (uid != null) {
        tripJoin.add(uid!);
      }

      DocumentReference tripRef =
          await FirebaseFirestore.instance.collection('trips').add({
        'tripCreate': uid,
        'tripName': tripName,
        'tripProfileUrl': null,
        'tripStartDate': tripStartDate,
        'tripEndDate': tripEndDate,
        'tripLimit': tripLimit,
        'tripStatus': tripStatus,
        'tripJoin': tripJoin,
      });

      String? imageUrl = await _uploadImage(tripRef.id);
      if (imageUrl != null) {
        await tripRef.update({
          'tripProfileUrl': imageUrl,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
        Fluttertoast.showToast(
          msg: "สร้างทริปสำเร็จ",
        );
      }
    } else {
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
                        : AssetImage('assets/trips.jpg') as ImageProvider,
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
                              "${DateFormat('dd/MM/yyyy HH:mm').format(selectedStartDate.toLocal())}",
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 14),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 22,
                            ),
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
                              "${DateFormat('dd/MM/yyyy HH:mm').format(selectedEndDate.toLocal())}",
                              style: GoogleFonts.ibmPlexSansThai(fontSize: 14),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 22,
                            ),
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
                        15,
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
                onPressed: _isLoading || _userProfileImage == null
                    ? null
                    : () {
                        if (_tripNameController.text.isEmpty) {
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
                          _createTrip();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffdb923c),
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
