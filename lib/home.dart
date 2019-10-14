import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:adawifi/list.dart';

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> checkLocationPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    return permission == PermissionStatus.granted;
  }

  Future<bool> requestLocationPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);

    return permissions[PermissionGroup.location] == PermissionStatus.granted;
  }

  Future<bool> isConnected() async {
    bool isConnectedAndGranted;

    try {
      bool isConnected = await WiFiForIoTPlugin.isConnected();
      bool isGranted = await checkLocationPermission();
      if (isGranted == false) {
        await requestLocationPermission();
        isGranted = await checkLocationPermission();
      }

      if (isConnected == true && isGranted) {
        isConnectedAndGranted = true;
      }
    } on PlatformException {
      isConnectedAndGranted = false;
    }

    if (!mounted) return true;

    return isConnectedAndGranted;
  }

  handleNavigate() {
    Navigator.pushNamed(context, '/detail');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Show Snackbar',
            onPressed: handleNavigate,
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: isConnected(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return WifiList();
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
