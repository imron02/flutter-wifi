import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  void _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      if (user.getIdToken() != null) {
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      print(e);
    }
  }

  Material _signinButton(BuildContext context, String image) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: () => _signInWithGoogle(context),
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

  Container _body(BuildContext context) {
    return Container(
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
              _signinButton(context, 'images/google.png'),
              SizedBox(width: 20),
              _signinButton(context, 'images/facebook.png'),
            ],
          )
        ],
      ),
    );
  }

  final Widget _header = Column(
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
                _header,
                _body(context),
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
