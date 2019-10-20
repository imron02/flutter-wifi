import 'package:flutter/material.dart';

class Auth extends StatelessWidget {
  static Material signinButton(String image) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () => {},
        child: Container(
          child: Image.asset(
            image,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 1,
              )),
          padding: EdgeInsets.all(15),
        ),
      ),
    );
  }

  final Widget header = Column(
    children: <Widget>[
      Image.asset(
        'images/logo.png',
        width: 170,
        height: 90,
        fit: BoxFit.contain,
      ),
      Text('Ada WiFi Di Sini'),
    ],
  );

  final Widget body = Container(
    width: 220,
    child: Column(
      children: <Widget>[
        Text(
          'Choose your social media account to login',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            signinButton('images/google.png'),
            SizedBox(width: 20),
            signinButton('images/facebook.png'),
          ],
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                header,
                body,
                RichText(
                    text: TextSpan(
                        text: 'Read our ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(color: Colors.red))
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
