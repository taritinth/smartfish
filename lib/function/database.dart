import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import '../page/timer.dart';

class Database {
  FirebaseDatabase db = FirebaseDatabase.instance;

  getDBRef() {
    return db;
  }

  //update log
  updateLog(int newLog) async {
    await db.reference().child('log').update({"system_start": newLog});
  }

  ///get Log [return int]
  getLog() async {
    int log;
    await db.reference().child('log').once().then((DataSnapshot field) {
      log = field.value['system_start'];
    });

    return log;
  }

  ///get realtime [return Map {feed_status, food_remain, timestamp, turbidity, water_temp} ]
  getRealtime() async {
    Map<String, dynamic> realtime;
    await db.reference().child('realtime').once().then((DataSnapshot field) {
      realtime = {
        "feed_status": field.value['feed_status'],
        "food_remain": field.value['food_remain'],
        "timestamp": field.value['timestamp'],
        "turbidity": field.value['turbidity'],
        "water_temp": field.value['water_temp']
      };
      print(realtime);
      // result = jsonEncode(realtime);
    });
    // realtimeStr = jsonEncode(realtime);
    return realtime;
  }

  ///get rgb [return Map {mode, status}]
  getRGB() async {
    Map<String, String> rgb;
    await db.reference().child('rgb').once().then((DataSnapshot field) {
      rgb = {"mode": field.value['mode'], "status": field.value['status']};
    });
    return rgb;
  }

  ///get timer [return Map{timer1{duration,hour,minute,status}}]
  getTimer() async {
    Map<String, String> timer;
    await db
        .reference()
        .child('timer')
        .child("timer1")
        .once()
        .then((DataSnapshot field) {
      timer = {
        "duration": field.value['duration'],
        "hour": field.value['hour'],
        "minute": field.value['minute'],
        "status": field.value['status'],
      };
    });
    return timer;
  }

  //set timer
  setTimer(int duration, int hour, int minute, bool status) async {
    await db.reference().child('timer').child('timer1').set({
      "duration": duration,
      "hour": hour,
      "minute": minute,
      "status": status,
    });
  }
}
