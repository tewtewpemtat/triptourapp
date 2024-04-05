import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:triptourapp/tripmanage/maproute.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceMeet {
  final String docId;
  final double placeLatitude;
  final double placeLongitude;
  final String placeAddress;
  final String placePicUrl;
  final String userUid;

  PlaceMeet({
    required this.docId,
    required this.placeLatitude,
    required this.placeLongitude,
    required this.placeAddress,
    required this.placePicUrl,
    required this.userUid,
  });
}

class thingMap extends StatefulWidget {
  final String? placeid;

  const thingMap({Key? key, this.placeid}) : super(key: key);

  @override
  thingMapState createState() => thingMapState();
}

Future<String> _fetchNickname(String userUid) async {
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userUid).get();

  return userSnapshot['nickname'];
}

class thingMapState extends State<thingMap> {
  late String uid = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<PlaceMeet>> _placeMeetData;
  Map<String, BitmapDescriptor> _placeIcons = {};
  double userLatitude = 0.0; // พิกัดละติจูดปัจจุบันของผู้ใช้
  double userLongitude = 0.0; // พิกัดลองจิจูดปัจจุบันของผู้ใช้
  @override
  void initState() {
    super.initState();

    getUserLocation();
    _placeMeetData = _fetchPlaceMeetData();
  }

  @override
  void dispose() {
    // Add code here to clean up resources, close connections, etc.
    super.dispose();
  }

  Future<List<PlaceMeet>> _fetchPlaceMeetData() async {
    _showLoadingToast();
    List<PlaceMeet> placeMeetList = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('interest')
        .where('placeid', isEqualTo: widget.placeid)
        .get();

    querySnapshot.docs.forEach((doc) {
      placeMeetList.add(PlaceMeet(
        docId: doc.id,
        placeLatitude: doc['placeLatitude'],
        placeLongitude: doc['placeLongitude'],
        placeAddress: doc['placeaddress'],
        placePicUrl: doc['placepicUrl'],
        userUid: doc['useruid'],
      ));
    });

    return placeMeetList;
  }

