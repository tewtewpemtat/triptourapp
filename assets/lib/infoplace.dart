import 'package:flutter/material.dart';
import 'infoplace/headinfobutton.dart';
import 'infoplace/infomationplace.dart';
import 'infoplace/member.dart';

class InfoPlacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
              icon: Icon(Icons.chat),
              onPressed: () {},
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
