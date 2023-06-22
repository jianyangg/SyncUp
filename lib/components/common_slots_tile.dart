import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_up/services/get_common_time.dart';

class CommonSlotsTile extends StatefulWidget {
  final String eventName;
  final int selectedPeriod;
  final String selectedDateRangeText;
  final String groupId;
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
      required this.groupId,
      required this.userIds});

  @override
  State<CommonSlotsTile> createState() => _CommonSlotsTileState();
}

class _CommonSlotsTileState extends State<CommonSlotsTile> {
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

  String formatTimeRange(String startTime, int selectedPeriod) {
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

    return '$formattedStartTime - $formattedEndTime';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Name: ${widget.eventName}",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Duration: ${widget.selectedPeriod}",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Date Range: ${widget.selectedDateRangeText}",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(
                                widget.startDate.add(Duration(days: index))),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (slots.isEmpty)
                            Text(
                              "!! No slots found !!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.red.shade800,
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: slots.length,
                              itemBuilder:
                                  (BuildContext context, int innerIndex) {
                                String slot = slots[innerIndex];
                                return ListTile(
                                  titleAlignment: ListTileTitleAlignment.center,
                                  title: Text(
                                    // I want the text to include the selectedPeriod
                                    // e.g. 09:00 - 09:30
                                    formatTimeRange(
                                        slot, widget.selectedPeriod),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
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
