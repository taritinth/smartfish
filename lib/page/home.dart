import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
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
              color: AppColors.primary,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'สถานะ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: s45,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.wifi,
                  size: screenWidthDp / 6,
                  color: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'เชื่อมต่ออยู่',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: s48,
                      ),
                    ),
                    Text(
                      'ข้อมูลล่าสุด วันนี้ 20:21 น.',
                      style: TextStyle(
                        height: 0.7,
                        color: Colors.white54,
                        fontSize: s28,
                      ),
                    ),
                  ],
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
                        '27.09',
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
                  percent: 0.7,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '70',
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
                      'ความขุ่นของน้ำ',
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
                        'ปกติ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: s60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ไม่จำเป็นต้องเปลี่ยนน้ำ',
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
