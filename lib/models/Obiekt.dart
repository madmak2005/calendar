import 'package:cloud_firestore/cloud_firestore.dart';

class Obiekt {
  String id;
  int obiektId;
  String typ;
  String nazwa;
  int nr;

  Obiekt(
      {required this.id,
      required this.obiektId,
      required this.typ,
      required this.nazwa,
      required this.nr});

  factory Obiekt.fromDocument(DocumentSnapshot doc) {
    int obiektId = -1;
    String typ = '';
    String nazwa = '';
    int nr = -1;
    obiektId = doc.get('obiektId');
    typ = doc.get('typ');
    nazwa = doc.get('nazwa');
    nr = doc.get('nr');

    return Obiekt(
        id: doc.id, obiektId: obiektId, typ: typ, nazwa: nazwa, nr: nr);
  }
  factory Obiekt.fromJson(Map<String, dynamic> json) {
    String id = '';
    int obiektId = -1;
    String typ = '';
    String nazwa = '';
    int nr = -1;

    obiektId = json['obiektId'] == null ? '' : obiektId = json['obiektId'];
    obiektId = json['obiektId'];
    typ = json['typ'];
    nazwa = json['nazwa'];
    nr = json['nr'];

    return Obiekt(id: id, obiektId: obiektId, typ: typ, nazwa: nazwa, nr: nr);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['obiektId'] = obiektId;
    data['typ'] = typ;
    data['nazwa'] = nazwa;
    data['nr'] = nr;
    return data;
  }
}
