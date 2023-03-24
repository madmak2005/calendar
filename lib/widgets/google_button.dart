import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:wypoczynkowa_osada/providers/providers.dart';

import 'loading_view.dart';

class AuthButton extends StatefulWidget {
  const AuthButton({Key? key}) : super(key: key);

  @override
  AuthButtonState createState() => AuthButtonState();
}

class AuthButtonState extends State<AuthButton> {
  bool isAuth = false;

  @override
  initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
        setState(() {
          isAuth = false;
        });
      } else {
        if (kDebugMode) {
          print('User is signed in!');
        }
        setState(() {
          isAuth = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return isAuth
        ? Stack(
            children: <Widget>[
              Center(
                child: TextButton(
                  onPressed: () async {
                    await authProvider.handleSignOut();
                  },
                  child: const Text(
                    'Sign out from Google',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.green.withOpacity(0.8);
                        }
                        return Colors.green;
                      },
                    ),
                    splashFactory: NoSplash.splashFactory,
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(30, 15, 30, 15),
                    ),
                  ),
                ),
              ),
              // Loading
              Positioned(
                child: authProvider.status == Status.authenticating
                    ? LoadingView()
                    : const SizedBox.shrink(),
              ),
            ],
          )
        : Stack(
            children: <Widget>[
              Center(
                child: TextButton(
                  onPressed: () async {
                    bool isSuccess = await authProvider.handleSignIn();
                    if (isSuccess) {
                      /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(context),
                  ),
                );
                */
                    }
                  },
                  child: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return const Color(0xffdd4b39).withOpacity(0.8);
                        }
                        return const Color(0xffdd4b39);
                      },
                    ),
                    splashFactory: NoSplash.splashFactory,
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(30, 15, 30, 15),
                    ),
                  ),
                ),
              ),
              // Loading
              Positioned(
                child: authProvider.status == Status.authenticating
                    ? LoadingView()
                    : const SizedBox.shrink(),
              ),
            ],
          );
  }
}
