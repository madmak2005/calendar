import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wypoczynkowa_osada/pages/gridCalendar.page.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: Colors.pink,
            ),
            title: Text(
              'Kalendarz',
              style: GoogleFonts.comfortaa(
                  textStyle: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
            tileColor: Colors.lightBlueAccent,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CalendarPage()));
            }),
      ),
    );
  }
}
