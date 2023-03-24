import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wypoczynkowa_osada/main.dart';
import 'package:wypoczynkowa_osada/models/Rez.dart';

class FirebaseStreams {
  static Stream<QuerySnapshot<Map<String, dynamic>>> records(int year) {
    return bookingProvider
        .getBookingsCollection(year)
        .asStream()
        .asBroadcastStream();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> queryByYear(
      int year) async {
    return await bookingProvider.getBookingsCollection(year);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> khtStream() {
    return bookingProvider.getKhtCollection().asStream().asBroadcastStream();
  }

  static Stream<QuerySnapshot<Object?>> recordsStream(int year) {
    return bookingProvider.getBookingsStreamCollection(year);
  }

  static updateBookin(Rez booking) {
    bookingProvider.updateBookingFirestore(booking.id, booking.toJson());
  }

  static insertBooking(Rez booking) {
    bookingProvider.insertBooking(booking);
  }

  static deleteBooking(Rez booking) {
    bookingProvider.deleteBookingFirestore(booking.id);
  }
}
