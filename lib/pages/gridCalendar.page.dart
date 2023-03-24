import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:wypoczynkowa_osada/models/Kht.dart';
import 'package:wypoczynkowa_osada/models/Obiekt.dart';

import 'package:wypoczynkowa_osada/models/Rez.dart';
import 'package:wypoczynkowa_osada/pages/editBooking.dart';
import 'package:wypoczynkowa_osada/providers/booking_provider.dart';
import 'package:wypoczynkowa_osada/services/BookingService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:wypoczynkowa_osada/streams/firebaseStreams.dart';

var user = "";
const double boxSize = 50.0;
List<Rez> bookings = [];
var removedController = StreamController<Rez>();
var removedStream = removedController.stream.asBroadcastStream();

var reloadController = StreamController<bool>();
var reloadStream = reloadController.stream.asBroadcastStream();
var year = DateTime.now().year;

var yearController = StreamController<int>();
var yearStream = yearController.stream.asBroadcastStream();
late LinkedScrollControllerGroup _controllers;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late List<Rez> rezy;
  late ScrollController _oHeader;
  late ScrollController _o1;
  late ScrollController _o2;
  late ScrollController _o3;
  late ScrollController _o4;
  late ScrollController _o5;
  late ScrollController _o6;
  //late Future<QuerySnapshot<Map<String, dynamic>>> bookings;
  //late BookingProvider bookingProvider;

  var itemCount = 0;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> x;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> k;
  late StreamSubscription<QuerySnapshot<Object?>> y;
  late StreamSubscription<bool> a;
  static StreamController<Rez> bookingController =
      StreamController<Rez>.broadcast();
  static Stream<Rez> streamRez = bookingController.stream;

  Future<List<Rez>> oneTime(int y) async {
    List<Rez> resLista = [];
    var records = await FirebaseStreams.queryByYear(y);
    for (var record in records.docs) {
      Rez rx = Rez.fromDocument(record);
      log('-------> ' + rx.kht.nazwa);
      resLista.add(rx);
    }
    /*
    x = FirebaseStreams.records(year).asBroadcastStream().listen(
      (event) {
        
        log("oneTime()");
        var lista = event.docs;
        for (var element in lista) {
          print(element);
          Rez r = Rez.fromDocument(element);
          //if (!bookings.contains(r)) bookings.add(r);
          log(r.razem.toString());
          itemCount = bookings.length;
          bookings.add(r);
          bookingController.add(r);
          //setState(() {
          //  if (kDebugMode) {
          //    //print('setState()');
          //  }
          //});
          if (kDebugMode) {
            //print('records(): ' + r.kht.nazwa);
            //print('ID: ' + element.id);
          }
        }
        _controllers.jumpTo(0.0);
        _controllers.resetScroll();
        if (kDebugMode) {
          print('o1: ${_o1.position}');
          print('o2: ${_o2.position}');
          print('o3: ${_o3.position}');
          print('o4: ${_o4.position}');
          print('o5: ${_o5.position}');
          print('o6: ${_o6.position}');
        }
      },
      onDone: () => x.cancel(),
    );
    */
    return resLista;
  }

  void oneTimeKht() async {
    k = FirebaseStreams.khtStream().asBroadcastStream().listen(
      (event) {
        log("oneTimeKht()");
        var lista = event.docs;
        for (var element in lista) {
          Kht r = Kht.fromDocument(element);
          //if (!bookings.contains(r)) bookings.add(r);
          setState(() {
            if (kDebugMode) {
              //print('setState()');
            }
          });
          if (kDebugMode) {
            //print('records(): ' + r.kht.nazwa);
            //print('ID: ' + element.id);
          }
          log(r.nazwa);
        }

        if (kDebugMode) {}
      },
      onDone: () => k.cancel(),
    );
  }

  initStream() {
    yearStream.listen((event) async {
      bookings.clear();
      var xy = oneTime(event);
      xy.then((xx) => {
            setState(() {
              if (kDebugMode) {
                print('year $event');
              }
              bookings = xx;
              year = event;

              for (var element in xx) {
                bookingController.add(element);
              }
              //oneTimeKht();
            })
          });
    });

    removedStream.listen((event) {
      log('Skasowana ${event.id}');
      Stopwatch stopwatch = Stopwatch()..start();
      setState(() {
        bookings.remove(event);
      });
      log('removedStream.listen: ${stopwatch.elapsed}');
    });

    a = reloadStream.listen(
      (event) {
        if (event) {
          setState(() {
            //bookingController.add(Rez.empty());
            //bookings.clear();
            bookingController.add(Rez.empty());
          });
        }
      },
      onDone: () => a.cancel(),
    );
    /*
    x = FirebaseStreams.records().listen(
      (event) {
        var lista = event.docs;
        for (var element in lista) {
          Rez r = Rez.fromDocument(element);
          //if (!bookings.contains(r)) bookings.add(r);
          setState(() {
            if (kDebugMode) {
              print('setState()');
            }
            itemCount = bookings.length;
            bookings.add(r);
            bookingController.add(r);
          });
          if (kDebugMode) {
            print('records(): ' + r.kht.nazwa);
            print('ID: ' + element.id);
          }
        }
      },
      onDone: () => x.cancel(),
    );
    */
    y = FirebaseStreams.recordsStream(year).listen(
      (event) {
        var lista = event.docs;
        //setState(() {
        //bookingController.add(Rez.empty());
        //bookings.clear();
        //});

        if (kDebugMode) {
          print('Dlugość listy: ${lista.length}');
        }
        for (var element in lista) {
          Rez r = Rez.fromDocument(element);
          if (kDebugMode) {
            // print('adding xx: ${r.kht.nazwa}');
          }
          bookings.add(r);
          bookingController.add(r);
          //setState(() {
          //
          //});
        }
      },
      onDone: () => x.cancel(),
    );
  }

  _CalendarPageState() {
    initStream();
  }

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _oHeader = _controllers.addAndGet();
    _o1 = _controllers.addAndGet();
    _o2 = _controllers.addAndGet();
    _o3 = _controllers.addAndGet();
    _o4 = _controllers.addAndGet();
    _o5 = _controllers.addAndGet();
    _o6 = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _o1.dispose();
    _o2.dispose();
    _o3.dispose();
    _o4.dispose();
    _o5.dispose();
    _o6.dispose();
    _oHeader.dispose();
    //FirebaseStreams.initStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dateStart = DateTime(year, 1, 1);
    var addAutomaticKeepAlives = false;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Row(
          children: [
            Text(
              'Rok: $year',
              style: const TextStyle(color: Colors.amber),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                _showDialog(context);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<Rez>(
        stream: streamRez,
        builder: (
          BuildContext context,
          AsyncSnapshot<Rez> snapshot,
        ) {
          if (kDebugMode) {
            print('b ${snapshot.connectionState}');
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            for (var element in bookings) {
              if (kDebugMode) {
                // print('Przyjazd ${element.dataPrzyjazdu.toDate()} Wyjazd ${element.dataWyjazdu.toDate()} ${element.obiekt.nr} ${element.kht.nazwa}');
              }
            }
            //bookings.add(snapshot.data!);
            Stopwatch stopwatch = Stopwatch()..start();
            var listaDomkow = getData(bookings, year);
            log('getData: ${stopwatch.elapsed}');
            var listaRezerwacjiDomku1 = listaDomkow[0];
            var listaRezerwacjiDomku2 = listaDomkow[1];
            var listaRezerwacjiDomku3 = listaDomkow[2];
            var listaRezerwacjiDomku4 = listaDomkow[3];
            var listaRezerwacjiDomku5 = listaDomkow[4];
            var listaRezerwacjiDomku6 = listaDomkow[5];

            return Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      Expanded(
                          flex: 1, child: _Header("Dom", _oHeader, context)),
                      Expanded(flex: 2, child: _Resources("1", _oHeader)),
                      Expanded(flex: 2, child: _Resources("2", _oHeader)),
                      Expanded(flex: 2, child: _Resources("3", _oHeader)),
                      Expanded(flex: 2, child: _Resources("4", _oHeader)),
                      Expanded(flex: 2, child: _Resources("5", _oHeader)),
                      Expanded(flex: 2, child: _Resources("6", _oHeader))
                    ]),
                  ),
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _oHeader,
                            itemExtent: boxSize + 1,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              initializeDateFormatting('pl');
                              intl.DateFormat dateFormat =
                                  intl.DateFormat.E('pl');

                              return _Header(
                                  '${formatter.format(dateToPrint)}\n${dateFormat.format(dateToPrint)}',
                                  _oHeader,
                                  context);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o1,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));

                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');

                              var lista = listaRezerwacjiDomku1[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Rez? r;
                              Obiekt obiekt = Obiekt(
                                  id: '',
                                  obiektId: 1,
                                  typ: 'DOMEK',
                                  nazwa: 'Domek 1',
                                  nr: 1);

                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: obiekt,
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o2,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              var lista = listaRezerwacjiDomku2[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Obiekt obiekt = Obiekt(
                                  id: '',
                                  obiektId: 2,
                                  typ: 'DOMEK',
                                  nazwa: 'Domek 2',
                                  nr: 2);
                              Rez? r;
                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: obiekt,
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o3,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              var lista = listaRezerwacjiDomku3[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Obiekt obiekt = Obiekt(
                                  id: '',
                                  obiektId: 3,
                                  typ: 'DOMEK',
                                  nazwa: 'Domek 3',
                                  nr: 3);
                              Rez? r;
                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: obiekt,
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o4,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              var lista = listaRezerwacjiDomku4[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Obiekt obiekt = Obiekt(
                                  id: '',
                                  obiektId: 4,
                                  typ: 'DOMEK',
                                  nazwa: 'Domek 4',
                                  nr: 4);
                              Rez? r;
                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: obiekt,
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o5,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              var lista = listaRezerwacjiDomku5[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Rez? r;
                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: Obiekt(
                                      id: '',
                                      obiektId: 5,
                                      typ: 'DOMEK',
                                      nazwa: 'Domek 5',
                                      nr: 5),
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            addAutomaticKeepAlives: addAutomaticKeepAlives,
                            scrollDirection: Axis.horizontal,
                            controller: _o6,
                            itemCount:
                                DateUtil.isLeapYear(year.toInt()) ? 366 : 365,
                            itemBuilder: (BuildContext ctxt, int index) {
                              var dateToPrint =
                                  dateStart.add(Duration(days: index));
                              intl.DateFormat formatter =
                                  intl.DateFormat('dd.MM');
                              var lista = listaRezerwacjiDomku6[index];
                              var daysNo = 1;
                              var text = ""; // formatter.format(dateToPrint);
                              var hasData = false;
                              var hasZadatek = false;
                              Rez? r;
                              if (lista.length == 2) {
                                daysNo = lista[1];
                                r = lista[0];
                                text = r!.kht.nazwa;
                                hasData = true;
                                hasZadatek = r.zadatek > 0.0 ? true : false;
                              }
                              return _Tile(
                                  obiekt: Obiekt(
                                      id: '',
                                      obiektId: 6,
                                      typ: 'DOMEK',
                                      nazwa: 'Domek 6',
                                      nr: 6),
                                  date: dateToPrint,
                                  color: getColor(dateToPrint),
                                  caption: text,
                                  width: boxSize * daysNo +
                                      (daysNo > 1
                                          ? ((daysNo.toDouble() - 1) * 2.0) *
                                              0.5
                                          : 0.0),
                                  hasData: hasData,
                                  hasZadatek: hasZadatek,
                                  rezerwacja: r,
                                  context: ctxt);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          } else {
            return SpinnerWidget();
          }
        },
      ),
    );
  }

  void _showDialog(BuildContext context) {
    TextEditingController rokController = TextEditingController(text: '');

    rokController.addListener(() {});

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextFormField(
            autofocus: true,
            onFieldSubmitted: (String rok) {
              yearController.add(int.parse(rok));
              Navigator.of(context).pop();
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Rok',
            ),
            controller: rokController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            minLines: 1,
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                yearController.add(int.parse(rokController.value.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Color getColor(DateTime dateToPrint) {
  if (dateToPrint.weekday == DateTime.sunday) {
    return Colors.lightGreen.shade200;
  } else if (dateToPrint.weekday == DateTime.saturday) {
    return Colors.lightGreen.shade100;
  } else if (dateToPrint.weekday == DateTime.friday) {
    return Colors.lightGreen.shade50;
  }
  return Colors.grey.shade300;
}

class _Resources extends StatelessWidget {
  final String caption;
  final ScrollController scrollController;

  const _Resources(this.caption, this.scrollController);

  @override
  Widget build(_) => GestureDetector(
        onLongPress: () {
          switch (caption) {
            case '1':
              {
                scrollController.jumpTo(0.0);
              }
              break;
            case '2':
              {
                scrollController.jumpTo(boxSize * (31.0) + 30);
              }
              break;
            case '3':
              {
                scrollController.jumpTo(boxSize * (31.0 + 30.0) - 40);
              }
              break;
            case '4':
              {
                scrollController.jumpTo(boxSize * (31.0 + 30.0 + 31) - 10);
              }
              break;
            case '5':
              {
                scrollController.jumpTo(boxSize * (31.0 + 30.0 + 31 + 30) + 20);
              }
              break;
            case '6':
              {
                scrollController
                    .jumpTo(boxSize * (31.0 + 30.0 + 31 + 30 + 31) + 50);
              }
              break;
          }
        },
        onDoubleTap: () {
          switch (caption) {
            case '1':
              {
                scrollController.jumpTo(0.0);
              }
              break;
            case '2':
              {
                scrollController.jumpTo(boxSize * (31.0 + 30.0 + 31) - 10);
              }
              break;
            case '3':
              {
                scrollController
                    .jumpTo(boxSize * (31.0 + 30.0 + 31 + 30 + 31) + 50);
              }
              break;
            case '4':
              {
                scrollController.jumpTo(
                    boxSize * (31.0 + 30.0 + 31 + 30 + 31 + 30 + 31) + 110);
              }
              break;
            case '5':
              {
                scrollController.jumpTo(
                    boxSize * (31.0 + 30.0 + 31 + 30 + 31 + 30 + 31 + 31 + 33) +
                        20);
              }
              break;
            case '6':
              {
                scrollController.jumpTo(boxSize *
                        (31.0 +
                            30.0 +
                            31 +
                            30 +
                            31 +
                            30 +
                            31 +
                            31 +
                            33 +
                            30 +
                            31) +
                    84);
              }
              break;
          }
        },
        child: Container(
          margin: const EdgeInsets.all(0.5),
          color: Colors.lightBlueAccent.shade400,
          child: Center(
            child: Text(
              caption,
              style: GoogleFonts.comfortaa(
                  textStyle: const TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  final String caption;
  final double width;
  final bool hasData;
  final bool hasZadatek;
  final BuildContext context;
  final Rez? rezerwacja;
  final Color color;
  final DateTime date;
  final Obiekt obiekt;
  const _Tile(
      {required this.caption,
      required this.width,
      required this.hasData,
      required this.hasZadatek,
      this.rezerwacja,
      required this.context,
      required this.color,
      required this.date,
      required this.obiekt});

  @override
  Widget build(_) => GestureDetector(
        onLongPress: () {
          rezerwacja != null
              ? showBooking(context, rezerwacja!)
              : newBooking(context, date, obiekt);
        },
        child: Container(
          margin: width == 0
              ? const EdgeInsets.all(0.0)
              : const EdgeInsets.all(0.5),
          //padding: const EdgeInsets.all(3.0),
          //height: 250.0,
          width: width,
          color: (hasData && rezerwacja!.razem == 0.0)
              ? Colors.redAccent
              : hasZadatek
                  ? Colors.lightBlue
                  : hasData
                      ? Colors.lightGreen
                      : color,
          child: Column(
            children: [
              Row(
                children: [
                  Visibility(
                    visible: () {
                      if (rezerwacja == null) {
                        return false;
                      } else if (rezerwacja!.uwagi == null) {
                        return false;
                      } else if (rezerwacja!.uwagi.isNotEmpty) {
                        return true;
                      }
                      return false;
                    }(),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 15.0,
                        )),
                  ),
                  Visibility(
                    visible: () {
                      if (rezerwacja == null) {
                        return false;
                      } else if (rezerwacja!.kht.telefon == null) {
                        return false;
                      } else if (rezerwacja!.kht.telefon.isNotEmpty) {
                        return true;
                      }
                      return false;
                    }(),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 15.0,
                        )),
                  ),
                  Visibility(
                    visible: () {
                      if (rezerwacja == null) {
                        return false;
                      } else if (rezerwacja!.zadatek == 0) {
                        return false;
                      } else if (rezerwacja!.zadatek > 0) {
                        return true;
                      }
                      return false;
                    }(),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.money,
                          color: Colors.white,
                          size: 15.0,
                        )),
                  ),
                ],
              ),
              Center(
                  child: Text(
                caption,
                style: GoogleFonts.varelaRound(
                    textStyle: TextStyle(
                        decoration: TextDecoration.none,
                        color: hasData ? Colors.white : Colors.black87,
                        fontSize: hasData ? 12 : 10,
                        fontWeight: FontWeight.w900)),
              )),
            ],
          ),
        ),
      );

  newBooking(BuildContext context, DateTime date, Obiekt obiekt) {
    date = DateTime(date.year, date.month, date.day);
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
        dataPrzyjazdu: Timestamp.fromDate(date),
        dataWyjazdu: Timestamp.fromDate(date.add(const Duration(days: 7))),
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
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBooking(
            booking: newRez,
          ),
        ));
    //showNewBookingDialog(context, newRez);
  }
}

updateRez(BuildContext context, Rez rezerwacja) async {}

showNewBookingDialog(BuildContext context, Rez rezerwacja) {
  bool loading = false;
  TextEditingController _uwagiController = TextEditingController();
  _uwagiController.text = rezerwacja.uwagi;
  Widget okButton = loading
      ? const Center(child: CircularProgressIndicator())
      : TextButton(
          child: const Text("OK"),
          onPressed: () async {
            loading = true;
            log("zapisz:${_uwagiController.text}");
            if (rezerwacja.uwagi != _uwagiController.text) {
              log("Zmienione uwagi. Trzeba zapisać");
              rezerwacja.uwagi = _uwagiController.text;
              FirebaseStreams.updateBookin(rezerwacja);
              Rez r = await updateRez(context, rezerwacja);
              log(r.toString());
            }
            Navigator.pop(context);
          },
        );
}

Future<void> showBooking(BuildContext context, Rez rezerwacja) async {
  log('showBooking ${rezerwacja.id}');
  final Rez? updBooking = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBooking(
          booking: rezerwacja,
        ),
      ));
  /*.then((value) => () {
        FirebaseStreams.records(year).listen(
          (event) {
            var lista = event.docs;
            if (lista.isEmpty) reloadController.add(true);
          },
        );
        bookings.remove(rezerwacja);
      });*/
  Stopwatch stopwatch = Stopwatch()..start();
  if (updBooking == null) {
    bookings.removeWhere((item) => item.id == rezerwacja.id);
    //removedController.add(rezerwacja);
  } else {
    log(bookings.length.toString());
    bookings.removeWhere((item) => item.id == updBooking.id);
    bookings.add(updBooking);
  }
  //log('updBooking: ${stopwatch.elapsed}');
  //reloadController.add(true);
}

class _Header extends StatelessWidget {
  final String caption;
  final ScrollController oHeader;
  final BuildContext context;
  const _Header(this.caption, this.oHeader, this.context);
  @override
  Widget build(_) => GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(0.5),
          //padding: const EdgeInsets.all(3.0),
          height: 20.0,
          color: Colors.black54,
          child: Center(
              child: Text(
            caption,
            style: GoogleFonts.comfortaa(
                textStyle: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900)),
          )),
        ),
      );
}

