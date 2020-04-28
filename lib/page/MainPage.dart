import 'package:flutter/material.dart';
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
  PageController pageController = PageController(viewportFraction: 1.0);
  int currentPages = 0;

  final List<Widget> pages = [Home(), Timer(), Lighting()];

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
                      '27 April, 2020',
                      style: TextStyle(
                        height: 0.7,
                        color: Color(0xff9E9E9E),
                        fontSize: s34,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            currentPages = index;
          });
        },
        children: <Widget>[
          Home(),
          Timer(),
          Lighting(),
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
                  color: AppColors.primary,
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
                    onTap: () {},
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
