import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/main.dart';

import 'tripmanage.dart';

class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  File? _userProfileImage;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
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
                onPressed: () {
                  // ทำงานเมื่อกดปุ่ม "ดำเนินการต่อ"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripmanagePage(),
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
                        builder: (context) =>
                            CreateTripPage()), // RegisterPage() คือหน้าที่คุณต้องไป
                  );
                },
                child: Text(
                  "ล้างข้อมูลเพื่อระบุข้อมูลการสร้างทริปใหม่",
                  style: GoogleFonts.ibmPlexSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
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
  runApp(MaterialApp(
    home: CreateTripPage(),
  ));
}
