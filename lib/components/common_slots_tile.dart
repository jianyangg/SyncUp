import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:sync_up/components/confirm_group_event_dialog.dart';
import 'package:sync_up/components/time_slot_tile.dart';
import 'package:sync_up/services/get_common_time.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:sync_up/services/sync_calendar.dart';
import '../pages/group_events_page.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

List<List<String>> getSlotsSuggestionsHelper(
    List<List<String>> workingHourFreeSlots,
    DateTime startDate,
    int selectedPeriod,
    DateTime now) {
  List<List<String>> slicedFreeSlots = [];
  int countDays = 0;
  for (List<String> day in workingHourFreeSlots) {
    List<String> slicedDay = [];
    DateTime currentDay = startDate.add(Duration(days: countDays));
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
        startTime = startTime.add(Duration(minutes: selectedPeriod));
      }
    }
    slicedFreeSlots.add(slicedDay);
  }
  // print("slicedFreeSlots: $slicedFreeSlots");
  List<List<String>> formattedSlots = [];

  for (var slots in slicedFreeSlots) {
    List<String> formattedList = [];

    for (var slot in slots) {
      DateTime dateTime = DateTime.parse(slot);

      DateTime endTime = dateTime.add(Duration(minutes: selectedPeriod));

      if (endTime.hour > 17 || (endTime.hour == 17 && endTime.minute > 0)) {
        continue; // Skip the slot if it goes past 17:00
      } else {
        String formattedTime =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        formattedList.add(formattedTime);
      }
    }

    formattedSlots.add(formattedList);
  }

  // Modify the first row (representing the current day) to only show timings after the current time
  // this is only if the startDate has the same date as today
  if (startDate.year == DateTime.now().year &&
      startDate.month == DateTime.now().month &&
      startDate.day == DateTime.now().day) {
    List<String> firstRow = formattedSlots[0];
    List<String> modifiedFirstRow = [];
    for (String time in firstRow) {
      List<String> timeSplit = time.split(':');
      int hour = int.parse(timeSplit[0]);
      int minute = int.parse(timeSplit[1]);
      if (hour > now.hour) {
        modifiedFirstRow.add(time);
      } else if (hour == now.hour && minute > now.minute) {
        modifiedFirstRow.add(time);
      }
    }
    formattedSlots[0] = modifiedFirstRow;
  }
  // List<String> firstRow = formattedSlots[0];
  // List<String> modifiedFirstRow = [];
  // for (String time in firstRow) {
  //   List<String> timeSplit = time.split(':');
  //   int hour = int.parse(timeSplit[0]);
  //   int minute = int.parse(timeSplit[1]);
  //   if (hour > now.hour) {
  //     modifiedFirstRow.add(time);
  //   } else if (hour == now.hour && minute > now.minute) {
  //     modifiedFirstRow.add(time);
  //   }
  // }
  // formattedSlots[0] = modifiedFirstRow;
  // print("formattedSlotsFinal: $formattedSlots");
  return formattedSlots;
}

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
  final int memberCount;

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
      required this.userIds,
      required this.memberCount});

  @override
  State<CommonSlotsTile> createState() => _CommonSlotsTileState();
}

class _CommonSlotsTileState extends State<CommonSlotsTile> {
  final firestore = FirebaseFirestore.instance;

  GoogleSignInAccount? _currentUser;
  late DateTime selectedDate;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();

    now = DateTime.now();
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
    // print(workingHourFreeSlots);
    // print(getSlotsSuggestionsHelper(
    //     workingHourFreeSlots, widget.startDate, widget.selectedPeriod, now));
    return getSlotsSuggestionsHelper(
        workingHourFreeSlots, widget.startDate, widget.selectedPeriod, now);
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

