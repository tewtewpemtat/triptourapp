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
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MapSelectionOwnPage extends StatefulWidget {
  final String? tripUid;

  const MapSelectionOwnPage({Key? key, this.tripUid}) : super(key: key);

  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionOwnPage> {
  late GoogleMapController _controller;
  String? uid;
  LatLng? _selectedPosition;
  String placestart = '';
  DateTime? placetimeend = null;
  DateTime? placetimestart = null;
  String placestatus = 'Wait';
  String placeAdd = 'No';
  String? placetripid;
  File? _selectedImage;
  List<String> placewhogo = [];
  String? useruid;
  TextEditingController _placeNameController = TextEditingController();
  TextEditingController _placeAddressController = TextEditingController();
  late StreamSubscription<Position> _positionStreamSubscription;
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  void _getCurrentLocation() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('กำหนดสถานที่'),
        automaticallyImplyLeading: false, // ไม่แสดงปุ่ม Back อัตโนมัติ
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddPage(tripUid: widget.tripUid),
              ),
            ); // กลับไปที่หน้า AddPage
          },
        ),
      ),
      body: StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            onTap: (position) {
              setState(() {
                _selectedPosition = position;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(userLatitude, userLongitude), // Default position
              zoom: 12,
            ),
            markers:
                _selectedPosition != null ? _createMarkers() : Set<Marker>(),
          );
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

  void _showPlaceInfoDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('ข้อมูลสถานที่'),
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
                                          'assets/trips.jpg',
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
                      decoration: InputDecoration(labelText: 'ชื่อสถานที่'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('บันทึก'),
                  onPressed: () {
                    if (_selectedImage == null ||
                        _placeNameController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'กรุณากรอกชื่อสถานที่และเลือกรูปสถานที่');
                    } else {
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(msg: 'กำลังบันทึกสถานที่...');
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

  Future<String?> getDistrictFromCoordinates(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return placemark.subAdministrativeArea;
    } else {
      return null;
    }
  }

  Future<String?> getProvinceFromCoordinates(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return placemark
          .administrativeArea; // หรือจะใช้ .subAdministrativeArea ก็ได้
    } else {
      return null;
    }
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

  String generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(999999999 - 100000000) + 100000000;
    return randomNumber.toString();
  }

  Future<void> _PlaceAdd() async {
    try {
      final placeName = _placeNameController.text;
      final placeLatitude = _selectedPosition!.latitude;
      final placeLongitude = _selectedPosition!.longitude;
      final placeStart = placestart;
      final placetimeStart = placetimestart;
      final placetimeEnd = placetimeend;
      final placeTripid = widget.tripUid;
      final placeRun = 'Start';
      final placeWhoGo = placewhogo;
      final placeStatus = placestatus;
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      final randomImg =
          generateRandomNumber(); // Generate a random 9-digit number
      final placeProvince =
          await getProvinceFromCoordinates(_selectedPosition!);
      final placeDistrict =
          await getDistrictFromCoordinates(_selectedPosition!);
      final placeAddress = '$placeProvince $placeDistrict';
      final imageName = '$placeName$randomImg.jpg';
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('trip/places/profilepicown/${widget.tripUid}/$imageName');
      await firebaseStorageRef.putFile(_selectedImage!);

      final downloadURL = await firebaseStorageRef.getDownloadURL();

      final placesCollection = FirebaseFirestore.instance.collection('places');
      await placesCollection.add({
        'placeLatitude': placeLatitude,
        'placeLongitude': placeLongitude,
        'placeaddress': placeAddress,
        'placename': placeName,
        'placepicUrl': downloadURL,
        'placestart': placeStart,
        'placetimestart': placetimeStart,
        'placetimeend': placetimeEnd,
        'placetripid': placeTripid,
        'placewhogo': placeWhoGo,
        'useruid': userUid,
        'placestatus': placeStatus,
        'placeprovince': placeProvince,
        'placeadd': placeAdd,
        'placeRun': placeStart
      });

      setState(() {
        _selectedImage = null;
        _placeNameController.clear();
        _selectedPosition = null;
      });

      Fluttertoast.showToast(msg: 'เพิ่มสถานที่เรียบร้อยแล้ว');
    } catch (e) {
      print('Error: $e'); // แสดง error message ใน console
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการเพิ่มสถานที่');
    }
  }
}
