import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncCalendar {
  // can be changed accordingly
  static int daysToSync = 14;

  static Future<void> syncCalendarByDay(
    DateTime selectedDate,
    GoogleSignIn googleSignIn,
    BuildContext context,
  ) async {
    final scaffoldMessengerState = ScaffoldMessenger.of(context);
    final SnackBar syncSnackbar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 5,
          ),
          // reduce size of circular progress indicator
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              "Syncing calendar for $daysToSync days...",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Lato",
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.grey.shade400,
      // round corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),

      margin: const EdgeInsets.only(
        bottom: 80,
        left: 20,
        right: 20,
      ),
    );
    print('Syncing calendar for $daysToSync days...');
    scaffoldMessengerState.showSnackBar(syncSnackbar);

    final auth.AuthClient? client = await googleSignIn.authenticatedClient();
    final cal.CalendarApi gcalApi = cal.CalendarApi(client!);

    List<List<String>> eventsData = [];

    for (int i = 0; i < daysToSync; i++) {
      final cal.Events calEvents = await gcalApi.events.list(
        "primary",
        timeMin: selectedDate,
        timeMax: selectedDate.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        ),
      );
      final List<cal.Event> appointments = <cal.Event>[];

      if (calEvents.items != null) {
        for (int i = 0; i < calEvents.items!.length; i++) {
          final cal.Event event = calEvents.items![i];
          if (event.start == null) {
            continue;
          }
          appointments.add(event);
        }
      }

      List<String> eventsTimings = appointments.map((event) {
        String startTimeString;
        String endTimeString;
        if (event.start?.dateTime != null) {
          startTimeString =
              DateFormat('HHmm').format(event.start!.dateTime!.toLocal());
        } else {
          startTimeString = "0000";
        }
        if (event.end?.dateTime != null) {
          endTimeString =
              DateFormat('HHmm').format(event.end!.dateTime!.toLocal());
        } else {
          endTimeString = "0000";
        }
        return "$startTimeString-$endTimeString";
      }).toList();

      eventsData.add(eventsTimings);

      selectedDate = selectedDate.add(const Duration(days: 1));
    }

    final db = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = db.collection('users').doc(userId);

    for (int i = 0; i < eventsData.length; i++) {
      final date =
          DateTime.now().add(Duration(days: i)).toString().split(' ')[0];
      final eventData = eventsData[i];

      final availabilityData = {date: eventData};

      await userRef.set({
        'availability': availabilityData,
      }, SetOptions(merge: true));
    }

    print('Syncing done!');
    SnackBar doneSnackbar = SnackBar(
      content: const Text(
        'Syncing done!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Lato",
          fontSize: 15,
        ),
      ),
      duration: const Duration(seconds: 1),
      elevation: 0,
      backgroundColor: Colors.grey.shade400,
      // round corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        bottom: 80,
        left: 20,
        right: 20,
      ),
    );

    scaffoldMessengerState.showSnackBar(doneSnackbar);
  }
}
