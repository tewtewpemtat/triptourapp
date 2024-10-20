import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../infoplace.dart';

class HeadPlan extends StatefulWidget {
  final String? tripUid;
  const HeadPlan({Key? key, this.tripUid}) : super(key: key);
  _HeadPlanPageState createState() => _HeadPlanPageState();
}

class _HeadPlanPageState extends State<HeadPlan> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [buildTripItem(context)],
    );
  }

  Widget buildTripItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPlacePage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/headplan/headplan_image1.png',
                  width: 100.0,
                  height: 170.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              flex: 6,
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '1.ร้านจาคอฟฟี',
                            style: GoogleFonts.ibmPlexSansThai(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.remove),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color(0xFF1E30D7),
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กรุงเทพมหานคร',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color(0xffdc933c),
                      ),
                      padding: EdgeInsets.all(3.0),
                      child: Text(
                        'กำหนดการเวลา : 00:00',
                        style: GoogleFonts.ibmPlexSansThai(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Text('จำนวนผู้เข้าร่วม : 16',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Text('ห่าง 15Km จากตำแหน่งของคุณ',
                        style: GoogleFonts.ibmPlexSansThai(fontSize: 12)),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Color(0xffcfcfcf),
                                fixedSize: Size(70, 10),
                              ),
                              child: Text(
                                'จุดนัดพบ',
                                style: GoogleFonts.ibmPlexSansThai(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HeadPlan(),
  ));
}
