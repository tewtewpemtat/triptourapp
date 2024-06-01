import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triptourapp/infoplace.dart';
import 'package:triptourapp/infoplace/maproutetofriend.dart';

class UserLocationShow extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final String? friendId;
  final String? tripUid;
  final String? placeid;
  const UserLocationShow(
      {Key? key,
      this.userLatitude,
      this.userLongitude,
      this.friendId,
      this.tripUid,
      this.placeid})
      : super(key: key);

  @override
  UserLocationState createState() => UserLocationState();
}

class UserLocationState extends State<UserLocationShow> {
  late Future<CameraPosition> _cameraPosition;
  late Map<String, String> _userNicknames = {};
  late Map<String, String> _userProfileImageUrls = {};
  Map<String, BitmapDescriptor> _userProfileIcons = {};
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  double friendLatitude = 0.0;
  double friendLongitude = 0.0;
  @override
  void dispose() {
    friendLatitude = 0.0;
    friendLongitude = 0.0;

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cameraPosition = _fetchFriendCoordinates();
    _fetchFriendDetails();
    getFriendLocation();
    print(widget.friendId);
  }

  void getFriendLocation() async {
    try {
      DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('userlocation')
          .doc(widget.friendId)
          .get();

      if (locationSnapshot.exists) {
        if (mounted) {
          setState(() {
            friendLatitude = locationSnapshot['userLatitude'];
            friendLongitude = locationSnapshot['userLongitude'];
          });
        }
      } else {
        print('Friend location does not exist');
      }
    } catch (error) {
      print("Error getting user location: $error");
    }
  }

  Future<void> _fetchFriendDetails() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();
      if (userSnapshot.exists) {
        String nickname = userSnapshot['nickname'];
        _userNicknames[widget.friendId!] = nickname;

        String? profileImageUrl = userSnapshot['profileImageUrl'];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          _userProfileImageUrls[widget.friendId!] = profileImageUrl;
          Uint8List imageData = await _loadImage(profileImageUrl);
          _userProfileIcons[widget.friendId!] =
              BitmapDescriptor.fromBytes(imageData);
        }
      }
      setState(() {});
    } catch (error) {
      print('Error fetching friend details: $error');
    }
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

        final paintBorder = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final radius = size.width / 2;
        canvas.drawCircle(Offset(radius, radius), radius - 1, paintBorder);

        canvas.clipRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(radius)));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('\t\t\t\t\t\t\t\t\t\t\tตำแหน่งเพื่อน'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InfoPlacePage(
                  tripUid: widget.tripUid,
                  placeid: widget.placeid,
                ),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([_cameraPosition]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            CameraPosition cameraPosition = snapshot.data[0];

            return GoogleMap(
              initialCameraPosition: cameraPosition,
              markers: _buildMarkers(
                  {widget.friendId!: LatLng(friendLatitude, friendLongitude)}),
            );
          }
        },
      ),
    );
  }

  Future<CameraPosition> _fetchFriendCoordinates() async {
    try {
      DocumentSnapshot placeSnapshot = await FirebaseFirestore.instance
          .collection('userlocation')
          .doc(widget.friendId)
          .get();
      if (placeSnapshot.exists) {
        double friendLatitude = placeSnapshot['userLatitude'];
        double friendLongitude = placeSnapshot['userLongitude'];
        return CameraPosition(
          target: LatLng(friendLatitude, friendLongitude),
          zoom: 16.0,
        );
      } else {
        throw 'Friend location does not exist';
      }
    } catch (error) {
      print('Error fetching friend coordinates: $error');
      throw error;
    }
  }

  Set<Marker> _buildMarkers(Map<String, LatLng> userLocations) {
    Set<Marker> markers = {};

    userLocations.forEach((userId, position) {
      markers.add(_createMarkerFromUserId(userId, position));
    });

    return markers;
  }

  Marker _createMarkerFromUserId(String userId, LatLng position) {
    String nickname = _userNicknames[userId] ?? 'Unknown';
    BitmapDescriptor icon = _userProfileIcons[userId] ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

    return Marker(
      markerId: MarkerId(userId),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(
        title: nickname,
        snippet: 'ตำแหน่งเพื่อน',
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('ต้องการนำทางไปหรือไม่?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MapScreenFriend(
                                tripUid: widget.tripUid,
                                placeid: widget.placeid,
                                friendId: widget.friendId,
                                userLatitude: widget.userLatitude ?? 0.0,
                                userLongitude: widget.userLongitude ?? 0.0,
                                friendLatitude: friendLatitude,
                                friendLongitude: friendLongitude)),
                      );
                    },
                    child: Text('ตกลง'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ยกเลิก'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
