import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartfish/theme/AppColors.dart';
import 'package:smartfish/theme/ScreenUtil.dart';

class TimerConfig extends StatefulWidget {
  bool connectStatus;
  TimerConfig({@required this.connectStatus});
  @override
  _TimerConfigState createState() => _TimerConfigState();
}

class _TimerConfigState extends State<TimerConfig>
    with AutomaticKeepAliveClientMixin {
  int _hourValue = 0, _minValue = 0, _durValue = 200;
  bool _timerStatus = false;

  Map<String, dynamic> timer;
  FirebaseDatabase db = FirebaseDatabase.instance;
  _toggleButton() {
    setState(() {
      //update true / false to timer status
      db.reference().child('timer/timer1').update({
        "timer1_status": !_timerStatus,
      });
    });
  }

  getTimer() {
    var stream = db.reference().child('timer/timer1').onValue;
    stream.listen((field) {
      timer = {
        "duration": field.snapshot.value['duration'],
        "hour": field.snapshot.value['hour'],
        "minute": field.snapshot.value['minute'],
        "timer1_status": field.snapshot.value['timer1_status']
      };
      setState(() {
        _hourValue = field.snapshot.value['hour'];
        _minValue = field.snapshot.value['minute'];
        _durValue = field.snapshot.value['duration'];
        _timerStatus = field.snapshot.value['timer1_status'];
      });
      print('timer : $timer');
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    getTimer();
    super.initState();
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
                      'ตั้งเวลาให้อาหาร',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: s45,
                      ),
                    ),
                    InkWell(
                      onTap: widget.connectStatus ? _toggleButton : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        height: screenWidthDp / 12.5,
                        width: screenWidthDp / 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidthDp),
                          color: _timerStatus
                              ? AppColors.toggleEnable
                              : AppColors.toggleDisable,
                        ),
                        child: Stack(
                          children: <Widget>[
                            AnimatedPositioned(
                                duration: Duration(milliseconds: 150),
                                curve: Curves.easeIn,
                                left: _timerStatus
                                    ? ((screenWidthDp / 7) / 2) + 6
                                    : 0,
                                right: _timerStatus
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
                        ' ${_durValue.toString()} ms',
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
                          label: '${_hourValue.toString()}',
                          onChanged: (value) {
                            if (widget.connectStatus) {
                              _hourValue = value.round();
                              setState(() {
                                db.reference().child('timer/timer1').update({
                                  "hour": value.round(),
                                });
                              });
                            }
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
                          label: '${_minValue.toString()}',
                          onChanged: (double value) {
                            if (widget.connectStatus) {
                              _minValue = value.round();
                              setState(() {
                                db.reference().child('timer/timer1').update({
                                  "minute": value.round(),
                                });
                              });
                            }
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
                          label: '${_durValue.toString()}',
                          onChanged: (value) {
                            if (widget.connectStatus) {
                              _durValue = value.round();
                              setState(() {
                                db.reference().child('timer/timer1').update({
                                  "duration": value.round(),
                                });
                              });
                            }
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
