import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/notificationcheck/notificationfunction.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';

class EditTrip extends StatefulWidget {
  final String? tripUid;
  const EditTrip({Key? key, this.tripUid}) : super(key: key);
  _EditTripState createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;

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
          nummax = tripSnapshot['tripJoin']?.length ?? 0;
        });
      }
    }
  }

  Future<void> _uploadImageToStorage(String tripUid, String tripName) async {
    if (_userProfileImage != null) {
      try {
        final reference = FirebaseStorage.instance
            .ref()
            .child('trip/profiletrip/$tripUid.jpg');

        await reference.putFile(_userProfileImage!);

        final imageUrl = await reference.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripUid)
            .update({'tripProfileUrl': imageUrl});
      } catch (error) {
        print('Error uploading image: $error');
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

      await _uploadImageToStorage(widget.tripUid!, _tripName.text);
    }
  }

  String _formatDate(DateTime date) {
    initializeDateFormatting('th_TH');
    return DateFormat('dd MMMM yyyy HH:mm', 'th_TH').format(date);
  }

  Future<DateTime?> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime now = DateTime.now();
    DateTime? startTime;
    DateTime? endTime;
    DateTime firstDate = DateTime(now.year - 1);
    DateTime initialDate = isStartDate ? _selectedStartDate : _selectedEndDate;

    QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('placetripid', isEqualTo: widget.tripUid)
        .get();
    placeSnapshot.docs.forEach((doc) {
      Timestamp? startTimeStamp = doc['placetimestart'] as Timestamp?;
      Timestamp? endTimeStamp = doc['placetimeend'] as Timestamp?;
      if (startTimeStamp != null && endTimeStamp != null) {
        startTime = startTimeStamp.toDate();
        endTime = endTimeStamp.toDate();
      }
    });

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (combinedDateTime.isBefore(now)) {
          Fluttertoast.showToast(
            msg: 'ไม่สามารถเลือกวันและเวลาที่น้อยกว่าวันเวลาปัจจุบัน',
          );
          return null;
        }
        if (startTime != null || endTime != null) {
          if (isStartDate &&
              combinedDateTime.isBefore(startTime ?? DateTime.now())) {
            Fluttertoast.showToast(
              msg: 'โปรดเลือกวันเริ่มต้นทริปที่มากกว่าวันเริ่มต้นสถานที่',
            );
            return null;
          }

          if (!isStartDate &&
              combinedDateTime.isBefore(endTime ?? DateTime.now())) {
            Fluttertoast.showToast(
              msg: 'โปรดเลือกวันสิ้นสุดทริปที่มากกว่าวันสิ้นสุดสถานที่',
            );
            return null;
          }
        }
        if (!isStartDate && combinedDateTime.isBefore(_selectedStartDate)) {
          Fluttertoast.showToast(
            msg: 'โปรดเลือกวันสิ้นสุดทริปมากกว่าวันเริ่มต้นทริป',
          );
          return null;
        }
        if (isStartDate && combinedDateTime.isAfter(_selectedEndDate)) {
          Fluttertoast.showToast(
            msg: 'โปรดเลือกวันเริ่มต้นทริปมากกว่าวันสิ้นสุดทริป',
          );
          return null;
        }
        return combinedDateTime;
      } else {
        return null;
      }
    } else {
      return null;
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
                15,
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

        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripUid)
            .update({'tripLimit': selectedValue});
      } else {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fieldTitle == 'วันที่เริ่มทริป' ||
                  fieldTitle == 'วันที่สิ้นสุดทริป')
                InkWell(
                  onTap: () async {
                    DateTime? picked = await _selectDate(
                        context, fieldTitle == 'วันที่เริ่มทริป');
                    if (picked != null) {
                      setState(() {
                        if (fieldTitle == 'วันที่เริ่มทริป') {
                          _selectedStartDate = picked;
                        } else {
                          _selectedEndDate = picked;
                        }
                      });
                    }
                    if (fieldTitle == 'วันที่เริ่มทริป') {
                      await FirebaseFirestore.instance
                          .collection('trips')
                          .doc(widget.tripUid)
                          .update({'tripStartDate': _selectedStartDate});
                      await tripUpdatePlanNotification(widget.tripUid ?? '');
                    } else if (fieldTitle == 'วันที่สิ้นสุดทริป') {
                      await FirebaseFirestore.instance
                          .collection('trips')
                          .doc(widget.tripUid)
                          .update({'tripEndDate': _selectedEndDate});
                      await tripUpdatePlanNotification(widget.tripUid ?? '');
                    }
                    // Navigator.pop(context);
                  },
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
            if (fieldTitle != 'วันที่เริ่มทริป' &&
                fieldTitle != 'วันที่สิ้นสุดทริป') ...[
              TextButton(
                child: Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('บันทึก'),
                onPressed: () async {
                  if (fieldTitle == 'ชื่อทริป') {
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(widget.tripUid)
                        .update({'tripName': controller.text});

                    setState(() {
                      _tripName.text = controller.text;
                    });
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
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
                Container(
                  height: 200.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: _userProfileImage != null
                          ? FileImage(_userProfileImage!)
                          : _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl) as ImageProvider
                              : AssetImage('assets/cat.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      alignment: Alignment.center,
                      color: Color.fromARGB(0, 19, 19, 19),
                      child: Icon(
                        Icons.camera_alt,
                        size: 40.0,
                        color: Colors.white,
                      ),
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
                  subtitle: Text(_selectedLimit.toString()),
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
  initializeDateFormatting('th_TH');
  runApp(MaterialApp(
    home: EditTrip(),
  ));
}