    // temporary fix
    // if endDateTime is past working hours, remove current entry

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
          // freshEventDate: event.start!.dateTime!,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    SyncCalendar.syncCalendarByDay(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      _googleSignIn,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 75,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventName,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // <Day>, <Date>
                    // from <startTime>PM to <endTime>PM
                    Text(
                      widget.selectedDateRangeText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.selectedPeriod.toString()} minutes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: FutureBuilder<List<List<String>>>(
                  future: getSlotsSuggestions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<List<String>> formattedSlots = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: formattedSlots.length,
                        itemBuilder: (BuildContext context, int index) {
                          List<String> slots = formattedSlots[index];
                          int maxLength = formattedSlots
                              .reduce((a, b) => a.length > b.length ? a : b)
                              .length;

                          maxLength = maxLength == 0 ? 1 : maxLength;
                          double proportion = slots.length / maxLength;
                          // print('slots length: ${slots.length}');
                          // print('max length: $maxLength');
                          Color? expBgColor;
                          final ColorTween colorTween = ColorTween(
                            begin: Colors.orange.shade200, // Faint Orange
                            end: Colors.orange.shade700, // Dark Orange
                          );

                          expBgColor = colorTween.lerp(proportion)!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ExpansionTile(
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  backgroundColor: expBgColor,
                                  collapsedBackgroundColor: expBgColor,
                                  textColor: Colors.white,
                                  iconColor: Colors.white,
                                  trailing: slots.isEmpty
                                      ? const Icon(
                                          Icons.expand_more,
                                          color: Colors.transparent,
                                        )
                                      : null,
                                  title: Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "${slots.length}",
                                          style: const TextStyle(
                                            fontFamily: "Lato",
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                              DateFormat('EEE, dd MMM yyyy').format(
                                                  widget.startDate.add(Duration(
                                                      days:
                                                          index))), // date prop
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: slots.length,
                                      itemBuilder: (BuildContext context,
                                          int innerIndex) {
                                        DateTime currentDate = widget.startDate
                                            .add(Duration(days: index));
                                        DateTime startDateTime =
                                            getStartEndTime(
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
                                            numAvailable: widget.userIds.length,
                                            numTotal: widget.memberCount,
                                            handler: () => {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ConfirmGroupEventDialog(
                                                        title:
                                                            // 'Event: ${widget.eventName}',
                                                            widget.eventName,
                                                        dateString: DateFormat(
                                                                'EEE, dd MMM yyyy')
                                                            .format(
                                                                startDateTime),
                                                        timeString:
                                                            "${DateFormat('HH:mm').format(startDateTime)} - ${DateFormat('HH:mm').format(endDateTime)}",
                                                        messageBottom:
                                                            "Create the event and send invitation emails to all group members?",
                                                        onCancel: () {
                                                          // clear
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                        },
                                                        onConfirm: () async {
                                                          // Execute your function or API call here
                                                          // ...
                                                          List<String> uids =
                                                              await getUserEmails(
                                                                  widget
                                                                      .userIds);
                                                          cal.Event event =
                                                              cal.Event(
                                                            summary: widget
                                                                .eventName,
                                                            description:
                                                                "Group: ${widget.groupName} - Created by SyncUp ;)",
                                                            start: cal
                                                                .EventDateTime(
                                                                    dateTime:
                                                                        startDateTime),
                                                            end: cal.EventDateTime(
                                                                dateTime:
                                                                    endDateTime),
                                                            attendees: uids
                                                                .map((email) =>
                                                                    cal.EventAttendee(
                                                                        email:
                                                                            email))
                                                                .toList(),
                                                          );
                                                          event.extendedProperties =
                                                              cal.EventExtendedProperties();
                                                          event
                                                              .extendedProperties!
                                                              .shared = {
                                                            "CREATOR": "SYNCUP",
                                                            "GROUP_NAME": widget
                                                                .groupName,
                                                          };

                                                          Navigator.pop(
                                                              context);

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
                              const SizedBox(height: 5),
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
        ),
      ),
    );
  }
}
