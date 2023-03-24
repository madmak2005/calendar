import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wypoczynkowa_osada/constants/constants.dart';
import 'package:wypoczynkowa_osada/models/Rez.dart';

class BookingProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  BookingProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> updateBookingFirestore(
      String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection('bookings')
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Future<void> deleteBookingFirestore(String docPath) {
    return firebaseFirestore.collection('bookings').doc(docPath).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getBookingsCollection(int year) {
    /*
    return firebaseFirestore
        .collection('bookings')
        .orderBy('dataPrzyjazdu', descending: true)
        .get();
    */
    return firebaseFirestore
        .collection('bookings')
        .where('dataPrzyjazdu',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(year, DateTime.january, 1)))
        .where('dataPrzyjazdu',
            isLessThan:
                Timestamp.fromDate(DateTime(year + 1, DateTime.january, 1)))
        .orderBy('dataPrzyjazdu', descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getKhtCollection() {
    return firebaseFirestore.collection('bookings.kht').get();
  }

  Stream<QuerySnapshot> getBookingsStreamCollection(int year) {
    return firebaseFirestore
        .collection('bookings')
        .where('dataPrzyjazdu',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(year, DateTime.january, 1)))
        .where('dataPrzyjazdu',
            isLessThan:
                Timestamp.fromDate(DateTime(year + 1, DateTime.january, 1)))
        .orderBy('dataPrzyjazdu', descending: true)
        .snapshots();
  }

  void insertBooking(Rez rez) {
    DocumentReference documentReference = firebaseFirestore
        .collection('bookings')
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        rez.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
