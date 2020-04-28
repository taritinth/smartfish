import 'package:flutter/material.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';

class Lighting extends StatefulWidget {
  @override
  _LightingState createState() => _LightingState();
}

class _LightingState extends State<Lighting>
    with AutomaticKeepAliveClientMixin {
  String selectMode = 'Cycle';
  bool toggleValue = false;

  _toggleButton() {
    setState(() {
      toggleValue = !toggleValue;
    });
  }

  _selectMode(String mode) {
    setState(() {
      selectMode = mode;
    });
  }

  @override
  bool get wantKeepAlive => true;

  Widget rgbItem(String mode, IconData rgbIcon) {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: AnimatedContainer(
            width: screenWidthDp / 4.5,
            height: screenWidthDp / 4.5,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.6),
                width: 0.2,
              ),
              borderRadius: BorderRadius.circular(screenWidthDp / 15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  offset: Offset(0.0, 10.0),
                  blurRadius: 20.0,
                )
              ],
              color: selectMode == mode ? AppColors.primary : Colors.white,
            ),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Center(
              child: Icon(
                rgbIcon,
                size: s52,
                color: selectMode == mode ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          onTap: () {
            _selectMode(mode);
          },
        ),
        Text(
          mode,
          style: TextStyle(
            color: Colors.black38,
            fontSize: s38,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenutilInit(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: screenWidthDp,
            padding: EdgeInsets.all(
              screenWidthDp / 20,
            ),
            margin: EdgeInsets.symmetric(
                horizontal: screenWidthDp / 15, vertical: screenHeightDp / 20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'RGB Lighting',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: s45,
                      ),
                    ),
                    InkWell(
                      onTap: _toggleButton,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: screenWidthDp / 12.5,
                        width: screenWidthDp / 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidthDp),
                          color: toggleValue
                              ? AppColors.toggleEnable
                              : AppColors.toggleDisable,
                        ),
                        child: Stack(
                          children: <Widget>[
                            AnimatedPositioned(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                                left: toggleValue
                                    ? ((screenWidthDp / 7) / 2) + 6
                                    : 0,
                                right: toggleValue
                                    ? 0
                                    : ((screenWidthDp / 7) / 2) + 6,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.6),
                                          width: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            screenWidthDp),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.cardShadow,
                                            offset: Offset(0.0, 10.0),
                                            blurRadius: 20.0,
                                          )
                                        ],
                                      ),
                                      width: screenWidthDp / 12.5,
                                      height: screenWidthDp / 12.5,
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: screenWidthDp / 22,
                      children: <Widget>[
                        rgbItem('Cycle', Icons.all_inclusive),
                        rgbItem('Wave', Icons.vibration),
                        rgbItem('Solo', Icons.equalizer),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
