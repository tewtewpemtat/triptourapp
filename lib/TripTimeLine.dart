import 'package:flutter/material.dart';
import 'package:triptourapp/timeline/Timeline_History.dart';
import 'main/top_navbar.dart';
import 'main/bottom_navbar.dart';

void main() {
  runApp(TripTimeLine());
}

class TripTimeLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTour',
      home: Scaffold(
        appBar: TopNavbar(),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              TripTimelinePage(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 2,
          onItemTapped: (index) {},
        ),
      ),
    );
  }
}
