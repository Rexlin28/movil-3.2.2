import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final bluetooth = FlutterBluetoothSerial.instance;
  bool estadoBT = false;
  bool conectado = false;
  var contenido;
  BluetoothConnection? conexion;
  List<BluetoothDevice>? dispositivos = [];
  BluetoothDevice? activo;

  void _permisos() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void _estadoBT() {
    bluetooth.state.then(
          (value) {
        estadoBT = value.isEnabled;
        setState(() {});
      },
    );
    bluetooth.onStateChanged().listen((event) {
      setState(() {
        switch (event) {
          case BluetoothState.STATE_ON:
            estadoBT = true;
            break;
          case BluetoothState.STATE_OFF:
            estadoBT = false;
            break;
          case BluetoothState.STATE_BLE_TURNING_OFF:
            debugPrint("Se está apagando el BT");
            break;
          case BluetoothState.STATE_BLE_TURNING_ON:
            debugPrint("Se está encendiendo el BT");
            break;
        }
        setState(() {});
      });
    });
  }

  void encender() async {
    await bluetooth.requestEnable();
  }

  void apagar() async {
    await bluetooth.requestDisable();
  }

  Widget botonBT() {
    return SwitchListTile(
      value: estadoBT,
      title: Text(estadoBT ? "Encendido" : "Apagado"),
      tileColor: estadoBT ? Colors.green : Colors.grey,
      secondary:
      estadoBT ? const Icon(Icons.bluetooth_connected) : const Icon(Icons.bluetooth_disabled),
      onChanged: (value) {
        if (value) {
          encender();
        } else {
          apagar();
        }
        setState(() {
          estadoBT = value;
          leerDispositivos();
        });
      },
    );
  }

  void leerDispositivos() async {
    dispositivos = await bluetooth.getBondedDevices();
    debugPrint(dispositivos?[0].name);
    debugPrint(dispositivos?[0].address);
    setState(() {});
  }

  Widget lista() {
    if (dispositivos!.isEmpty) {
      return const Text("No hay dispositivos");
    } else {
      if (conectado) {
        return Text(contenido);
      } else {
        return ListView.builder(
          itemCount: dispositivos?.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: IconButton(
                icon: const Icon(Icons.bluetooth),
                onPressed: () async {
                  conexion = await BluetoothConnection.toAddress(
                      dispositivos![index].address);
                  activo = dispositivos![index];
                  recibirDatos();
                  conectado = true;
                  setState(() {});
                },
              ),
              trailing: Text(
                "${dispositivos?[index].address}",
                style: const TextStyle(color: Colors.green, fontSize: 15),
              ),
              title: Text("${dispositivos?[index].name}"),
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _permisos();
    _estadoBT();
  }

  Widget dispositivo() {
    return ListTile(
        title: activo == null
            ? const Text("No conectado")
            : Text("${activo?.name}"),
        subtitle: activo == null
            ? const Text("No Mac address")
            : Text("${activo?.address}"),
        leading: activo == null
            ? IconButton(
            onPressed: () {
              leerDispositivos();
            },
            icon: const Icon(Icons.delete))
            : IconButton(
            onPressed: () {
              activo = null;
              conectado = false;
              dispositivos = [];
              conexion?.finish();
              contenido = "";
              setState(() {});
            },
            icon: const Icon(Icons.search_rounded)));
  }

  void enviarDatos(String msg) {
    if (conexion!.isConnected) {
      conexion?.output.add(ascii.encode("$msg\n"));
    }
  }

  Widget botonera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CupertinoButton(
            child: const Text("Led on"),
            onPressed: () {
              enviarDatos("led on");
            }),
        CupertinoButton(
            child: const Text("Led off"),
            onPressed: () {
              enviarDatos("led off");
            }),
        CupertinoButton(
            child: const Text("Hello"),
            onPressed: () {
              enviarDatos("hello");
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth"),
      ),
      body: Column(
        children: <Widget>[
          botonBT(),
          const Divider(
            height: 5,
          ),
          Expanded(child: lista()),
        ],
      ),
    );
  }

  void recibirDatos() async {
    contenido = "";
    conexion?.input?.listen((event) {
      debugPrint(String.fromCharCodes(event));
      contenido = String.fromCharCodes(event);
    });
  }
}
