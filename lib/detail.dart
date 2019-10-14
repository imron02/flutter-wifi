import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List<ListTile> _wifiClients;

  @override
  void initState() {
    super.initState();
    getClientList();
  }

  getClientList() async {
    List<APClient> wifiClients;
    List<ListTile> clientInfo = new List();
    String ssid = "";

    try {
      wifiClients = await WiFiForIoTPlugin.getClientList(false, 300);
      ssid = await WiFiForIoTPlugin.getSSID();
    } catch (e) {
      // Error
      wifiClients = new List<APClient>();
    }

    if (ssid != "") {
      clientInfo.add(ListTile(
        title: Text("SSID"),
        subtitle: Text(ssid),
        dense: true,
      ));
    }

    if (wifiClients != null && wifiClients.length > 0) {
      wifiClients.forEach((client) {
        clientInfo.add(ListTile(
          title: Text("Ip Address"),
          subtitle: Text(client.ipAddr),
          dense: true,
        ));
        clientInfo.add(ListTile(
          title: Text("Hardware Address"),
          subtitle: Text(client.hwAddr),
        ));
      });
    }

    setState(() {
      _wifiClients = clientInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Wifi'),
      ),
      body: Container(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: _wifiClients,
        ),
      ),
    );
  }
}
