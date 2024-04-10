import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triptourapp/tripmanage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';

class EditTrip extends StatefulWidget {
  @override
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

          // ตัวอย่างเพิ่มเติม หากต้องการใช้ข้อมูลเพิ่มเติมจาก tripSnapshot
        });
      }
    }
  }

  Future<void> _uploadImageToStorage(String tripUid, String tripName) async {
    if (_userProfileImage != null) {
      try {
        // Create a reference to the location where the image will be stored in Firebase Storage
        final reference = FirebaseStorage.instance
            .ref()
            .child('trip/profiletrip/$uid/$tripUid.jpg');

        // Upload the file to Firebase Storage
        await reference.putFile(_userProfileImage!);

        // Get the download URL of the uploaded image
        final imageUrl = await reference.getDownloadURL();

        // Update the profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(tripUid)
            .update({'tripProfileUrl': imageUrl});

        // Show a success message or perform any other desired actions
      } catch (error) {
        // Handle any errors that occur during the process
        print('Error uploading image: $error');
        // Show an error message or perform any other desired actions
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

      // Upload the selected image to Firebase Storage
      await _uploadImageToStorage(widget.tripUid!, _tripName.text);
    }
  }

  String _formatDate(DateTime date) {
    initializeDateFormatting('th_TH');
    return DateFormat('dd MMMM yyyy HH:mm', 'th_TH').format(date);
  }

  Future<void> _fetchPlaceTimeData() async {
    QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('placetripid', isEqualTo: widget.tripUid)
        .get();

    if (placeSnapshot.docs.isNotEmpty) {
      DateTime? minPlaceTimeStart;
      DateTime? maxPlaceTimeEnd;

      // Find minPlaceTimeStart and maxPlaceTimeEnd
      placeSnapshot.docs.forEach((doc) {
        Timestamp? startTimeStamp = doc['placetimestart'] as Timestamp?;
        Timestamp? endTimeStamp = doc['placetimeend'] as Timestamp?;
        if (startTimeStamp != null && endTimeStamp != null) {
          DateTime startTime = startTimeStamp.toDate();
          DateTime endTime = endTimeStamp.toDate();
          if (minPlaceTimeStart == null ||
              startTime.isBefore(minPlaceTimeStart!)) {
            minPlaceTimeStart = startTime;
          }
          if (maxPlaceTimeEnd == null || endTime.isAfter(maxPlaceTimeEnd!)) {
            maxPlaceTimeEnd = endTime;
          }
        }
      });

      // Check if minPlaceTimeStart and maxPlaceTimeEnd are not null
      if (minPlaceTimeStart != null && maxPlaceTimeEnd != null) {
        // Check if selected dates are within the range of minPlaceTimeStart and maxPlaceTimeEnd
        if (_selectedStartDate.isBefore(minPlaceTimeStart!)) {
          Fluttertoast.showToast(
            msg:
                'โปรดเลือกวันและเวลาที่มากกว่าหรือเท่ากับ ${_formatDate(minPlaceTimeStart!)}',
          );
          return null;
        }
        if (_selectedEndDate.isAfter(maxPlaceTimeEnd!)) {
          Fluttertoast.showToast(
            msg:
                'โปรดเลือกวันและเวลาที่น้อยกว่าหรือเท่ากับ ${_formatDate(maxPlaceTimeEnd!)}',
          );
          return null;
        }
      }
    }
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
        // Combine pickedDate and pickedTime into a single DateTime object
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
        // User canceled picking time, return null
        return null;
      }
    } else {
      // User canceled picking date, return null
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

        // Update the tripLimit in Firestore
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripUid)
            .update({'tripLimit': selectedValue});
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
            mainAxisSize: MainAxisSize.min, // Use min size for the content
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
                    } else if (fieldTitle == 'วันที่สิ้นสุดทริป') {
                      await FirebaseFirestore.instance
                          .collection('trips')
                          .doc(widget.tripUid)
                          .update({'tripEndDate': _selectedEndDate});
                    }
                    Navigator.pop(context); // Close the dialog
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
                  // Update Firestore if necessary
                  if (fieldTitle == 'ชื่อทริป') {
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(widget.tripUid)
                        .update({'tripName': controller.text});

                    // Update the _tripName variable
                    setState(() {
                      _tripName.text = controller.text;
                    });
                  }

                  // Close the dialog
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
                  height: 200.0, // Define a fixed height for the container
                  width:
                      double.infinity, // Make the container take the full width
                  decoration: BoxDecoration(
                    // Use BoxDecoration to customize the appearance
                    color:
                        Colors.grey[300], // Background color for the container
                    image: DecorationImage(
                      // Background image
                      image: _userProfileImage != null
                          ? FileImage(_userProfileImage!)
                          : _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl) as ImageProvider
                              : AssetImage(
                                  'assets/cat.jpg'), // Default image if no profile image
                      fit: BoxFit.cover, // Cover the entire widget area
                    ),
                  ),
                  child: InkWell(
                    onTap: _pickImage, // Function to pick image
                    child: Container(
                      alignment: Alignment
                          .center, // Center the icon inside the container
                      color: Color.fromARGB(
                          0, 19, 19, 19), // Semi-transparent overlay
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
  initializeDateFormatting('th_TH');
  runApp(MaterialApp(
    home: EditTrip(),
  ));
}
