import 'package:flutter/material.dart';
import 'package:triptourapp/tripmanage.dart';
import 'tripmanage/information.dart';
import 'tripmanage/headbutton.dart';
import 'tripmanage/userbutton.dart';
import 'tripmanage/headplan.dart';
import 'tripmanage/userplan.dart';

class TestUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'แผนการเดินทาง',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(Icons.mail),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TripmanagePage()),
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
            UserButton(),
            UserPlan(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TestUserPage(),
  ));
}