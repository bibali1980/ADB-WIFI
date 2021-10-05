
import 'package:adb_wifi/pages/HomePage.dart';
import 'package:flutter/material.dart';

import 'Classes/PreferenceUtils.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADB Wifi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
