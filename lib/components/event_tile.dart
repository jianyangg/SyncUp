import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

class EventTile extends StatelessWidget {
  final cal.Event event;
  final Color color;
  const EventTile(this.event, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        //  width: SizeConfig.screenWidth * 0.78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: event.extendedProperties?.private?['CREATOR'] == "SYNCUP"
              ? Colors.orange.shade800
              : color,
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.summary ?? "N/A",
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey[200],
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (event.start?.dateTime != null &&
                              event.end?.dateTime != null)
                          ? '${DateFormat('HH:mm').format(event.start!.dateTime!.toLocal())} to ${DateFormat('HH:mm').format(event.end!.dateTime!.toLocal())}'
                          : 'All Day',
                      style: GoogleFonts.lato(
                        textStyle:
                            TextStyle(fontSize: 13, color: Colors.grey[100]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: GoogleFonts.lato().fontFamily,
                    color: Colors.grey[100],
                  ),
                  child: Html(
                    data: event.description ?? "",
                    style: {
                      'a': Style(
                        color: Colors.blue,
                        textDecoration: TextDecoration.underline,
                      )
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            width: 0.5,
            color: Colors.grey[200]!.withOpacity(0.7),
          ),
          Visibility(
            visible: event.extendedProperties?.private?['CREATOR'] == "SYNCUP",
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                event.extendedProperties?.private?['GROUP_NAME'] ?? "",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
