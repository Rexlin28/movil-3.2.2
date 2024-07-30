import 'package:flutter/material.dart';

import 'home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WiFi ESP32",
      theme: ThemeData(
          primarySwatch: Colors.blue, primaryColor: Colors.deepPurple
      ),
      home: Home(),
    );
  }
}
