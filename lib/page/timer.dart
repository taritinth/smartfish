import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';

class Timer extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> with AutomaticKeepAliveClientMixin {
  int _hourValue = 0, _minValue = 0, _durValue = 200;
  bool toggleValue = false;

  _toggleButton() {
    setState(() {
      toggleValue = !toggleValue;
    });
  }

  @override
  bool get wantKeepAlive => true;

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
                      'ตั้งเวลาให้อาหาร',
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
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${_hourValue.toString().padLeft(2, '0')}:${_minValue.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: s60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' $_durValue ms',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: s60,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'ชั่วโมง',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: s45,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withOpacity(0.2),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: screenWidthDp / 60,
                          thumbColor: AppColors.primary,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayColor: AppColors.primary.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 5),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: AppColors.primary,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: _hourValue.toDouble(),
                          min: 0.0,
                          max: 23.0,
                          divisions: 23,
                          label: '$_hourValue',
                          onChanged: (value) {
                            setState(() {
                              _hourValue = value.round();
                            });
                          },
                        ),
                      ),
                      Text(
                        'นาที',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: s45,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withOpacity(0.2),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: screenWidthDp / 60,
                          thumbColor: AppColors.primary,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayColor: AppColors.primary.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 5),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: AppColors.primary,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: _minValue.toDouble(),
                          min: 0.0,
                          max: 59.0,
                          divisions: 59,
                          label: '$_minValue',
                          onChanged: (double value) {
                            setState(() {
                              _minValue = value.round();
                            });
                          },
                        ),
                      ),
                      Text(
                        'ระยะเวลา (ms)',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: s45,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withOpacity(0.2),
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: screenWidthDp / 60,
                          thumbColor: AppColors.primary,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayColor: AppColors.primary.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 5),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: AppColors.primary,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          value: _durValue.toDouble(),
                          min: 200.0,
                          max: 3000.0,
                          divisions: 14,
                          label: '$_durValue',
                          onChanged: (value) {
                            setState(() {
                              _durValue = value.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
