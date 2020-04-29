import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:smartfish/page/home.dart';
import 'package:smartfish/page/lighting.dart';
import 'package:smartfish/page/timer.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Timer timer;
  //Get now timestamp
  int nowTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  bool newUpdate = false;

  int lastUpdate = 0; //timestamp
  bool connectStatus = false;
  bool loading = false;

  Map<String, dynamic> realtime;
  FirebaseDatabase db = FirebaseDatabase.instance;

  String getDate(int timeStamp, String format) {
    var datetime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    String date;
    date = DateFormat(format).format(datetime);
    return date;
  }

  PreloadPageController pageController =
      PreloadPageController(viewportFraction: 1.0);
  int currentPages = 0;

  // final List<Widget> pages = [Home(), Timer(), Lighting()];
  isConnect(int lastUpdate) {
    print('now timestamp: $nowTimeStamp');
    print('last update: $lastUpdate');
    nowTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    setState(() {
      if (nowTimeStamp - lastUpdate >= 10) {
        connectStatus = false;
      } else {
        connectStatus = true;
      }
    });
  }

  getStatus() {
    loading = true;
    var stream = db.reference().child('realtime').onValue;
    stream.listen((field) {
      realtime = {
        "feed_status": field.snapshot.value['feed_status'],
        "last_update": field.snapshot.value['last_update'],
      };
      if (!field.snapshot.value.isEmpty) {
        setState(() {
          lastUpdate = field.snapshot.value['last_update'];
        });
        print('realtime main: $realtime');
      }
    });
  }

  _scrollTo(int index) {
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 150), curve: Curves.easeInCubic);
  }

  _setCurrentPage(int index) {
    setState(() {
      currentPages = index;
    });
  }

  _getIconColor(int index) {
    if (currentPages == index) {
      return AppColors.iconEnable;
    } else {
      return AppColors.iconDisable;
    }
  }

  @override
  void initState() {
    // for check connection status
    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => isConnect(lastUpdate));
    initializeDateFormatting();
    Intl.defaultLocale = 'th';
    getStatus();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenutilInit(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: screenWidthDp / 15,
              right: screenWidthDp / 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Smart Fish Tank',
                      style: TextStyle(
                        color: Color(0xff414141),
                        fontSize: s52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getDate(nowTimeStamp, 'd MMMM, y'),
                      style: TextStyle(
                        height: 0.7,
                        color: Color(0xff9E9E9E),
                        fontSize: s34,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Icon(
                  connectStatus ? Icons.wifi : OMIcons.wifiOff,
                  size: s52,
                  color: connectStatus
                      ? AppColors.primary
                      : AppColors.connectionLostText,
                ),
              ],
            ),
          ),
        ),
      ),
      body: PreloadPageView(
        controller: pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            currentPages = index;
          });
        },
        children: <Widget>[
          Home(
            connectStatus: connectStatus,
          ),
          TimerConfig(
            connectStatus: connectStatus,
          ),
          Lighting(
            connectStatus: connectStatus,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: bottomBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: InkWell(
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Icon(
                    OMIcons.dashboard,
                    size: s45,
                    color: _getIconColor(0),
                  ),
                ),
                onTap: () {
                  _scrollTo(0);
                  _setCurrentPage(0);
                },
              ),
            ),
            Expanded(
              child: InkWell(
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Icon(
                    OMIcons.accessAlarm,
                    size: s45,
                    color: _getIconColor(1),
                  ),
                ),
                onTap: () {
                  _scrollTo(1);
                  _setCurrentPage(1);
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainButtonShadow,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 20.0,
                  )
                ],
              ),
              child: ClipOval(
                child: Material(
                  color: connectStatus
                      ? AppColors.primary
                      : AppColors.connectionLostColor,
                  child: InkWell(
                    splashColor: Colors.black.withOpacity(0.2),
                    child: Container(
                      width: screenWidthDp / 5.5,
                      height: screenWidthDp / 5.5,
                      padding: EdgeInsets.all(screenWidthDp / 18),
                      child: SvgPicture.asset(
                        'assets/icon/custom_grain.svg',
                      ),
                    ),
                    onTap: connectStatus ? () => {} : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Icon(
                    OMIcons.dataUsage,
                    size: s45,
                    color: _getIconColor(2),
                  ),
                ),
                onTap: () {
                  _scrollTo(2);
                  _setCurrentPage(2);
                },
              ),
            ),
            Expanded(
              child: InkWell(
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Icon(
                    OMIcons.notificationsActive,
                    size: s45,
                    color: _getIconColor(3),
                  ),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