List getData(List<Rez> bookings, int year) {
  var listaDomkow = [];
  listaDomkow.length = 6;
  log("Calendar data initialization.");
  for (int d = 0; d < 6; d++) {
    var listaRezDomku = [];
    var dateStart = DateTime(year, 1, 1);
    var days = DateUtil.isLeapYear(year.toInt()) ? 366 : 365;
    for (int i = 0; i < days; i++) {
      var dateToPrint = dateStart.add(Duration(days: i));
      listaRezDomku.add(getDays(bookings, d + 1, dateToPrint.year,
          dateToPrint.month, dateToPrint.day));
    }
    listaDomkow[d] = (listaRezDomku);
  }
  return listaDomkow;
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

List getDays(List<Rez> bookings, int nrDomku, int year, int month, int day) {
  var daysNo = 1;
  var iter = bookings.iterator;
  var lista = [];
  while (iter.moveNext()) {
    var rezerwacja = iter.current;
    var dataPrzyjazdu = DateTime(
        rezerwacja.dataPrzyjazdu.toDate().year,
        rezerwacja.dataPrzyjazdu.toDate().month,
        rezerwacja.dataPrzyjazdu.toDate().day);
    var dataWyjazdu = DateTime(
        rezerwacja.dataWyjazdu.toDate().year,
        rezerwacja.dataWyjazdu.toDate().month,
        rezerwacja.dataWyjazdu.toDate().day);
    var dataSprawdzania = DateTime(year, month, day);
    if (rezerwacja.obiekt.nr == nrDomku) {
      if (dataSprawdzania.isSameDate(dataPrzyjazdu)) {
        var bookingLength = dataWyjazdu.difference(dataPrzyjazdu).inDays;
        daysNo = bookingLength;
        lista = [rezerwacja, daysNo];
        break;
      } else if (dataSprawdzania.isAfter(dataPrzyjazdu) &&
          dataSprawdzania.isBefore(dataWyjazdu)) {
        daysNo = 0;
        lista = [rezerwacja, daysNo];
        break;
      }
    }
  }
  return lista;
}

class SpinnerWidget extends StatelessWidget {
  const SpinnerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          alignment: AlignmentDirectional.bottomCenter,
          child: Column(
            children: const <Widget>[
              CircularProgressIndicator(),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
          )),
    );
  }
}

class DateUtil {
  static bool isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
