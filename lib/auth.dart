import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class SignIn extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkLocationPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    if (permission != PermissionStatus.granted) {
      requestLocationPermission();
      return true;
    }

    return false;
  }

  Future<bool> requestLocationPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);

    return permissions[PermissionGroup.location] == PermissionStatus.granted;
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      final String deviceId = await DeviceId.getID;
      bool isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final IdTokenResult idTokenResult = await user.getIdToken(refresh: true);
      String idToken = idTokenResult.token;
      var url = DotEnv().env['BASE_URL'] + "verify-token?idToken=$idToken";
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var url1 = DotEnv().env['BASE_URL'] + "check-auth?deviceId=$deviceId";
        var response1 = await http.get(url1);

        if (response1.statusCode == 200) {
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          var email = googleUser.email;
          var name = googleUser.displayName;
          var url2 = DotEnv().env['BASE_URL'] +
              "create-user?email=$email&name=$name&deviceId=$deviceId";
          var response2 = await http.get(url2);

          if (response2.statusCode == 200) {
            Navigator.pushReplacementNamed(context, "/home");
          } else {
            throw ("error when created user");
          }
        }
      } else {
        throw ("token is invalid");
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

  Widget build(BuildContext context) {
    checkLocationPermission();

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
                    ],
                  ),
                ),
              ],
            ),
          )),
    ));
  }
}
