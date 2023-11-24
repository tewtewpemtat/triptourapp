import 'package:flutter/material.dart';
import 'package:triptourapp/tripmanage.dart';
import 'infoplace/groupchat.dart';
import 'infoplace/headinfobutton.dart';
import 'infoplace/infomationplace.dart';
import 'infoplace/member.dart';

class InfoPlacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TripmanagePage()),
            );
          },
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
              color: Colors.black,
              icon: Icon(Icons.chat),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GroupScreenPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [InformationPlan(), HeadInfoButton(), MemberPage()],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InfoPlacePage(),
  ));
}
