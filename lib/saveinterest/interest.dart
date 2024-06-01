import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:triptourapp/infoplace/groupchat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

class InterestPage extends StatefulWidget {
  final String? tripUid;
  final String? placeid;

  const InterestPage({Key? key, this.tripUid, this.placeid}) : super(key: key);

  @override
  _InterestPageState createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  late GoogleMapController _controller;
  String? uid;
  LatLng? _selectedPosition;
  String? placetripid;
  File? _selectedImage;
  String? useruid;
  TextEditingController _placeNameController = TextEditingController();
  TextEditingController _placeAddressController = TextEditingController();
  String? placeid;
  late Future<void> _initialCameraPositionFuture;
  Position? _currentPosition;

  bool _isDisposed = false;
  late Uint8List markerIconBytes = Uint8List(0);
  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    _initialCameraPositionFuture = _getInitialCameraPosition();
    _getCurrentLocation();
    _getMarkerIcon();
    Geolocator.getPositionStream().listen((Position position) {
      if (!_isDisposed) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getMarkerIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Color.fromARGB(255, 26, 167, 249);
    final double radius = 32;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final img =
        await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      markerIconBytes = byteData.buffer.asUint8List();
    } else {
      throw 'Error converting image to bytes';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('\tกำหนดสถานที่',
            style: GoogleFonts.ibmPlexSansThai(
                fontSize: 24, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupScreenPage(
                      tripUid: widget.tripUid ?? '',
                      placeid: widget.placeid ?? '')),
            );
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initialCameraPositionFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildGoogleMap();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildGoogleMap() {
    Set<Marker> markers = {};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: markerIconBytes.isNotEmpty
              ? BitmapDescriptor.fromBytes(markerIconBytes)
              : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: 'ตำแหน่งปัจจุบันของคุณ',
          ),
        ),
      );
    }

    if (_selectedPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('selected_position'),
          position: _selectedPosition!,
          draggable: false,
        ),
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
      initialCameraPosition: _currentPosition != null
          ? CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 17,
            )
          : CameraPosition(
              target: LatLng(13.736717, 100.523186),
              zoom: 17,
            ),
      markers: Set<Marker>.from(markers),
    );
  }

  void _showPlaceInfoDialog() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text('สิ่งน่าสนใจ',
                      style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _selectedImage != null
                        ? Image.file(_selectedImage!)
                        : GestureDetector(
                            onTap: () {
                              _getImage().then((_) {
                                setState(() {});
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
                      controller: _placeAddressController,
                      decoration:
                          InputDecoration(labelText: 'รายละเอียดสิ่งน่าสนใจ'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('บันทึก'),
                  onPressed: () {
                    if (_selectedImage == null ||
                        _placeAddressController.text.isEmpty) {
                      Fluttertoast.showToast(msg: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                    } else {
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(msg: 'กำลังบันทึกสิ่งน่าสนใจ...');
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
        final placeDoc = placesSnapshot.docs.first;
        placeDoc.data();
        final placeIddoc = placeDoc.id;

        setState(() {
          placeid = placeIddoc;
        });
      } else {
        placeid = widget.tripUid;
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
      final placeDetail = _placeAddressController.text;
      final placeLatitude = _selectedPosition!.latitude;
      final placeLongitude = _selectedPosition!.longitude;
      final placeTripid = widget.tripUid;
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      final randomImg = generateRandomNumber();
      final imageName = '${widget.tripUid}$randomImg.jpg';
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('trip/places/interest/${widget.tripUid}/$imageName');
      await firebaseStorageRef.putFile(_selectedImage!);

      final downloadURL = await firebaseStorageRef.getDownloadURL();
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userUid);
      final userData = await userDocRef.get();
      final nickname = userData['nickname'];
      final profileImageUrl = userData['profileImageUrl'];

      final placesCollection =
          FirebaseFirestore.instance.collection('interest');
      final placeDocumentRef = await placesCollection.add({
        'placeLatitude': placeLatitude,
        'placeLongitude': placeLongitude,
        'placeaddress': placeDetail,
        'placepicUrl': downloadURL,
        'placetripid': placeTripid,
        'placeid': placeid,
        'useruid': userUid,
      });

      final message = '28sd829gDw8d6a8w4d8a6=${placeDocumentRef.id}';
      final MessageCollection =
          FirebaseFirestore.instance.collection('groupmessages');
      await MessageCollection.add({
        'message': message,
        'nickname': nickname,
        'profileImageUrl': profileImageUrl,
        'senderUid': userUid,
        'timestampserver': FieldValue.serverTimestamp(),
        'tripChatUid': widget.tripUid
      });
      setState(() {
        _selectedImage = null;
        _placeNameController.clear();
        _placeAddressController.clear();
        _selectedPosition = null;
      });

      Fluttertoast.showToast(msg: 'เพิ่มสิ่งน่าสนใจเรียบร้อยแล้ว');
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(msg: 'เกิดข้อผิดพลาดในการเพิ่มสิ่งน่าสนใจ');
    }
  }
}
