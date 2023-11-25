import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/authen/login.dart';

void main() {
  runApp(splash());
}

class splash extends StatelessWidget {
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
  final List<String> imagePaths = [
    'assets/splash/splash_image1.png',
    'assets/splash/splash_image2.png',
    'assets/splash/splash_image3.png',
    'assets/splash/splash_image4.png'
  ];
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
          duration: Duration(seconds: 3), curve: Curves.easeInOut);
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
          flex: 8,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return FractionallySizedBox(
                heightFactor: 1, // ลองปรับค่านี้เพื่อเปลี่ยนความสูง
                child: Image.asset(
                  imagePaths[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),

        // Bottom 50%: Text and Button
        // 50% ล่าง: ข้อความและปุ่ม
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment
                .center, // เปลี่ยนจาก Alignment.topCenter เป็น Alignment.center
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // เพิ่มบรรทัดนี้
                      children: [
                        Text(
                          'Trip',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          'Tour',
                          style: GoogleFonts.ibmPlexSansThai(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE59730),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    SizedBox(height: 17),
                    Text(
                      'แอปพลิเคชันวางแผนจัดทริปท่องเที่ยว',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ที่ช่วยให้คุณและกลุ่มเพื่อนของคุณท่อง',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'เที่ยวกันเป็นกลุ่มได้อย่างสะดวกยิ่งขึ้น',
                      style: GoogleFonts.ibmPlexSansThai(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: 391,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffdb923c),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'ดำเนินการต่อ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
