import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'Kht.dart';
import 'Obiekt.dart';

class Rez {
  String id;
  int rezId;
  Timestamp dataPrzyjazdu;
  Timestamp dataWyjazdu;
  Kht kht;
  double klimatyczne;
  double zadatek;
  double paragon;
  double razem;
  int iloscDoroslych;
  int iloscDzieci;
  String uwagi;
  Timestamp czasUtworzenia;
  Timestamp czasAktualizacji;
  Obiekt obiekt;

  Rez(
      {required this.id,
      required this.rezId,
      required this.dataPrzyjazdu,
      required this.dataWyjazdu,
      required this.kht,
      required this.klimatyczne,
      required this.zadatek,
      required this.paragon,
      required this.razem,
      required this.iloscDoroslych,
      required this.iloscDzieci,
      required this.uwagi,
      required this.czasUtworzenia,
      required this.czasAktualizacji,
      required this.obiekt});

  factory Rez.empty() {
    Kht kht = Kht(
        id: 'auto',
        khtId: -1,
        nazwa: '',
        imie: '',
        ulicaNr: '',
        kodPocztowy: '',
        miasto: '',
        nip: '',
        telefon: '',
        email: '',
        szukacz: '',
        czasUtworzenia: Timestamp.now().toString(),
        czasAktualizacji: Timestamp.now().toString());

    Obiekt obiekt = Obiekt(id: '', obiektId: -1, typ: '', nazwa: '', nr: -1);

    Rez newRez = Rez(
        id: 'auto',
        rezId: -1,
        dataPrzyjazdu: Timestamp.fromDate(DateTime.now()),
        dataWyjazdu: Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        kht: kht,
        klimatyczne: 0,
        zadatek: 0,
        paragon: 0,
        razem: 0,
        iloscDoroslych: 0,
        iloscDzieci: 0,
        uwagi: '',
        czasUtworzenia: Timestamp.now(),
        czasAktualizacji: Timestamp.now(),
        obiekt: obiekt);

    return newRez;
  }

  factory Rez.emptyFromOld(Rez oldRez) {
    Kht kht = Kht(
        id: 'auto',
        khtId: -1,
        nazwa: '',
        imie: '',
        ulicaNr: '',
        kodPocztowy: '',
        miasto: '',
        nip: '',
        telefon: '',
        email: '',
        szukacz: '',
        czasUtworzenia: Timestamp.now().toString(),
        czasAktualizacji: Timestamp.now().toString());

    Rez newRez = Rez(
        id: 'auto',
        rezId: -1,
        dataPrzyjazdu: oldRez.dataPrzyjazdu,
        dataWyjazdu: oldRez.dataWyjazdu,
        kht: kht,
        klimatyczne: 0,
        zadatek: 0,
        paragon: 0,
        razem: 0,
        iloscDoroslych: 0,
        iloscDzieci: 0,
        uwagi: '',
        czasUtworzenia: Timestamp.now(),
        czasAktualizacji: Timestamp.now(),
        obiekt: oldRez.obiekt);

    return newRez;
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }

  factory Rez.fromDocument(DocumentSnapshot doc) {
    int rezId;
    Timestamp dataPrzyjazdu;
    Timestamp dataWyjazdu;
    Kht kht;
    double klimatyczne;
    double zadatek;
    double paragon;
    double razem;
    int iloscDoroslych;
    int iloscDzieci;
    String uwagi;
    Timestamp czasUtworzenia;
    Timestamp czasAktualizacji;
    Obiekt obiekt;

    rezId = doc.get('rezId');
    dataPrzyjazdu = doc.get('dataPrzyjazdu');
    dataWyjazdu = doc.get('dataWyjazdu');
    kht = Kht.fromJson(doc.get('kht'));
    klimatyczne = checkDouble(doc.get('klimatyczne'));
    zadatek = checkDouble(doc.get('zadatek'));
    paragon = checkDouble(doc.get('paragon'));
    razem = checkDouble(doc.get('razem'));
    iloscDoroslych = doc.get('iloscDoroslych');
    iloscDzieci = doc.get('iloscDzieci');
    uwagi = doc.get('uwagi');
    czasUtworzenia = doc.get('czasUtworzenia');
    czasAktualizacji = doc.get('czasAktualizacji');
    obiekt = Obiekt.fromJson(doc.get('obiekt'));

    return Rez(
        id: doc.id,
        rezId: rezId,
        dataPrzyjazdu: dataPrzyjazdu,
        dataWyjazdu: dataWyjazdu,
        kht: kht,
        klimatyczne: klimatyczne,
        zadatek: zadatek,
        paragon: paragon,
        razem: razem,
        iloscDoroslych: iloscDoroslych,
        iloscDzieci: iloscDzieci,
        uwagi: uwagi,
        czasUtworzenia: czasUtworzenia,
        czasAktualizacji: czasAktualizacji,
        obiekt: obiekt);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['rezId'] = rezId;
    data['dataPrzyjazdu'] = dataPrzyjazdu;
    data['dataWyjazdu'] = dataWyjazdu;
    data['kht'] = kht.toJson();
    data['klimatyczne'] = klimatyczne;
    data['zadatek'] = zadatek;
    data['paragon'] = paragon;
    data['razem'] = razem;
    data['iloscDoroslych'] = iloscDoroslych;
    data['iloscDzieci'] = iloscDzieci;
    data['uwagi'] = uwagi;
    data['czasUtworzenia'] = czasUtworzenia;
    data['czasAktualizacji'] = czasAktualizacji;
    data['obiekt'] = obiekt.toJson();

    return data;
  }

  factory Rez.fromJson(Map<String, dynamic> json) {
    String id;
    int rezId;
    String dataPrzyjazdu;
    String dataWyjazdu;
    Kht kht;
    double klimatyczne;
    double zadatek;
    double paragon;
    double razem;
    int iloscDoroslych;
    int iloscDzieci;
    String uwagi;
    String czasUtworzenia;
    String czasAktualizacji;
    Obiekt obiekt;

    id = json['id'] ?? '';
    rezId = json['rezId'] ?? -1;
    dataPrzyjazdu = json['dataPrzyjazdu'] ?? '';
    dataWyjazdu = json['dataWyjazdu'] ?? '';
    kht = Kht.fromJson(json['kht']);
    klimatyczne = json['klimatyczne'] ?? 0.0;
    zadatek = json['zadatek'] ?? 0.0;
    paragon = json['paragon'] ?? 0.0;
    razem = json['razem'] ?? 0.0;
    iloscDoroslych = json['iloscDoroslych'] ?? 0;
    iloscDzieci = json['iloscDzieci'] ?? 0;
    uwagi = json['uwagi'] ?? '';
    czasUtworzenia = json['czasUtworzenia'] ?? '';
    czasAktualizacji = json['czasAktualizacji'] ?? '';
    obiekt = Obiekt.fromJson(json['obiekt']);
    return Rez(
        id: id,
        rezId: rezId,
        dataPrzyjazdu: Timestamp.fromDate(DateTime.parse(dataPrzyjazdu)),
        dataWyjazdu: Timestamp.fromDate(DateTime.parse(dataWyjazdu)),
        kht: kht,
        klimatyczne: klimatyczne,
        zadatek: zadatek,
        paragon: paragon,
        razem: razem,
        iloscDoroslych: iloscDoroslych,
        iloscDzieci: iloscDzieci,
        uwagi: uwagi,
        czasUtworzenia: Timestamp.fromDate(DateTime.parse(czasUtworzenia)),
        czasAktualizacji: Timestamp.fromDate(DateTime.parse(czasAktualizacji)),
        obiekt: obiekt);
  }
}
