import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class DateScroller extends StatelessWidget {
  final DateTime dateToDisplay;
  final DatePickerController _controller;
  final Function(DateTime) updateSelectedDate;
  final Color color;

  const DateScroller(
      this.dateToDisplay, this.updateSelectedDate, this._controller,
      {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, left: 10),
        child: DatePicker(
          DateTime.now().subtract(const Duration(days: 365)),
          height: 80,
          width: 64,
          initialSelectedDate: DateTime.now(),
          selectionColor: color,
          selectedTextColor: Colors.white,
          monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          daysCount: 1000,
          onDateChange: (date) {
            updateSelectedDate(date);
          },
          controller: _controller,
        ));
  }
}
