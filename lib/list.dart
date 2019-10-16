import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

class WifiList extends StatefulWidget {
  @override
  _WifiListState createState() => _WifiListState();
}

class _WifiListState extends State<WifiList> {
  List<ListTile> _wifiList = new List();
  TextEditingController _passwordCtrl = TextEditingController();

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

  handleConnect(network) async {
    await confirmDialog();

    try {
      var response = await WiFiForIoTPlugin.connect(network.ssid,
          password: _passwordCtrl.text,
          joinOnce: true,
          security: STA_DEFAULT_SECURITY);

      if (response == true) {
        Future.delayed(const Duration(seconds: 1));
        String url = 'http://meteor-inovasi-digital.id/login?';
        var response = await http.post(url, body: {
          'username': 'imron',
          'password': 'imron',
          'dst': 'http://meteor-inovasi-digital.id/login?'
        });

        if (response.statusCode == 200) {
          Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Connected')));
        }
      } else {
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text('Connection failed')));
      }

      _passwordCtrl.text = '';
    } catch (e) {
      // Error
    }
  }

  Future<Null> getWifiList() async {
    List<WifiNetwork> networks;
    List<ListTile> wifiList = new List();

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

        wifiList.add(ListTile(
          title: Text(network.ssid),
          trailing: PopupMenuButton<PopupCommand>(
            padding: EdgeInsets.zero,
            onSelected: (PopupCommand pocommand) {
              switch (pocommand.command) {
                case "Connect":
                  handleConnect(network);
                  break;
                case "Remove":
                  WiFiForIoTPlugin.removeWifiNetwork(pocommand.argument);
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => popupMenuItems,
          ),
        ));
      });
    }

    setState(() {
      _wifiList = wifiList;
    });
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
