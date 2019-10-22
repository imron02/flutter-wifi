import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:adawifi/list.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Connectivity _connectivity = new Connectivity();
  bool isWifiEnable = false;
  var listener;

  void initState() {
    super.initState();
    isWifiEnabled();
    listener = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi &&
          await WiFiForIoTPlugin.isEnabled() == true) {
        setState(() {
          isWifiEnable = true;
        });
      } else {
        setState(() {
          isWifiEnable = false;
        });
      }
    });
  }

  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void handleChangeWifi(bool value) async {
    await WiFiForIoTPlugin.setEnabled(value);
    setState(() {
      isWifiEnable = value;
    });
  }

  Future<bool> isWifiEnabled() async {
    bool isEnable = await WiFiForIoTPlugin.isEnabled();
    String ssid = await WiFiForIoTPlugin.getSSID();
    if (isEnable) {
      if (ssid != null) {
        print('Masuk sini');
        handleConnect();
      }
      setState(() {
        isWifiEnable = true;
      });
    }
    return isEnable;
  }

  Future<bool> isConnected() async {
    bool isEnabled = false;

    try {
      isEnabled = await WiFiForIoTPlugin.isEnabled();
    } on PlatformException {
      isEnabled = false;
    }

    if (!mounted) return true;

    return isEnabled;
  }

  handleNavigate() {
    Navigator.pushNamed(context, '/detail');
  }

  handleConnect() async {
    try {
      var deviceId = await DeviceId.getID;
      var urlGetUsername =
          DotEnv().env['BASE_URL'] + "check-auth?deviceId=$deviceId";
      var account = await http.get(urlGetUsername);
      Future.delayed(const Duration(seconds: 3), () async {
        try {
          String url = "http://192.168.88.1/login?";
          String username = json.decode(account.body)['email'];
          String password = json.decode(account.body)['password'];
          var response = await http.post(url,
              body: {'username': '$username', 'password': '$password'});
          if (response.statusCode == 200) {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text('Connected')));
          } else {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text('Connection failed')));
            throw ("cannot access internet");
          }
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Switch(
            value: isWifiEnable,
            onChanged: (value) {
              handleChangeWifi(!isWifiEnable);
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Show Snackbar',
            onPressed: handleNavigate,
          ),
        ],
      ),
      body: isWifiEnable
          ? Container(
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
            )
          : Center(
              child: GestureDetector(
                onTap: () => handleChangeWifi(true),
                child: Text("Turn on Wifi"),
              ),
            ),
    );
  }
}
