import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DateTile extends StatelessWidget {
  final DateTime dateToDisplay;
  final Color bgColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry margin;

  const DateTile({
    required this.dateToDisplay,
    required this.bgColor,
    required this.textColor,
    this.fontSize = 16,
    this.margin = const EdgeInsets.only(left: 20, right: 220, bottom: 10),
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor, // color prop
        ),
        alignment: Alignment.center,
        child: Text(
          DateFormat('EEE, dd MMM yyyy').format(dateToDisplay), // date prop
          style: GoogleFonts.lato(
            fontSize: fontSize,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
        ));
  }
}
