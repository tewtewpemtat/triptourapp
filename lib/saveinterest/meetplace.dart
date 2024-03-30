import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triptourapp/addplaceuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

import 'package:triptourapp/groupchat.dart';

class MeetplacePage extends StatefulWidget {
  final String? tripUid;
  final double? placelat;
  final double? placelong;
  const MeetplacePage({Key? key, this.tripUid, this.placelat, this.placelong})
      : super(key: key);

  @override
  _MeetplacePageState createState() => _MeetplacePageState();
}

class _MeetplacePageState extends State<MeetplacePage> {
  late GoogleMapController _controller;
  String? uid;
  LatLng? _startPosition;
  LatLng? _selectedPosition;
  String? placetripid;
  File? _selectedImage;
  String? useruid;
  TextEditingController _placeNameController = TextEditingController();
  TextEditingController _placeAddressController = TextEditingController();
  double? _placeLatitude;
  double? _placeLongitude;
  late Future<void>
      _initialCameraPositionFuture; // Future for _getInitialCameraPosition()
  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    _initialCameraPositionFuture =
        _getInitialCameraPosition(); // Initialize Future in initState
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('กำหนดสถานที่'),
        automaticallyImplyLeading: false, // ไม่แสดงปุ่ม Back อัตโนมัติ
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GroupScreenPage(tripUid: widget.tripUid ?? ''),
              ),
            ); // กลับไปที่หน้า AddPage
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initialCameraPositionFuture, // Use the Future here
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildGoogleMap(); // Build GoogleMap after Future completes
          }
        },
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton(
              onPressed: () {
                _showPlaceInfoDialog();
              },
              child: Icon(Icons.save),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.startFloat, // ตำแหน่ง FAB ที่กำหนด
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: MarkerId('selected_position'),
        position: _selectedPosition!,
        draggable: false,
      ),
    };
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _controller = controller;
      },
      onTap: (position) {
        setState(() {
          _selectedPosition = position;
        });
      },
      initialCameraPosition: _placeLatitude != null && _placeLongitude != null
          ? CameraPosition(
              target: LatLng(_placeLatitude!, _placeLongitude!),
              zoom: 17,
            )
          : CameraPosition(
              target: LatLng(13.736717, 100.523186), // Default position
              zoom: 17,
            ),
      markers: _selectedPosition != null ? _createMarkers() : Set<Marker>(),
    );
  }

  void _showPlaceInfoDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('จุดนัดพบ'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _selectedImage != null
                        ? Image.file(_selectedImage!)
                        : GestureDetector(
                            onTap: () {
                              _getImage().then((_) {
                                setState(
                                    () {}); // เรียกใช้ setState เพื่อให้ Dialog สร้างใหม่เพื่อแสดงรูปภาพใหม่
                              });
                            },
                            child: Container(
                              width: 150.0,
                              height: 150.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: _selectedImage != null
                                    ? DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: AssetImage(
                                          'assets/addplace/addplace_image2.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 40.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    TextField(
                      controller: _placeNameController,
                      decoration: InputDecoration(labelText: 'ชื่อจุดนัดพบ'),
                    ),
                    TextField(
                      controller: _placeAddressController,
                      decoration: InputDecoration(labelText: 'รายละเอียด'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('บันทึก'),
                  onPressed: () {
                    if (_selectedImage == null ||
                        _placeNameController.text.isEmpty ||
                        _placeAddressController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                    } else {
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(msg: 'กำลังบันทึกจุดนัดพบ...');
                      _PlaceAdd();
                    }
                  },
                ),
                TextButton(
                  child: Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImage = null;
                      _selectedPosition = null;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getInitialCameraPosition() async {
    try {
      final placesSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .where('placetripid', isEqualTo: widget.tripUid)
          .where('placerun', isEqualTo: 'Running')
          .get();

      if (placesSnapshot.docs.isNotEmpty) {
        final placeData =
            placesSnapshot.docs.first.data() as Map<String, dynamic>;
        _placeLatitude = placeData['placeLatitude'];
        _placeLongitude = placeData['placeLongitude'];

        setState(() {
          _placeLatitude = placeData['placeLatitude'];
          _placeLongitude = placeData['placeLongitude'];
        });
      } else {
        // ตั้งค่าเริ่มต้นให้กับ _placeLatitude และ _placeLongitude
        // เมื่อไม่มีข้อมูลในฐานข้อมูล
        _placeLatitude = 13.736717; // ละติจูดตำแหน่งเริ่มต้น
        _placeLongitude = 100.523186; // ลองจิจูดตำแหน่งเริ่มต้น
      }
    } catch (e) {
      print('Error fetching initial camera position: $e');
    }
  }

  String generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(999999999 - 100000000) + 100000000;
    return randomNumber.toString();
  }

  Future<void> _PlaceAdd() async {
    try {
      final placeName = _placeNameController.text;
      final placeDetail = _placeAddressController.text;
      final placeLatitude = _selectedPosition!.latitude;
      final placeLongitude = _selectedPosition!.longitude;
      final placeTripid = widget.tripUid;
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      final randomImg =
          generateRandomNumber(); // Generate a random 9-digit number
      final imageName = '$placeName$randomImg.jpg';
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('trip/places/meetplace/${widget.tripUid}/$imageName');
      await firebaseStorageRef.putFile(_selectedImage!);

      final downloadURL = await firebaseStorageRef.getDownloadURL();

      final placesCollection =
          FirebaseFirestore.instance.collection('placemeet');
      await placesCollection.add({
        'placeLatitude': placeLatitude,
        'placeLongitude': placeLongitude,
        'placeaddress': placeDetail,
        'placename': placeName,
        'placepicUrl': downloadURL,
        'placetripid': placeTripid,
        'useruid': userUid,
      });

      setState(() {
        _selectedImage = null;
        _placeNameController.clear();
        _placeAddressController.clear();
        _selectedPosition = null;
      });

      Fluttertoast.showToast(msg: 'เพิ่มจุดนัดพบเรียบร้อยแล้ว');
    } catch (e) {
      print('Error: $e'); // แสดง error message ใน console
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการเพิ่มจุดนัดพบ');
    }
  }
}
