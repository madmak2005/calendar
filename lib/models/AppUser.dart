import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wypoczynkowa_osada/constants/firestore_constants.dart';

class AppUser {
  String id;
  String photoUrl;
  String nickname;
  String role;

  AppUser(
      {required this.id,
      required this.photoUrl,
      required this.nickname,
      required this.role});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.role: role,
      FirestoreConstants.photoUrl: photoUrl,
    };
  }

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    String role = "";
    String photoUrl = "";
    String nickname = "";
    try {
      role = doc.get(FirestoreConstants.role);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    return AppUser(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      role: role,
    );
  }
}
