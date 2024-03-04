import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditTrip extends StatefulWidget {
  @override
  final String? tripUid;
  const EditTrip({Key? key, this.tripUid}) : super(key: key);
  _EditTripState createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip> {
  File? _userProfileImage;
  TextEditingController _tripName = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  int? _selectedLimit = 1;
  String _profileImageUrl = '';
  int nummax = 0;
  @override
  void initState() {
    super.initState();
    _fetchtripData();
  }

  Future<void> _fetchtripData() async {
    if (widget.tripUid != null) {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripUid)
          .get();

      if (tripSnapshot.exists) {
        setState(() {
          _tripName.text = tripSnapshot['tripName'];
          _selectedStartDate = tripSnapshot['tripStartDate'].toDate();
          _selectedEndDate = tripSnapshot['tripEndDate'].toDate();
          _selectedLimit = tripSnapshot['tripLimit'];
          _profileImageUrl = tripSnapshot['tripProfileUrl'] ?? '';

          // ตัวอย่างเพิ่มเติม หากต้องการใช้ข้อมูลเพิ่มเติมจาก tripSnapshot
        });
      }
    }
    await _fetchTripJoinData();
  }

  Future<void> _fetchTripJoinData() async {
    QuerySnapshot tripJoinSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripUid)
        .collection('tripJoin')
        .get();

    if (tripJoinSnapshot.docs.isNotEmpty) {
      // นับจำนวนข้อมูลและบวกค่าเพื่อกำหนดค่าให้กับ nummax
      int sum = tripJoinSnapshot.docs
          .map<int>((doc) => doc['value'] ?? 0)
          .reduce((value, element) => value + element);
      setState(() {
        nummax = sum;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _showParticipantDialog() async {
    int? selectedValue = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            child: Column(
              children: List.generate(
                16,
                (index) {
                  final value = index + 1;
                  return ListTile(
                    title: Text(value.toString()),
                    onTap: () {
                      Navigator.pop(context, value);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (selectedValue != null) {
      if (selectedValue > nummax) {
        setState(() {
          _selectedLimit = selectedValue;
        });
      } else {
        // Show a warning
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('เเจ้งเตือน'),
              content: Text('ให้เลือกจำนวนคนที่มากกว่า $nummax.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
              if (fieldTitle == 'วันที่เริ่มทริป' ||
                  fieldTitle == 'วันที่สิ้นสุดทริป')
                InkWell(
                  onTap: () =>
                      _selectDate(context, fieldTitle == 'วันที่เริ่มทริป'),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: fieldTitle,
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          fieldTitle == 'วันที่เริ่มทริป'
                              ? "${_selectedStartDate.toLocal()}".split(' ')[0]
                              : "${_selectedEndDate.toLocal()}".split(' ')[0],
                          style: GoogleFonts.ibmPlexSansThai(fontSize: 16),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                )
              else
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "แก้ไขข้อมูลทริป",
          style: GoogleFonts.ibmPlexSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripmanagePage(tripUid: widget.tripUid),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
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
                      ? FileImage(_userProfileImage!)
                      : _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                              as ImageProvider<Object>?
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
                  "เปลี่ยนรูปทริป",
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
                    'ชื่อทริป',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _tripName.text,
                    style: GoogleFonts.ibmPlexSansThai(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('ชื่อทริป', _tripName);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'วันที่เริ่มทริป',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_formatDate(_selectedStartDate)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('วันที่เริ่มทริป', _tripName);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'วันที่สิ้นสุดทริป',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_formatDate(_selectedEndDate)),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog('วันที่สิ้นสุดทริป', _tripName);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    'จำนวนผู้ร่วมทริปสูงสุด',
                    style: GoogleFonts.ibmPlexSansThai(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_selectedLimit.toString() ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showParticipantDialog();
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
    home: EditTrip(),
  ));
}
