import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

class ControlPage extends StatefulWidget {
  final ScanResult scanResult;
  const ControlPage({Key? key, required this.scanResult}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late Device device;
  bool connected = false;
  late Stream<DeviceState> deviceStateStream;
  @override
  void initState() {
    device = widget.scanResult.connect(connectTimeout: 20000);
    device.readData('6e400001-b5a3-f393-e0a9-e50e24dcca9e',
        '6e400003-b5a3-f393-e0a9-e50e24dcca9e');
    device.deviceSignalResultStream.listen((event) {
      print('data ' + event.data.toString());
    });

    deviceStateStream = device.stateStream;
    super.initState();
  }

  @override
  void dispose() {
    if (device.state == DeviceState.connected) {
      device.disConnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<DeviceState>(
          stream: deviceStateStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.data == DeviceState.connected) {
                return Center(
                  child: Column(
                    children: [
                      Text(widget.scanResult.id),
                      ElevatedButton(
                        onPressed: () {
                          int unixTime =
                              DateTime.now().millisecondsSinceEpoch ~/ 1000;
                          List<int> buffer = [0x00, 0x00, 0x05] +
                              Uint8List.fromList([
                                unixTime >> 24,
                                unixTime >> 16,
                                unixTime >> 8,
                                unixTime
                              ]) +
                              [0x01] +
                              [0, 0, 0, 0];
                          device.writeData(
                            '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
                            '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
                            true,
                            Uint8List.fromList(buffer),
                          );
                        },
                        child: const Text('unlock'),
                      )
                    ],
                  ),
                );
              } else if (snapshot.data == DeviceState.connecting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == DeviceState.disconnected) {
                return Center(
                  child: Column(
                    children: [
                      Text(widget.scanResult.id),
                      ElevatedButton(
                        onPressed: () {
                          device =
                              widget.scanResult.connect(connectTimeout: 20000);
                          setState(() {
                            deviceStateStream = device.stateStream;
                          });
                        },
                        child: const Text('connect'),
                      )
                    ],
                  ),
                );
              }
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
