import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wypoczynkowa_osada/models/Rez.dart';
import 'package:wypoczynkowa_osada/providers/booking_provider.dart';
import 'package:wypoczynkowa_osada/providers/providers.dart';
import 'package:wypoczynkowa_osada/services/BookingService.dart';
import 'package:wypoczynkowa_osada/widgets/cards/calendarCard.dart';
import 'package:wypoczynkowa_osada/widgets/cards/chatGPT4.dart';
import 'package:wypoczynkowa_osada/widgets/google_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isAuth = false;

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

  printJWT(String jwt, BookingProvider bookingProvider) {
    if (kDebugMode) {
      print('Then jwt:' + jwt);
    }

    insertBookings(List<Rez> bookings) {
      if (kDebugMode) {
        print('Bookings:' + bookings.length.toString());
      }

      for (var booking in bookings) {
        if (kDebugMode) {
          print(booking.kht.nazwa);
          bookingProvider.insertBooking(booking);
        }
      }
    }

    if (jwt.isNotEmpty) {
      BookingService.fromBase64(
              'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhbmlhbWFrb3dza2FAZ21haWwuY29tIiwiZXhwIjoxNjQzMDY2Nzc5LCJpYXQiOjE2NDMwNDg3Nzl9.B12O5s22WuIOtMXgpBLnZS9nANWMg6xE_vXoQcrJOzMDp2-_jt6qXkkKhiBMpS3lt5mjxWQJjIeKARBo9MD_fw')
          .getBookingsBetween()
          .then((bookings) => insertBookings(bookings));
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    BookingProvider bookingProvider = Provider.of<BookingProvider>(context);
    //Auth.attemptLogIn('aniamakowska@gmail.com', 'tomeczek')
    //    .then((jwt) => printJWT(jwt, bookingProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wypoczynkowa Osada'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Wylogowuję')));
              authProvider.handleSignOut();
            },
          ),
        ],
      ),
      body: Container(
        child: isAuth
            ? Column(
                children: const [
                  CalendarCard(),
                  ChatGPT4Card(),
                ],
              )
            : const AuthButton(),
      ),
    );
  }
}
