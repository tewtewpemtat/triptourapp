import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triptourapp/placetimeline.dart';

class TimelinePainter extends CustomPainter {
  final bool hasEntry;
  final bool hasExit;

  TimelinePainter({this.hasEntry = false, this.hasExit = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    final circlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    if (hasEntry) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 3),
        6,
        circlePaint,
      );
    }

    if (hasExit) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 4 * 3.2),
        6,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TimelinePainter2 extends CustomPainter {
  final bool hasEntry;
  final bool hasExit;

  TimelinePainter2({this.hasEntry = false, this.hasExit = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    final circlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    if (hasEntry) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 4),
        6,
        circlePaint,
      );
    }

    if (hasExit) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 4 * 3.4),
        6,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TimelinePainter3 extends CustomPainter {
  final bool hasEntry;
  final bool hasExit;

  TimelinePainter3({this.hasEntry = false, this.hasExit = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    final circlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    if (hasEntry) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 1.65),
        6,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PlaceTimelineDetail extends StatefulWidget {
  final String placeId;
  final String tripUid;
  final String userUid;

  const PlaceTimelineDetail({
    Key? key,
    required this.placeId,
    required this.tripUid,
    required this.userUid,
  }) : super(key: key);

  @override
  _PlaceTimelineDetailState createState() => _PlaceTimelineDetailState();
}

class _PlaceTimelineDetailState extends State<PlaceTimelineDetail> {
  late Stream<QuerySnapshot> _timelineStream;

  @override
  void initState() {
    super.initState();
    _timelineStream = FirebaseFirestore.instance
        .collection('timelinestamp')
        .where('placeid', isEqualTo: widget.placeId)
        .where('placetripid', isEqualTo: widget.tripUid)
        .where('useruid', isEqualTo: widget.userUid)
        .orderBy('intime', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "  ไทมไลน์",
          style: GoogleFonts.ibmPlexSansThai(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Placetimeline(tripUid: widget.tripUid),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _timelineStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('ไม่มีไทมไลน์ของสถานที่นี้'));
          }

          var previousDate;
          var previousDateIn;
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var timelineData = snapshot.data!.docs[index];
              var intime = timelineData['intime'];
              var outtime = timelineData['outtime'];
              int distance = timelineData['distance'].toInt();

              var thaiFormatter = DateFormat('d MMMM yyyy', 'th');
              var thaiDateIn = thaiFormatter.format(intime.toDate());
              var thaiDateOut;
              if (outtime != "Wait") {
                thaiDateOut = thaiFormatter.format(outtime.toDate());
              }
              bool outwait = outtime == "Wait";
              var thaiFormatter2 = DateFormat('HH:mm', 'th');
              var thaiIntime = thaiFormatter2.format(intime.toDate());
              var thaiOuttime;
              if (outtime != "Wait") {
                thaiOuttime = thaiFormatter2.format(outtime.toDate());
              }

              var isDateChanged = previousDate != thaiDateIn;
              bool isSameDay = thaiDateIn == thaiDateOut;
              previousDate = thaiDateOut;
              var isDateChangedIn = previousDateIn != thaiDateIn;
              previousDateIn = thaiDateIn;

              return !outwait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDateChanged && isDateChangedIn)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              thaiDateIn,
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        isSameDay
                            ? CustomPaint(
                                size: Size(100, 200),
                                painter: TimelinePainter(
                                  hasEntry: true,
                                  hasExit: true,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'เข้า:  $thaiIntime',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ระยะ: $distance',
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'ออก: $thaiOuttime',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ระยะ: $distance',
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : CustomPaint(
                                size: Size(100, 200),
                                painter: TimelinePainter2(
                                  hasEntry: true,
                                  hasExit: true,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'เข้า:  $thaiIntime',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ระยะ: $distance',
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          child: Text(
                                            thaiDateOut,
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          subtitle: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ออก: $thaiOuttime',
                                                  style: GoogleFonts
                                                      .ibmPlexSansThai(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'ระยะ: $distance',
                                                style:
                                                    GoogleFonts.ibmPlexSansThai(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDateChangedIn)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              thaiDateIn,
                              style: GoogleFonts.ibmPlexSansThai(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        isSameDay
                            ? CustomPaint(
                                size: Size(100, 200),
                                painter: TimelinePainter3(
                                  hasEntry: true,
                                  hasExit: true,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'เข้า:  $thaiIntime',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ระยะ: $distance',
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : CustomPaint(
                                size: Size(100, 200),
                                painter: TimelinePainter3(
                                  hasEntry: true,
                                  hasExit: true,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'เข้า:  $thaiIntime',
                                              style:
                                                  GoogleFonts.ibmPlexSansThai(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ระยะ: $distance',
                                            style: GoogleFonts.ibmPlexSansThai(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    );
            },
          );
        },
      ),
    );
  }
}
