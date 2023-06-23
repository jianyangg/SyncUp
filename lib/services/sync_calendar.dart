import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncCalendar {
  static int daysToSync = 14;
  static Future<void> syncCalendarByDay(
      DateTime selectedDate, GoogleSignIn googleSignIn) async {
    // Get user's calendar events
    // loop through the dates for the next 7 days
    // save the
    print("Syncing calendar for $daysToSync days...");
    final auth.AuthClient? client = await googleSignIn.authenticatedClient();
    // assert(client != null);
    final cal.CalendarApi gcalApi = cal.CalendarApi(client!);

    List<List<String>> eventsData = []; // 2D array to store events data

    for (int i = 0; i < daysToSync; i++) {
      // get events for the selected date
      // await GetEventsDay().handleGetEventsForDay(selectedDate);
      final cal.Events calEvents = await gcalApi.events.list(
        "primary",
        timeMin: selectedDate,
        timeMax: selectedDate
            .add(const Duration(hours: 23, minutes: 59, seconds: 59)),
      );
      final List<cal.Event> appointments = <cal.Event>[];
      // add all events to appointments which is a List<cal.Event>
      if (calEvents.items != null) {
        for (int i = 0; i < calEvents.items!.length; i++) {
          final cal.Event event = calEvents.items![i];
          if (event.start == null) {
            continue;
          }
          appointments.add(event);
        }
      }

      // Convert appointments to 1D array of event timings
      List<String> eventsTimings = appointments
          .map((event) =>
              '${DateFormat('HHmm').format(event.start!.dateTime!.toLocal())}-${DateFormat('HHmm').format(event.end!.dateTime!.toLocal())}')
          .toList();

      // Add events timings to 2D array
      eventsData.add(eventsTimings);

      // Increment the date by 1 day
      selectedDate = selectedDate.add(const Duration(days: 1));
    }
    print("ownEventsData: $eventsData");
    // now save the numbers to the database
    // Save the events data to Firestore
    final db = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = db.collection('users').doc(userId);

    // Create a new document
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
  }
}
