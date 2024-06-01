import 'package:flutter/material.dart';
import 'package:triptourapp/authen/login.dart';
import 'main/bottom_navbar.dart';
import 'main/top_navbar.dart';
import 'main/tripbutton.dart';
import 'main/triphistory.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  initializeDateFormatting('th', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: AuthenticationWrapper(),
    ),
  );
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            if (snapshot.hasData) {
              return MyApp();
            } else {
              return LoginPage();
            }
          }
        } catch (error) {
          print("Error: $error");
        }

        return Container();
      },
    );
  }
}

class MyApp extends StatelessWidget {
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
              TripButtons(),
              TripHistory(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: 0,
          onItemTapped: (index) {},
        ),
      ),
    );
  }
}
