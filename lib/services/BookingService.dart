// ignore_for_file: file_names

import 'dart:convert' show json, base64, ascii, jsonEncode, utf8;
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:wypoczynkowa_osada/constants/constants.dart';
import 'package:wypoczynkowa_osada/models/Rez.dart';

class BookingService {
  BookingService(this.jwt, this.payload);

  factory BookingService.fromBase64(String jwt) => BookingService(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  String jwt;
  final String serverIP = Configuration.getServerIP();
  Map<String, dynamic> payload;

  Future<List<Rez>> getBookingsBetween() async {
    log('$serverIP/user/rezerwacjeBetween');
    log("Bearer " + jwt);
    var dateformat = DateFormat('yyyy-MM-dd');
    var now = DateTime.now();
    var end = dateformat.format(DateTime(now.year, 12, 31));
    var start = dateformat.format(DateTime(now.year - 10, 1, 1));

    var queryParameters = {
      'start': start,
      'end': end,
    };
    var uri = Uri.https(serverIP, '/user/rezerwacjeBetween', queryParameters);
    log("URI: " + uri.toString());

    final res = await http.get(uri, headers: {
      HttpHeaders.authorizationHeader: 'Bearer $jwt',
      HttpHeaders.contentTypeHeader: 'application/json'
    });

    if (kDebugMode) {
      print('getBookingsBetween() ' + res.statusCode.toString());
    }

    if (res.statusCode == 200) {
      //var content = await res.transform(utf8.decoder).join();
      var content = res.body;
      var arr = json.decode(content) as List;

      // for every element of arr map to _fromJson
      // and convert the array to list
      var ret = arr.map((e) => Rez.fromJson(e)).toList();
      return ret;
    }

    return <Rez>[];
  }

  Future<Rez?> updateRez(Rez rezerwacja) async {
    log('$serverIP/user/rezerwacja/update');
    log("Bearer " + jwt);

    var uri = Uri.https(serverIP, '/user/rezerwacja/update');
    log("URI: " + uri.toString());
    log("BODY:");
    log(rezerwacja.toJson().toString());
    final msg = jsonEncode(rezerwacja.toJson());
    log(msg);
    final res = await http.put(uri, body: msg, headers: {
      HttpHeaders.authorizationHeader: 'Bearer $jwt',
      HttpHeaders.contentTypeHeader: 'application/json'
    });

    if (res.statusCode == 200) {
      var content = res.body;
      Rez r = Rez.fromJson(json.decode(content));
      return r;
    }
  }
}
