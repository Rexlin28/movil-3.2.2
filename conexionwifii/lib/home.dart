import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';

import 'api.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  bool visible = false;
  double? temperatura, humedad;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    temperatura = 0;
    humedad = 0;
  }

  void get() async {
    String tem = await Api.getSensor("temperature");
    String hum = await Api.getSensor("humidity");

    if (!tem.contains("Error") && !hum.contains("Error")) {
      temperatura = double.parse(tem);
      humedad = double.parse(hum);
      setState(() {
        visible = true;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Temperatura"),
      ),
      body: Visibility(
        visible: visible,
        replacement: const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
        child: Builder(
          builder: (context) {
            if (temperatura != 0 && humedad != 0) {
              return ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Temperatura: $temperatura"),
                  ),
                  ListTile(
                    title: Text("Humedad: $humedad"),
                  ),
                ],
              );
            } else {
              return ListTile(title: const Text("Error de lectura"),
                leading: CupertinoButton(onPressed:() async {
                  get();
                },
                  child: const Icon(Icons.download),),);
            }
          },
        ),
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
    Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        visible = false;
      });
    });
    get();
  }
}
