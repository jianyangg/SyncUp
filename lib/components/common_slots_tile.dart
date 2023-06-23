import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:sync_up/components/confirm_group_event_dialog.dart';
import 'package:sync_up/components/date_tile.dart';
import 'package:sync_up/components/event_tile.dart';
import 'package:sync_up/components/time_slot_tile.dart';
import 'package:sync_up/services/get_common_time.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;

import '../pages/group_events_page.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

class CommonSlotsTile extends StatefulWidget {
  final String eventName;
  final int selectedPeriod;
  final String selectedDateRangeText;
  final String userId;
  final String groupId;
  final String groupName;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> userIds;

  const CommonSlotsTile(
      {super.key,
      required this.eventName,
      required this.selectedPeriod,
      required this.selectedDateRangeText,
      required this.startDate,
      required this.endDate,
      required this.userId,
      required this.groupId,
      required this.groupName,
      required this.userIds});

  @override
  State<CommonSlotsTile> createState() => _CommonSlotsTileState();
}

class _CommonSlotsTileState extends State<CommonSlotsTile> {
  final firestore = FirebaseFirestore.instance;

  GoogleSignInAccount? _currentUser;
  late DateTime selectedDate;
  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _authenticateUserAndInstantiateAPI();
        // might not need to do anything here
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<cal.CalendarApi> _authenticateUserAndInstantiateAPI() async {
    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    // Prepare a gcal authenticated client. ORIGINAL. KEEP THIS CODE
    return cal.CalendarApi(client!);
  }

