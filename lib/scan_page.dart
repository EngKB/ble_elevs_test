import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/control_page.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<AndroidBluetoothLack> _blueLack = [];
  IosBluetoothState _iosBlueState = IosBluetoothState.unKnown;
  List<ScanResult> _scanResultList = [];
  void iosGetBlueState(timer) {
    FlutterBlueElves.instance.iosCheckBluetoothState().then((value) {
      setState(() {
        _iosBlueState = value;
      });
    });
  }

  void androidGetBlueLack(timer) {
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) {
      setState(() {
        _blueLack = values;
      });
    });
  }

  @override
  void initState() {
    Timer.periodic(const Duration(milliseconds: 2000),
        Platform.isAndroid ? androidGetBlueLack : iosGetBlueState);
    FlutterBlueElves.instance.startScan(5000).listen((event) {
      print(event.id + " " + event.uuids.toString());
      setState(() {
        if (event.uuids.contains('6e400001-b5a3-f393-e0a9-e50e24dcca9e')) {
          _scanResultList.add(event);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FlutterBlueElves.instance.startScan(30000).listen((event) {
              print(event.id + " " + event.uuids.toString());
              setState(() {
                if (event.uuids
                    .contains('6e400001-b5a3-f393-e0a9-e50e24dcca9e')) {
                  _scanResultList.add(event);
                }
              });
            });
          },
          child: const Text('scan'),
        ),
        appBar: AppBar(
          toolbarHeight: Platform.isAndroid ? 100 : null,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Platform.isAndroid
                ? [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: _blueLack.contains(
                                      AndroidBluetoothLack.locationPermission)
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            icon: Icon(_blueLack.contains(
                                    AndroidBluetoothLack.locationPermission)
                                ? Icons.error
                                : Icons.done),
                            label: const Text("GPS Permission",
                                style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              if (_blueLack.contains(
                                  AndroidBluetoothLack.locationPermission)) {
                                FlutterBlueElves.instance
                                    .androidApplyLocationPermission((isOk) {
                                  print(isOk
                                      ? "User agrees to grant location permission"
                                      : "User does not agree to grant location permission");
                                });
                              }
                            },
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: _blueLack.contains(
                                      AndroidBluetoothLack.locationFunction)
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            icon: Icon(_blueLack.contains(
                                    AndroidBluetoothLack.locationFunction)
                                ? Icons.error
                                : Icons.done),
                            label: const Text(
                              "GPS",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              if (_blueLack.contains(
                                  AndroidBluetoothLack.locationFunction)) {
                                FlutterBlueElves.instance
                                    .androidOpenLocationService((isOk) {
                                  print(isOk
                                      ? "The user agrees to turn on the positioning function"
                                      : "The user does not agree to enable the positioning function");
                                });
                              }
                            },
                          ),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: _blueLack.contains(
                                      AndroidBluetoothLack.bluetoothPermission)
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            icon: Icon(_blueLack.contains(
                                    AndroidBluetoothLack.bluetoothPermission)
                                ? Icons.error
                                : Icons.done),
                            label: const Text("Blue Permission",
                                style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              if (_blueLack.contains(
                                  AndroidBluetoothLack.bluetoothPermission)) {
                                FlutterBlueElves.instance
                                    .androidApplyBluetoothPermission((isOk) {
                                  print(isOk
                                      ? "User agrees to grant Bluetooth permission"
                                      : "User does not agree to grant Bluetooth permission");
                                });
                              }
                            },
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: _blueLack.contains(
                                      AndroidBluetoothLack.bluetoothFunction)
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            icon: Icon(_blueLack.contains(
                                    AndroidBluetoothLack.bluetoothFunction)
                                ? Icons.error
                                : Icons.done),
                            label: const Text(
                              "Blue",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              if (_blueLack.contains(
                                  AndroidBluetoothLack.bluetoothFunction)) {
                                FlutterBlueElves.instance
                                    .androidOpenBluetoothService((isOk) {
                                  print(isOk
                                      ? "The user agrees to turn on the Bluetooth function"
                                      : "The user does not agree to enable the Bluetooth function");
                                });
                              }
                            },
                          ),
                        ])
                  ]
                : [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              _iosBlueState == IosBluetoothState.poweredOn
                                  ? Colors.green
                                  : Colors.red),
                      icon: Icon(_iosBlueState == IosBluetoothState.poweredOn
                          ? Icons.done
                          : Icons.error),
                      label: Text(
                          "BlueToothState:" +
                              _iosBlueState
                                  .toString()
                                  .replaceAll(RegExp("IosBluetoothState."), ""),
                          style: const TextStyle(color: Colors.black)),
                      onPressed: () {
                        if (_iosBlueState == IosBluetoothState.unKnown) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text("Tip"),
                                content: Text(
                                    "Bluetooth is not initialized, please wait"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (_iosBlueState ==
                            IosBluetoothState.resetting) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text("Tip"),
                                content:
                                    Text("Bluetooth is resetting, please wait"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (_iosBlueState ==
                            IosBluetoothState.unSupport) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text("Tip"),
                                content: Text(
                                    "The current device does not support Bluetooth, please check"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (_iosBlueState ==
                            IosBluetoothState.unAuthorized) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text("Tip"),
                                content: Text(
                                    "The current app does not have Bluetooth permission, please go to the settings to grant"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (_iosBlueState ==
                            IosBluetoothState.poweredOff) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text("Tip"),
                                content: Text(
                                    "Bluetooth is not currently turned on, please check"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("close"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
          ),
        ),
        body: ListView.builder(
          itemCount: _scanResultList.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(_scanResultList[i].id),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ControlPage(
                        scanResult: _scanResultList[i],
                      ),
                    ),
                  );
                },
                child: const Text('control'),
              ),
            );
          },
        ),
      ),
    );
  }
}
