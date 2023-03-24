import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wypoczynkowa_osada/constants/constants.dart';
import 'package:wypoczynkowa_osada/models/Obiekt.dart';
import 'package:wypoczynkowa_osada/models/PopupChoices.dart';
import 'package:wypoczynkowa_osada/models/Rez.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wypoczynkowa_osada/pages/gridCalendar.page.dart';
import 'package:wypoczynkowa_osada/streams/firebaseStreams.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:math' as math;

class EditBooking extends StatefulWidget {
  late final Rez booking;

  EditBooking({Key? key, required this.booking}) : super(key: key);

  @override
  State<EditBooking> createState() => _EditBookingState(booking: booking);
}

class _EditBookingState extends State<EditBooking> {
  Rez booking;
  late DateTime startDate;
  late DateTime endDate;
  late int days = 7;

  _EditBookingState({required this.booking}) {
    startDate = booking.dataPrzyjazdu.toDate().add(const Duration(days: 0));
    endDate = booking.dataPrzyjazdu.toDate().add(const Duration(days: 60));
    booking.kht.telefon =
        booking.kht.telefon.isEmpty ? '+48' : booking.kht.telefon;

    days = booking.dataWyjazdu
        .toDate()
        .difference(booking.dataPrzyjazdu.toDate())
        .inDays;
  }

  void onDaysChange(int d) {
    setState(() {
      log(d.toString());
      booking.dataWyjazdu = Timestamp.fromDate(
          booking.dataPrzyjazdu.toDate().add(Duration(days: d)));
    });
  }

