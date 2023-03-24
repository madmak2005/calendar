import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wypoczynkowa_osada/firebase_options.dart';
import 'package:wypoczynkowa_osada/pages/home.page.dart';
import 'package:wypoczynkowa_osada/providers/auth_provider.dart';
import 'package:wypoczynkowa_osada/providers/booking_provider.dart';
import 'package:wypoczynkowa_osada/services/BookingService.dart';

late BookingProvider bookingProvider;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DevHttpOverrides();

  //await Firebase.initializeApp();
  const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDGlo1B6SNx_rAMEBrOF13DlGxAtZGMBKc",
      authDomain: "wypoczynkowa-osada.firebaseapp.com",
      projectId: "wypoczynkowa-osada",
      storageBucket: "wypoczynkowa-osada.appspot.com",
      messagingSenderId: "885817675623",
      appId: "1:885817675623:web:812f5638a13cc82b1829c2",
      measurementId: "G-ELZNW7FT4Z");
  if (kIsWeb)
    await Firebase.initializeApp(
      options: web,
    );
  else
    await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  Wakelock.enable();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  bookingProvider = BookingProvider(
      firebaseFirestore: firebaseFirestore,
      prefs: prefs,
      firebaseStorage: firebaseStorage);

  runApp(MyApp(
    prefs: prefs,
    firebaseFirestore: firebaseFirestore,
    firebaseStorage: firebaseStorage,
  ));
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  MyApp(
      {Key? key,
      required this.prefs,
      required this.firebaseFirestore,
      required this.firebaseStorage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
              googleSignIn: GoogleSignIn(
                  clientId:
                      '885817675623-rj3jodj3do4bpgeaemgqhcmm9um8m9mh.apps.googleusercontent.com'),
              prefs: prefs,
              firebaseFirestore: firebaseFirestore,
            ),
          ),
          Provider<BookingProvider>(
            create: (_) => BookingProvider(
              prefs: prefs,
              firebaseFirestore: firebaseFirestore,
              firebaseStorage: firebaseStorage,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Wypoczynkowa Osada',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          locale: const Locale('pl', 'PL'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          home: const HomePage(),
          scrollBehavior: MyCustomScrollBehavior(),
        ));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
