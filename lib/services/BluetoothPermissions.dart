import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissions {
  Future<void> initBluetooth() async {
    //initialization of the app
    await requestPermissions();
    await enableBluetooth();
    // inside mapscreen
  }

  Future<void> requestPermissions() async {
    // Request Bluetooth permission

    var status = await Permission.bluetooth.request();
    if (status != PermissionStatus.granted) {
      // Handle the case where Bluetooth permission is not granted
      print('Bluetooth permission not granted');
      return;
    } else
      print('Bluetooth permission is granted');

    // Request location permissions (for Bluetooth LE scanning)
    status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // Handle the case where location permission is not granted
      print('Location permission not granted');
      return;
    } else
      print('Location permission is granted');
  }

  Future<void> enableBluetooth() async {
    //check if BT is supported
    if (await FlutterBluePlus.isSupported == true) {
      print("Bluetooth is supported");

      //check if BT is on
      var subscription =
          FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        print("before print state");
        print("state is " + state.toString());
        if (state == BluetoothAdapterState.on) {
          print("bluetooth is on");
        } else {
          print("bluetooth is off");
        }
      });

      // turn on bluetooth ourself if we can
      // for iOS, the user controls bluetooth enable/disable
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

      // cancel to prevent duplicate listeners
      subscription.cancel();
    } else
      print("Bluetooth is not supported");
  }
}
