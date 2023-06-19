import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DateTile extends StatelessWidget {
  final DateTime dateToDisplay;
  final Color bgColor;
  final Color textColor;
  const DateTile(this.dateToDisplay, this.bgColor, this.textColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 20, right: 220, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor, // color prop
        ),
        alignment: Alignment.center,
        child: Text(
          DateFormat('EEE, dd MMM yyyy').format(dateToDisplay), // date prop
          style: GoogleFonts.lato(
            fontSize: 16,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ));
  }
}
