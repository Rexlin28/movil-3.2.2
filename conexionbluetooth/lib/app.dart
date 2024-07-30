import 'package:flutter/material.dart';

import 'home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Conexion Bluetooth",
      theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.blue,
          primarySwatch: Colors.deepPurple),
      home: Home(),
    );
  }
}