  Future<List<List<String>>> getSlotsSuggestions() async {
    List<List<String>> workingHourFreeSlots = await GetCommonTime.findFreeSlots(
        widget.userIds, widget.startDate, widget.endDate);
    // now we want to slice the free time slots into intervals accoridng to the selected period
    // e.g. if selected period is 30 mins, then we want to slice the free time slots into 30 mins intervals
    List<List<String>> slicedFreeSlots = [];
    int countDays = 0;
    for (List<String> day in workingHourFreeSlots) {
      List<String> slicedDay = [];
      DateTime currentDay = widget.startDate.add(Duration(days: countDays));
      for (String timeSlot in day) {
        // split the time slot into start and end time
        List<String> timeSlotSplit = timeSlot.split("-");
        // convert the start and end time into DateTime objects
        // now convert 09:00 to DateTime object
        List<String> startTimeStringSplit = timeSlotSplit[0].split(":");
        int startHours = int.parse(startTimeStringSplit[0]);
        int startMinutes = int.parse(startTimeStringSplit[1]);
        List<String> endTimeStringSplit = timeSlotSplit[1].split(":");
        int endHours = int.parse(endTimeStringSplit[0]);
        int endMinutes = int.parse(endTimeStringSplit[1]);

        // Create a DateTime object with today's date and the specified time
        DateTime startTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          startHours,
          startMinutes,
        );

        DateTime endTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          endHours,
          endMinutes,
        );

        // slice the time slot into intervals
        while (startTime.isBefore(endTime)) {
          slicedDay.add(startTime.toIso8601String());
          startTime = startTime.add(Duration(minutes: widget.selectedPeriod));
        }
      }
      slicedFreeSlots.add(slicedDay);
    }
    // print(slicedFreeSlots);
    List<List<String>> formattedSlots = [];

    for (var slots in slicedFreeSlots) {
      List<String> formattedList = [];

      for (var slot in slots) {
        DateTime dateTime = DateTime.parse(slot);
        String formattedTime =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        formattedList.add(formattedTime);
      }

      formattedSlots.add(formattedList);
    }
    // print(formattedSlots);
    return formattedSlots;
  }

  List<DateTime> getStartEndTime(
      String startTime, int selectedPeriod, DateTime currentDate) {
    List<String> startTimeSplit = startTime.split(':');
    int startHour = int.parse(startTimeSplit[0]);
    int startMinute = int.parse(startTimeSplit[1]);

    int endMinute = startMinute + selectedPeriod;
    int endHour = startHour + (endMinute ~/ 60);
    endMinute %= 60;
    String formattedStartTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    String formattedEndTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    DateTime startDateTime = DateTime.parse(
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')} $formattedStartTime");
    DateTime endDateTime = DateTime.parse(
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')} $formattedEndTime");
    return [startDateTime, endDateTime];
  }

  Future<List<String>> getUserEmails(List<String> userIds) async {
    final firestore = FirebaseFirestore.instance;

    final List<String> userEmails = [];

    for (final userId in userIds) {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final email = userDoc.get('email') as String;
        userEmails.add(email);
      }
    }

    return userEmails;
  }

  void createEventAndBackToGroupPage(cal.Event event) async {
    try {
      cal.CalendarApi calendarApi = await _authenticateUserAndInstantiateAPI();
      calendarApi.events
          .insert(event, "primary", sendNotifications: true)
          .then((value) {
        print("ADDEDDD_________________${value.status}");
        if (value.status == "confirmed") {
          print('Event added in google calendar');
        } else {
          print("Unable to add event in google calendar");
        }
      });
    } catch (e) {
      print('Error creating event $e');
    }
    // back to group page. consider implementing it later on such that it scrolls
    // to the date that the event is created for.
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => GroupEventsPage(
          userId: widget.userId,
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.orange[300],
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_fields),
                          SizedBox(width: 8),
                          Text(
                            "Event Title: ${widget.eventName}",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.date_range),
                          SizedBox(width: 8),
                          Text(
                            "Dates: ${widget.selectedDateRangeText}",
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 8),
                          Text(
                            "Duration: ${widget.selectedPeriod} minutes",
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          const SizedBox(height: 5),
          Expanded(
            child: FutureBuilder<List<List<String>>>(
              future: getSlotsSuggestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<List<String>> formattedSlots = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: formattedSlots.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<String> slots = formattedSlots[index];
                      int maxLength = formattedSlots
                          .reduce((a, b) => a.length > b.length ? a : b)
                          .length;

                      double proportion = slots.length / maxLength;
                      Color? expBgColor;

                      if (proportion < 0.5) {
                        expBgColor = Color.lerp(Colors.red[100],
                            Colors.yellow[100], proportion * 2)!;
                      } else {
                        expBgColor = Color.lerp(Colors.yellow[100],
                            Colors.green[100], (proportion - 0.5) * 2)!;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ExpansionTile(
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: expBgColor,
                              collapsedBackgroundColor: expBgColor,
                              trailing: slots.length == 0
                                  ? const Icon(
                                      Icons.expand_more,
                                      color: Colors.transparent,
                                    )
                                  : null,
                              title: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Text(
                                      "${slots.length}",
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                          DateFormat('EEE, dd MMM yyyy').format(
                                              widget.startDate.add(Duration(
                                                  days: index))), // date prop
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                            fontSize: 17,
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: slots.length,
                                  itemBuilder:
                                      (BuildContext context, int innerIndex) {
                                    DateTime currentDate = widget.startDate
                                        .add(Duration(days: index));
                                    DateTime startDateTime = getStartEndTime(
                                        slots[innerIndex],
                                        widget.selectedPeriod,
                                        currentDate)[0];
                                    DateTime endDateTime = getStartEndTime(
                                        slots[innerIndex],
                                        widget.selectedPeriod,
                                        currentDate)[1];
                                    return TimeSlotTile(
                                        startDateTime: startDateTime,
                                        endDateTime: endDateTime,
                                        numAvailable: 5,
                                        numTotal: 5,
                                        handler: () => {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ConfirmGroupEventDialog(
                                                    title:
                                                        'Event: ${widget.eventName}',
                                                    dateString: DateFormat(
                                                            'EEE, dd MMM yyyy')
                                                        .format(startDateTime),
                                                    timeString:
                                                        "${DateFormat('HH:mm').format(startDateTime)} - ${DateFormat('HH:mm').format(endDateTime)}",
                                                    messageBottom:
                                                        "Create the event and send invitation emails to all group members?",
                                                    onCancel: () {
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    },
                                                    onConfirm: () async {
                                                      // Execute your function or API call here
                                                      // ...
                                                      List<String> uids =
                                                          await getUserEmails(
                                                              widget.userIds);
                                                      cal.Event event =
                                                          cal.Event(
                                                        summary:
                                                            widget.eventName,
                                                        description:
                                                            "Group: ${widget.groupName} - Created by SyncUp ;)",
                                                        start: cal.EventDateTime(
                                                            dateTime:
                                                                startDateTime),
                                                        end: cal.EventDateTime(
                                                            dateTime:
                                                                endDateTime),
                                                        attendees: uids
                                                            .map((email) => cal
                                                                .EventAttendee(
                                                                    email:
                                                                        email))
                                                            .toList(),
                                                      );
                                                      event.extendedProperties =
                                                          cal.EventExtendedProperties();
                                                      event.extendedProperties!
                                                          .private = {
                                                        "CREATOR": "SYNCUP",
                                                        "GROUP_NAME":
                                                            widget.groupName,
                                                      };

                                                      Navigator.pop(context);

                                                      createEventAndBackToGroupPage(
                                                          event);
                                                    },
                                                  );
                                                },
                                              )
                                            });
                                  },
                                ),
                              ]),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
