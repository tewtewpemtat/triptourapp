import 'package:flutter/material.dart';
import 'package:triptourapp/main.dart';
import 'package:triptourapp/testuser.dart';
import 'tripmanage/information.dart';
import 'tripmanage/headbutton.dart';
import 'tripmanage/userbutton.dart';
import 'tripmanage/headplan.dart';
import 'tripmanage/userplan.dart';
import 'infoplace.dart';

class TripmanagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'แผนการเดินทาง',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.person_add),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TestUserPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InformationPage(),
            HeadButton(),
            HeadPlan(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TripmanagePage(),
  ));
}