  Future<DocumentSnapshot> _fetchPlaceData() async {
    return await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeid)
        .get();
  }

  void _showLoadingToast() {
    Fluttertoast.showToast(
      msg: "กำลังโหลดข้อมูลสถานที่...",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  void _showCompleteToast() {
    Fluttertoast.showToast(
      msg: "โหลดข้อมูลเสร็จสมบูรณ์",
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_placeMeetData, _fetchPlaceData()]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<PlaceMeet> placeMeetList = snapshot.data![0];
          DocumentSnapshot placeData = snapshot.data![1];
          return FutureBuilder<Set<Marker>>(
            future: _buildMarkers(placeMeetList),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      placeData['placeLatitude'],
                      placeData['placeLongitude'],
                    ),
                    zoom: 15.0,
                  ),
                  markers: snapshot.data!,
                );
              }
            },
          );
        }
      },
    );
  }

  Future<Uint8List> _loadImage(String imageUrl,
      {int width = 100, int height = 100}) async {
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageData = response.bodyBytes;
        Uint8List resizedImageData =
            await FlutterImageCompress.compressWithList(
          imageData,
          minHeight: height,
          minWidth: width,
          quality: 100,
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final size = Size(width.toDouble(), height.toDouble());

        // Draw the circle border
        final paintBorder = Paint()
          ..color = Colors.blue // Choose your desired border color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final radius = size.width / 2;
        canvas.drawCircle(Offset(radius, radius), radius - 1, paintBorder);

        // Clip the canvas to draw the image only inside the circle
        canvas.clipRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(radius)));

        // Draw the image
        final image = await decodeImageFromList(resizedImageData);
        final paintImage = Paint()..filterQuality = FilterQuality.high;
        canvas.drawImageRect(
            image,
            Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
            Offset.zero & size,
            paintImage);

        final picture = recorder.endRecording();
        final img = await picture.toImage(width, height);
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

        return byteData!.buffer.asUint8List();
      } else {
        throw 'Failed to load image: ${response.statusCode}';
      }
    } catch (error) {
      print('Error loading image: $error');
      throw error;
    }
  }

  Future<Set<Marker>> _buildMarkers(List<PlaceMeet> placeMeetList) async {
    Set<Marker> markers = {};

    for (var placeMeet in placeMeetList) {
      if (placeMeet != null) {
        LatLng position =
            LatLng(placeMeet.placeLatitude, placeMeet.placeLongitude);
        String userUid = placeMeet.userUid;
        String nickname = await _fetchNickname(userUid);
        String docId = placeMeet.docId;
        String placeAddress = placeMeet.placeAddress;
        Uint8List imageData = await _loadImage(
            placeMeet.placePicUrl); // เรียกใช้ _loadImage โดยส่ง URL ของภาพ
        _placeIcons[userUid] = BitmapDescriptor.fromBytes(
            imageData); // เก็บ Icon ลงใน Map แบบ userUid เป็น Key

        markers.add(Marker(
          markerId: MarkerId(placeMeet.docId),
          position: position,
          icon: _placeIcons[userUid]!, // ใช้ Icon จาก Map ที่เก็บไว้
          infoWindow: InfoWindow(
            title: "ผู้มาร์คจุด: $nickname",
            snippet: "สิ่งน่าสนใจ : $placeAddress",
            onTap: () {
              getPlaceData(placeMeet.docId, userUid, context);
            },
          ),
        ));
      }
    }

    return markers;
  }

  void getPlaceData(String postId, String userUid, BuildContext context) async {
    try {
      // ค้นหา document ใน collection 'placemeet' โดยใช้ postId ที่ได้จากข้อความ
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('interest')
          .doc(postId)
          .get();

      // ถ้าพบ document
      if (snapshot.exists) {
        // เข้าถึงข้อมูลจาก snapshot
        String placepicUrl = snapshot['placepicUrl'];
        String placeid = snapshot['placeid'];
        double placeLatitude = snapshot['placeLatitude'];
        double placeLongitude = snapshot['placeLongitude'];
        String placetripid = snapshot['placetripid'];
        String placeaddress = snapshot['placeaddress'];

        // แสดงข้อมูลในรูปแบบของ Dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                  child: Text('สิ่งน่าสนใจ',
                      style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 24, fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // กำหนด border radius ให้กับรูปภาพ
                      child: Image.network(
                        placepicUrl,
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "รายละเอียด:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$placeaddress",
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          rounttomap(placeLatitude, placeLongitude, context);
                        },
                        child: Text('นำทาง'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('ยกเลิก'),
                      ),
                    ),
                  ],
                ),
                if (userUid == FirebaseAuth.instance.currentUser?.uid)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        deletePlaceMeet(postId); // Call delete function
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'ลบจุดมาร์ค',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11 // Change text color to red
                            ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      } else {
        print('ไม่พบเอกสาร');
        setState(() {
          _placeMeetData =
              _fetchPlaceMeetData(); // เรียกฟังก์ชัน _fetchPlaceMeetData เพื่อดึงข้อมูลใหม่
        });
      }
    } catch (e) {
      print('Error retrieving place data: $e');
      setState(() {
        _placeMeetData =
            _fetchPlaceMeetData(); // เรียกฟังก์ชัน _fetchPlaceMeetData เพื่อดึงข้อมูลใหม่
      });
    }
  }

  void deletePlaceMeet(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupmessages')
          .where('message',
              isGreaterThanOrEqualTo: "28sd829gDw8d6a8w4d8a6=$postId")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          String message = doc['message'];
          if (message.contains('=$postId')) {
            await doc.reference.delete();
          }
        });
      });
      await FirebaseFirestore.instance
          .collection('interest')
          .doc(postId)
          .delete();

      print('Deleted place meet successfully.');
      Fluttertoast.showToast(
        msg: "ลบจุดมาร์คสำเร็จ",
      );
      setState(() {
        _placeMeetData =
            _fetchPlaceMeetData(); // เรียกฟังก์ชัน _fetchPlaceMeetData เพื่อดึงข้อมูลใหม่
      });
    } catch (error) {
      print('Error deleting place meet: $error');
      // Handle error accordingly
    }
  }

  void rounttomap(double placeLatitude, double placeLongitude, context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          placeLatitude: placeLatitude, // ประกาศพารามิเตอร์ placelatitude
          placeLongitude: placeLongitude, // ประกาศพารามิเตอร์ placelongitude
        ),
      ),
    );
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }
}
