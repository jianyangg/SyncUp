import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

class EventTile extends StatelessWidget {
  final cal.Event event;
  final Color color;
  final String groupName;
  const EventTile(this.event,
      {super.key, required this.color, required this.groupName});

  // Then for own_events_page, we should all of the current user's events, but colour code according to the group.

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
          color: event.extendedProperties?.shared?['CREATOR'] == "SYNCUP"
              ? Colors.orange.shade700
              : color,
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.summary ?? "N/A",
                  style: const TextStyle(
                      fontFamily: "Lato",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[100],
                        fontFamily: "Lato",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: "Lato",
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
            visible: event.extendedProperties?.shared?['CREATOR'] == "SYNCUP",
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                event.extendedProperties?.shared?['GROUP_NAME'] ?? "",
                style: const TextStyle(
                    fontFamily: "Lato",
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
