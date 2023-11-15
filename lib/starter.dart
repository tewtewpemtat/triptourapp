import 'package:flutter/material.dart';
import 'package:triptourapp/authen/login.dart';

void main() {
  runApp(Starter());
}

class Starter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IntroducePage(),
      ),
    );
  }
}

class IntroducePage extends StatefulWidget {
  @override
  _IntroducePageState createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {
  final List<String> imagePaths = ['assets/cat.jpg', 'assets/00.jpg'];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Automatically transition to the next page every 2 seconds
    Future.delayed(Duration(seconds: 3), _autoTransition);
  }

  void _autoTransition() {
    if (_currentPage < imagePaths.length - 1) {
      _pageController.nextPage(
          duration: Duration(seconds: 2), curve: Curves.easeInOut);
    } else {
      _pageController.jumpToPage(0);
    }
    Future.delayed(Duration(seconds: 3), _autoTransition);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 50%: Image
        Expanded(
          flex: 5,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Image.asset(
                imagePaths[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        // Bottom 50%: Text and Button
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'TripTour',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'เเอปพลิเคชั่นวางเแผนจัดทริปท่องเที่ยว',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ที่ช่วยให้คุณเเละกลุ่มเพื่อนของคุณท่อง',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'เที่ยวกันเป็นกลุ่มได้อย่างสะดวกยิ่งขึ้น',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text('เริ่มต้น'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        fixedSize: Size(300, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
