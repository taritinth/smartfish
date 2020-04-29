import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  bool connectStatus;
  Home({@required this.connectStatus});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Get now timestamp
  int nowTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  int lastUpdate = 0; //timestamp
  double waterTemp = 0, turbidity = 5;
  int foodRemain = 100;

  Map<String, dynamic> realtime;
  FirebaseDatabase db = FirebaseDatabase.instance;
  bool loading = true;

  String getDate(int timeStamp, String format) {
    var datetime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    String date;
    date = DateFormat(format).format(datetime);
    return date;
  }

  getRealtime() {
    var stream = db.reference().child('realtime').onValue;
    stream.listen((field) {
      realtime = {
        "feed_status": field.snapshot.value['feed_status'],
        "food_remain": field.snapshot.value['food_remain'],
        "last_update": field.snapshot.value['last_update'],
        "turbidity": field.snapshot.value['turbidity'],
        "water_temp": field.snapshot.value['water_temp']
      };
      if (!field.snapshot.value.isEmpty) {
        setState(() {
          lastUpdate = field.snapshot.value['last_update'];
          waterTemp = field.snapshot.value['water_temp'];
          foodRemain = field.snapshot.value['food_remain'];
          turbidity = field.snapshot.value['turbidity'].toDouble();
        });
        print('realtime main: $realtime');
      }
    });
  }

  turbidityStandard(int turb) {
    switch (turb) {
      case 0:
        return 'แย่มาก';
        break;

      case 1:
        return 'แย่';
        break;

      case 2:
        return 'ไม่ดี';
        break;

      case 3:
        return 'ไม่ค่อยดี';
        break;

      case 4:
        return 'ปกติ';
        break;

      case 5:
        return 'ดีมาก';
        break;
    }
  }

  turbidityComment(int turb) {
    switch (turb) {
      case 0:
        return 'เปลี่ยนน้ำเถอะขอร้อง';
        break;

      case 1:
        return 'เปลี่ยนน้ำทันที';
        break;

      case 2:
        return 'ควรเปลี่ยนน้ำ';
        break;

      case 3:
        return 'เปลี่ยนน้ำก็ดีนะ';
        break;

      case 4:
        return 'ไม่จำเป็นต้องเปลี่ยนน้ำ';
        break;

      case 5:
        return 'ไม่จำเป็นต้องเปลี่ยนน้ำ';
        break;
    }
  }

  @override
  void initState() {
    initializeDateFormatting();
    Intl.defaultLocale = 'th';
    getRealtime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenutilInit(context);
    return Scaffold(
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidthDp / 25,
        mainAxisSpacing: screenWidthDp / 25,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidthDp / 15, vertical: screenHeightDp / 20),
        children: <Widget>[
          InkWell(
            // onTap: () async {
            //   var test = await Database().getRealtime();
            //   print('Home : ${test["timestamp"]}');
            //   setState(() {
            //     realtime = test["timestamp"];
            //     widget.connectStatus = !widget.connectStatus;
            //   });
            // },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.all(
                screenWidthDp / 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidthDp / 15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 20.0,
                  )
                ],
                color: widget.connectStatus
                    ? AppColors.primary
                    : AppColors.connectionLost,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'สถานะ',
                        style: TextStyle(
                          color: widget.connectStatus
                              ? Colors.white
                              : AppColors.connectionLostText,
                          fontSize: s45,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    widget.connectStatus ? Icons.wifi : OMIcons.wifiOff,
                    size: screenWidthDp / 6,
                    color: widget.connectStatus
                        ? Colors.white
                        : AppColors.connectionLostText,
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        widget.connectStatus
                            ? 'เชื่อมต่อแล้ว'
                            : 'ไม่ได้เชื่อมต่อ',
                        style: TextStyle(
                          color: widget.connectStatus
                              ? Colors.white
                              : AppColors.connectionLostText,
                          fontSize: s48,
                        ),
                      ),
                      Text(
                        'ล่าสุด ${getDate(lastUpdate, 'd MMM HH:mm')} น.',
                        style: TextStyle(
                          height: 0.7,
                          color: widget.connectStatus
                              ? Colors.white54
                              : Colors.grey.withOpacity(0.7),
                          fontSize: s28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              screenWidthDp / 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidthDp / 15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0.0, 10.0),
                  blurRadius: 20.0,
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'อุณหภูมิของน้ำ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: s45,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$waterTemp',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: s60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'องศาเซลเซียส',
                        style: TextStyle(
                          height: 0.7,
                          color: Colors.black38,
                          fontSize: s28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              screenWidthDp / 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidthDp / 15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0.0, 10.0),
                  blurRadius: 20.0,
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'อาหารที่เหลือ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: s45,
                      ),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  radius: screenWidthDp / 3.5,
                  lineWidth: screenWidthDp / 40,
                  animation: true,
                  percent: foodRemain.toDouble() / 100,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '$foodRemain',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: s60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                          height: 0,
                          color: Colors.black38,
                          fontSize: s28,
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.softGrey,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(
              screenWidthDp / 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidthDp / 15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0.0, 10.0),
                  blurRadius: 20.0,
                )
              ],
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'คุณภาพน้ำ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: s45,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        turbidityStandard(turbidity.round()),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: s60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        turbidityComment(turbidity.round()),
                        style: TextStyle(
                          height: 0.7,
                          color: Colors.black38,
                          fontSize: s28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        staggeredTiles: [
          StaggeredTile.extent(1, screenWidthDp / 2),
          StaggeredTile.extent(1, screenWidthDp / 3),
          StaggeredTile.extent(1, screenWidthDp / 2),
          StaggeredTile.extent(1, screenWidthDp / 3),
        ],
      ),
    );
  }
}