  void onDCalendarChange() {
    days = booking.dataWyjazdu
        .toDate()
        .difference(booking.dataPrzyjazdu.toDate())
        .inDays;
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Skasuj', icon: Icons.delete_forever),
  ];

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Skasuj') {
      _delete();
      Navigator.pop(context, null);
    }
  }

  Widget buildPopupMenu(BuildContext context) {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: const TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController imieController =
        TextEditingController(text: booking.kht.imie);
    TextEditingController nazwaController =
        TextEditingController(text: booking.kht.nazwa);
    TextEditingController telefonController =
        TextEditingController(text: booking.kht.telefon);
    TextEditingController doroslychController = TextEditingController(
        text: booking.iloscDoroslych == 0
            ? ''
            : booking.iloscDoroslych.toString());
    TextEditingController dzieciController = TextEditingController(
        text: booking.iloscDzieci == 0 ? '' : booking.iloscDzieci.toString());
    TextEditingController uwagiController =
        TextEditingController(text: booking.uwagi);
    TextEditingController zadatekController = TextEditingController(
        text: booking.zadatek != 0 ? booking.zadatek.toStringAsFixed(0) : '');
    TextEditingController paragonController = TextEditingController(
        text: booking.paragon != 0 ? booking.paragon.toStringAsFixed(2) : '');
    TextEditingController razemController = TextEditingController(
        text: booking.razem != 0 ? booking.razem.toStringAsFixed(2) : '');
    TextEditingController klimatyczneController = TextEditingController(
        text: booking.klimatyczne != 0
            ? booking.klimatyczne.toStringAsFixed(2)
            : '');

    imieController.addListener(() {
      booking.kht.imie = imieController.text;
    });

    nazwaController.addListener(() {
      booking.kht.nazwa = nazwaController.text;
    });

    telefonController.addListener(() {
      booking.kht.telefon = telefonController.text;
    });

    doroslychController.addListener(() {
      var ile = int.tryParse(doroslychController.text);
      ile ??= 0;
      booking.iloscDoroslych = ile;
    });

    dzieciController.addListener(() {
      var ile = int.tryParse(dzieciController.text);
      ile ??= 0;
      booking.iloscDzieci = ile;
    });

    uwagiController.addListener(() {
      booking.uwagi = uwagiController.text;
    });

    zadatekController.addListener(() {
      double? zadatek = double.tryParse(zadatekController.text);
      zadatek ??= 0.0;
      booking.zadatek = zadatek;
    });

    paragonController.addListener(() {
      double? paragon = double.tryParse(paragonController.text);
      paragon ??= 0.0;
      booking.paragon = paragon;
    });

    klimatyczneController.addListener(() {
      double? kwota = double.tryParse(klimatyczneController.text);
      kwota ??= 0.0;
      booking.klimatyczne = kwota;
    });

    razemController.addListener(() {
      double? kwota = double.tryParse(razemController.text);
      kwota ??= 0.0;
      booking.razem = kwota;
    });

    initializeDateFormatting('pl');
    intl.DateFormat dateFormat = intl.DateFormat.yMEd('pl');
    var dom = booking.obiekt.nr;
    return WillPopScope(
      onWillPop: () {
        save(context: context);
        Navigator.pop(context, booking);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [buildPopupMenu(context)],
          title: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: NumberPicker(
                    value: dom,
                    minValue: 1,
                    maxValue: 6,
                    step: 1,
                    itemHeight: 30,
                    haptics: true,
                    onChanged: (value) => setState(() {
                      dom = value;
                      onObiektChange(dom);
                    }),
                    textStyle: const TextStyle(color: Colors.white),
                    selectedTextStyle: const TextStyle(color: Colors.amber),
                  )),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateFormat.format(booking.dataPrzyjazdu.toDate()),
                      style: GoogleFonts.firaCode(
                          textStyle: const TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ),
                    Text(
                      dateFormat.format(booking.dataWyjazdu.toDate()),
                      style: GoogleFonts.firaCode(
                          textStyle: const TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: NumberPicker(
                    value: days,
                    minValue: 1,
                    maxValue: 31,
                    step: 1,
                    itemHeight: 30,
                    haptics: true,
                    onChanged: (value) => setState(() {
                      days = value;
                      onDaysChange(days);
                    }),
                    textStyle: const TextStyle(color: Colors.white),
                    selectedTextStyle: const TextStyle(color: Colors.amber),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      lastDate: endDate,
                      firstDate: startDate,
                    );
                    if (picked != null) {
                      if (kDebugMode) {
                        print(picked);
                      }
                      setState(() {
                        booking.dataPrzyjazdu =
                            Timestamp.fromDate(picked.start);
                        booking.dataWyjazdu = Timestamp.fromDate(picked.end);
                        onDCalendarChange();
                        //startDate = picked.start;
                        //endDate = picked.end;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: MyBody(
            imieController: imieController,
            nazwaController: nazwaController,
            telefonController: telefonController,
            doroslychController: doroslychController,
            dzieciController: dzieciController,
            zadatekController: zadatekController,
            uwagiController: uwagiController,
            paragonController: paragonController,
            klimatyczneController: klimatyczneController,
            razemController: razemController,
            booking: booking,
          ),
        ),
      ),
    );
  }

  Future<bool> save({required BuildContext context}) {
    if (booking.kht.imie.isNotEmpty || booking.kht.nazwa.isNotEmpty) {
      if (booking.kht.telefon == '+48') booking.kht.telefon = '';

      if (booking.id == 'auto') {
        log('inserting');
        FirebaseStreams.insertBooking(booking);
      } else {
        log('updating');
        FirebaseStreams.updateBookin(booking);
      }
    }
    return Future.value(true);
  }

  _delete() {
    log("kasuję: ${booking.id}");
    FirebaseStreams.deleteBooking(booking);
    bookings.remove(booking);
    setState(() {
      booking = Rez.emptyFromOld(booking);
    });
  }

  void onObiektChange(int dom) {
    booking.obiekt.nr = dom;
    booking.obiekt.obiektId = dom;
    booking.obiekt.nazwa = 'Domek $dom';
  }
}

class MyBody extends StatelessWidget {
  final _keyValidationForm = GlobalKey<FormState>();
  final FocusNode _imieNode = FocusNode();
  final FocusNode _nazwaNode = FocusNode();
  final FocusNode _zadatekNode = FocusNode();
  final FocusNode _iloscDzieciNode = FocusNode();
  final FocusNode _klimatyczneNode = FocusNode();
  final FocusNode _paragonNode = FocusNode();
  final FocusNode _razemNode = FocusNode();
  final FocusNode _uwagiNode = FocusNode();

  MyBody(
      {Key? key,
      required TextEditingController imieController,
      required TextEditingController nazwaController,
      required TextEditingController telefonController,
      required TextEditingController zadatekController,
      required TextEditingController uwagiController,
      required TextEditingController doroslychController,
      required TextEditingController dzieciController,
      required TextEditingController paragonController,
      required TextEditingController klimatyczneController,
      required TextEditingController razemController,
      required Rez booking})
      : _imieController = imieController,
        _nazwaController = nazwaController,
        _telefonController = telefonController,
        _doroslychkController = doroslychController,
        _dzieciController = dzieciController,
        _zadatekController = zadatekController,
        _uwagiController = uwagiController,
        _booking = booking,
        _razemController = razemController,
        _klimatyczneController = klimatyczneController,
        _paragonController = paragonController,
        super(key: key);

  final TextEditingController _imieController;
  final TextEditingController _nazwaController;
  final TextEditingController _telefonController;
  final TextEditingController _zadatekController;
  final TextEditingController _doroslychkController;
  final TextEditingController _dzieciController;
  final TextEditingController _uwagiController;
  final TextEditingController _razemController;
  final TextEditingController _klimatyczneController;
  final TextEditingController _paragonController;
  final Rez _booking;

  final maskFormatter = MaskTextInputFormatter(
    initialText: '48',
    mask: '+## ### ### ### ###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  Widget build(BuildContext context) {
    maskFormatter.maskText('48');
    if (kDebugMode) {
      log("masked: ${maskFormatter.getMaskedText()}");
    }
    return Form(
      key: _keyValidationForm,
      onChanged: formChanged,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Wprowadź imię',
            ),
            focusNode: _imieNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: _imieController,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (String value) {
              FocusScope.of(context).requestFocus(_nazwaNode);
            },
            minLines: 1,
            maxLines: null,
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Wprowadź nazwisko / nazwę firmy',
            ),
            focusNode: _nazwaNode,
            controller: _nazwaController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: null,
          ),
          TextFormField(
            inputFormatters: [maskFormatter],
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Wprowadź telefon',
            ),
            controller: _telefonController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            minLines: 1,
            maxLines: null,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ilość dorosłych',
                  ),
                  controller: _doroslychkController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_iloscDzieciNode);
                  },
                  minLines: 1,
                  maxLines: null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Ilość dzieci',
                  ),
                  focusNode: _iloscDzieciNode,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_zadatekNode);
                  },
                  controller: _dzieciController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  minLines: 1,
                  maxLines: null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Wprowadź zadatek',
                  ),
                  focusNode: _zadatekNode,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_klimatyczneNode);
                  },
                  controller: _zadatekController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  minLines: 1,
                  maxLines: null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Wprowadź klimatyczne',
                  ),
                  focusNode: _klimatyczneNode,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_paragonNode);
                  },
                  controller: _klimatyczneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                  minLines: 1,
                  maxLines: null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Wprowadź paragon',
                  ),
                  focusNode: _paragonNode,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_razemNode);
                  },
                  controller: _paragonController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                  minLines: 1,
                  maxLines: null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Wprowadź razem',
                  ),
                  focusNode: _razemNode,
                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(_uwagiNode);
                  },
                  controller: _razemController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                  minLines: 1,
                  maxLines: null,
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Wprowadź uwagi',
            ),
            focusNode: _uwagiNode,
            onFieldSubmitted: (String value) {
              save(_booking);
              Navigator.pop(context, _booking);
            },
            controller: _uwagiController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  void formChanged() {
    log("FORM CHANGED");
  }

  Future<bool> save(Rez booking) {
    if (booking.kht.imie.isNotEmpty || booking.kht.nazwa.isNotEmpty) {
      if (booking.kht.telefon == '+48') booking.kht.telefon = '';

      if (booking.id == 'auto') {
        log('inserting');
        FirebaseStreams.insertBooking(booking);
      } else {
        log('updating');
        FirebaseStreams.updateBookin(booking);
      }
    }
    return Future.value(true);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;
    if (newValue.text.contains(",")) {
      truncated = value.replaceAll(',', '.');
    }

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
