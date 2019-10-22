import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class WifiList extends StatefulWidget {
  @override
  _WifiListState createState() => _WifiListState();
}

class _WifiListState extends State<WifiList> {
  List<ListTile> _wifiList = new List();
  TextEditingController _passwordCtrl = TextEditingController();
  String username;
  String password;

  @override
  initState() {
    super.initState();
    getWifiList();
  }

  Future<void> confirmDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Input password'),
            content: SingleChildScrollView(
              child: TextField(
                controller: _passwordCtrl,
                decoration: InputDecoration(hintText: 'Masukkan password'),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
  Future<Null> getWifiList() async {
    List<WifiNetwork> networks;
    List<ListTile> wifiList = new List();
    String ssid = await WiFiForIoTPlugin.getSSID();
    bool connected;
    try {
      networks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      networks = new List<WifiNetwork>();
    }
    if (networks != null && networks.length > 0) {
      networks.forEach((network) {
        PopupCommand oCmdConnect = new PopupCommand("Connect", network.ssid);
        PopupCommand oCmdRemove = new PopupCommand("Remove", network.ssid);
        List<PopupMenuItem<PopupCommand>> popupMenuItems = new List();
        popupMenuItems.add(
          new PopupMenuItem<PopupCommand>(
            value: oCmdConnect,
            child: const Text('Connect'),
          ),
        );

        popupMenuItems.add(
          new PopupMenuItem<PopupCommand>(
            value: oCmdRemove,
            child: const Text('Disconnect'),
          ),
        );
        connected = ssid == network.ssid;
        wifiList.add(ListTile(
          title: Text(network.ssid),
          trailing: FlatButton(
            onPressed: () async {
              if (connected) {
                setState(() {
                  connected = false;
                });
                return handleDisconnect(network);
              }
              setState(() {
                  connected = true;
              });
              return handleConnect(network);
            },
            child: connected ? Text("disconnect") : Text("connect", style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
        ));
      });
    }

    setState(() {
      _wifiList = wifiList;
    });
  }

  handleConnect(network) async {
    // await confirmDialog();
    // var bssid = network.bssid;
    try {
      var deviceId = await DeviceId.getID;
      var response = await WiFiForIoTPlugin.connect(
          network.ssid,
          joinOnce: true
      );
      if (response == true) {
        var urlGetUsername = DotEnv().env['BASE_URL'] + "check-auth?deviceId=$deviceId";
        var account = await http.get(urlGetUsername);

        Future.delayed(const Duration(seconds: 3), () async {
          try {
            String url = "http://192.168.88.1/login?";
            String username = json.decode(account.body)['email'];
            String password = json.decode(account.body)['password'];
            var response2 = await http.post(url, body: {
              'username': '$username',
              'password': '$password'
            });
            if (response2.statusCode == 200) {
              Scaffold
                .of(context)
                .showSnackBar(SnackBar(content: Text('Connected')));
            } else {
              throw("cannot access internet");
            }
          } catch (e) {
            print(e);
          }
        });

      } else {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Connection failed')));
        throw("cannot connect to this network");
      }

      _passwordCtrl.text = '';
    } catch (e) {
      print(e);
    }
  }

  handleDisconnect(network) async {
    WiFiForIoTPlugin.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getWifiList,
      child: ListView(
        children: _wifiList,
      ),
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument) {
    ///
  }
}
