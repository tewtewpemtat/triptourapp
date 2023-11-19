import 'package:flutter/material.dart';
import 'tripmanage/information.dart';
import 'tripmanage/headbutton.dart';

class TripmanagePage extends StatelessWidget {
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
                // ทำอะไรสักอย่างเมื่อกด icon อีเมล
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          InformationPage(),
          HeadbuttonPage(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TripmanagePage(),
  ));
}
