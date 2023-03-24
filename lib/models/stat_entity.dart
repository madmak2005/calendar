import 'package:cloud_firestore/cloud_firestore.dart';

class StatEntity {
  String id;
  int rok;
  int miesiac;
  double razem;

  StatEntity(
      {required this.id,
      required this.rok,
      required this.miesiac,
      required this.razem});

  factory StatEntity.fromDocument(DocumentSnapshot doc) {
    String id;
    int rok;
    int miesiac;
    double razem;
    id = doc.id;
    rok = doc.get('rok');
    miesiac = doc.get('miesiac');
    razem = doc.get('razem');

    return StatEntity(id: id, rok: rok, miesiac: miesiac, razem: razem);
  }
}
