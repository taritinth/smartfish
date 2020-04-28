import 'package:flutter/material.dart';
import 'package:smartfish/theme/ScreenUtil.dart';

class Lighting extends StatefulWidget {
  @override
  _LightingState createState() => _LightingState();
}

class _LightingState extends State<Lighting> {
  @override
  Widget build(BuildContext context) {
    screenutilInit(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Lighting",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: s52,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
