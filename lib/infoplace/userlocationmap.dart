import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UserLocationMap extends StatefulWidget {
  final List<String>? userLocations;
  final String? placeid;

  const UserLocationMap({Key? key, this.userLocations, this.placeid})
      : super(key: key);

  @override
  UserLocationMapState createState() => UserLocationMapState();
}

class UserLocationMapState extends State<UserLocationMap> {
  late Future<CameraPosition> _cameraPosition;
  late Future<Map<String, LatLng>> _userLocations;
  late Map<String, String> _userNicknames = {};
  late Map<String, String> _userProfileImageUrls = {};
  Map<String, BitmapDescriptor> _userProfileIcons = {};
  @override
  void initState() {
    super.initState();
    _cameraPosition = _fetchPlaceCoordinates();
    _userLocations = _fetchUserLocations();
    _fetchUserDetails(); // New method call
  }

  Future<void> _fetchUserDetails() async {
    for (String userId in widget.userLocations!) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        _userNicknames[userId] = userSnapshot['nickname'];
        String? profileImageUrl = userSnapshot['profileImageUrl'];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          Uint8List imageData = await _loadImage(profileImageUrl);
          _userProfileIcons[userId] = BitmapDescriptor.fromBytes(imageData);
        }
      }
    }
    setState(() {}); // Update state to trigger marker rebuild
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
        return resizedImageData;
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
    return FutureBuilder(
      future: Future.wait([_cameraPosition, _userLocations]),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          CameraPosition cameraPosition = snapshot.data[0];
          Map<String, LatLng> userLocations = snapshot.data[1];
          return GoogleMap(
            initialCameraPosition: cameraPosition,
            markers: _buildMarkers(userLocations),
          );
        }
      },
    );
  }

  Future<CameraPosition> _fetchPlaceCoordinates() async {
    try {
      DocumentSnapshot placeSnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.placeid)
          .get();

      if (placeSnapshot.exists) {
        double placeLatitude = placeSnapshot['placeLatitude'];
        double placeLongitude = placeSnapshot['placeLongitude'];
        return CameraPosition(
          target: LatLng(placeLatitude, placeLongitude),
          zoom: 12.0,
        );
      } else {
        throw 'Place does not exist';
      }
    } catch (error) {
      print('Error fetching place coordinates: $error');
      throw error;
    }
  }

  Future<Map<String, LatLng>> _fetchUserLocations() async {
    try {
      Map<String, LatLng> userLocations = {};
      for (String userId in widget.userLocations!) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('userlocation')
            .doc(userId)
            .get();
        if (userSnapshot.exists) {
          double userLatitude = userSnapshot['userLatitude'];
          double userLongitude = userSnapshot['userLongitude'];
          userLocations[userId] = LatLng(userLatitude, userLongitude);
        }
      }
      return userLocations;
    } catch (error) {
      print('Error fetching user locations: $error');
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
        snippet: 'ตำแหน่งผู้ร่วมทริป',
        onTap: () {
          // Handle marker tap event
        },
      ),
    );
  }
}
