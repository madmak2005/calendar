import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Kht {
  String id;
  int khtId;
  String nazwa;
  String imie;
  String ulicaNr;
  String kodPocztowy;
  String miasto;
  String nip;
  String telefon;
  String email;
  String szukacz;
  String czasUtworzenia;
  String czasAktualizacji;

  Kht(
      {required this.id,
      required this.khtId,
      required this.nazwa,
      required this.imie,
      required this.ulicaNr,
      required this.kodPocztowy,
      required this.miasto,
      required this.nip,
      required this.telefon,
      required this.email,
      required this.szukacz,
      required this.czasUtworzenia,
      required this.czasAktualizacji});

  factory Kht.fromDocument(DocumentSnapshot doc) {
    int khtId = -1;
    String nazwa = '';
    String imie = '';
    String ulicaNr = '';
    String kodPocztowy = '';
    String miasto = '';
    String nip = '';
    String telefon = '';
    String email = '';
    String szukacz = '';
    String czasUtworzenia = '';
    String czasAktualizacji = '';

    try {
      khtId = doc.get('khtId');
    } catch (e) {
      if (kDebugMode) print(e);
    }
    try {
      nazwa = doc.get('nazwa');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      imie = doc.get('imie');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      ulicaNr = doc.get('ulicaNr');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      kodPocztowy = doc.get('kodPocztowy');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      miasto = doc.get('miasto');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      nip = doc.get('nip');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      telefon = doc.get('telefon');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      email = doc.get('email');
    } catch (e) {
      if (kDebugMode) print(e);
    }
    try {
      szukacz = doc.get('szukacz');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      czasUtworzenia = doc.get('czasUtworzenia');
    } catch (e) {
      if (kDebugMode) print(e);
    }

    try {
      czasAktualizacji = doc.get('czasAktualizacji');
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return Kht(
        id: doc.id,
        khtId: khtId,
        nazwa: nazwa,
        imie: imie,
        ulicaNr: ulicaNr,
        kodPocztowy: kodPocztowy,
        miasto: miasto,
        nip: nip,
        telefon: telefon,
        email: email,
        szukacz: szukacz,
        czasUtworzenia: czasUtworzenia,
        czasAktualizacji: czasAktualizacji);
  }

  factory Kht.fromJson(Map<String, dynamic> json) {
    String id = '';
    int khtId = -1;
    String nazwa = '';
    String imie = '';
    String ulicaNr = '';
    String kodPocztowy = '';
    String miasto = '';
    String nip = '';
    String telefon = '';
    String email = '';
    String szukacz = '';
    String czasUtworzenia = '';
    String czasAktualizacji = '';

    khtId = json['khtId'] ?? -1;
    nazwa = json['nazwa'] ?? '';
    imie = json['imie'] ?? "";
    ulicaNr = json['ulica_nr'] ?? '';
    kodPocztowy = json['kod_pocztowy'] ?? '';
    miasto = json['miasto'] ?? '';
    nip = json['nip'] ?? '';
    telefon = json['telefon'] ?? '';
    email = json['email'] ?? '';
    szukacz = json['szukacz'] ?? '';
    czasUtworzenia = json['czasUtworzenia'] ?? '';
    czasAktualizacji = json['czasAktualizacji'] ?? '';

    return Kht(
        id: id,
        khtId: khtId,
        nazwa: nazwa,
        imie: imie,
        ulicaNr: ulicaNr,
        kodPocztowy: kodPocztowy,
        miasto: miasto,
        nip: nip,
        telefon: telefon,
        email: email,
        szukacz: szukacz,
        czasUtworzenia: czasUtworzenia,
        czasAktualizacji: czasAktualizacji);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'khtId': khtId,
      'nazwa': nazwa,
      'imie': imie,
      'ulicaNr': ulicaNr,
      'kodPocztowy': kodPocztowy,
      'miasto': miasto,
      'nip': nip,
      'telefon': telefon,
      'email': email,
      'szukacz': szukacz,
      'czasUtworzenia': czasUtworzenia,
      'czasAktualizacji': czasAktualizacji
    };
  }
}
