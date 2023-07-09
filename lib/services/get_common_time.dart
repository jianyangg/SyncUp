import 'package:cloud_firestore/cloud_firestore.dart';

class GetCommonTime {
  static List<List<String>> findCommonBusySlots(
      List<Map<String, List<String>>> availabilityDataList,
      DateTime startDate,
      DateTime endDate) {
    // Find the common free slots among users
    List<List<String>> commonBusySlots = [];

    if (availabilityDataList.isNotEmpty) {
      // Merge availability data
      Map<String, List<String>> mergedAvailabilityData =
          availabilityDataList.reduce((value1, value2) {
        value2.forEach((key, value) {
          value1.update(key, (existingValue) => [...existingValue, ...value],
              ifAbsent: () => value);
        });
        return value1;
      });

      // Filter free slots within the date range
      List<DateTime> datesInRange = [];
      for (DateTime date = startDate;
          date.isBefore(endDate) || date == endDate;
          date = date.add(const Duration(days: 1))) {
        datesInRange.add(date);
      }

      for (DateTime date in datesInRange) {
        // print("date: $date");
        String formattedDate = date.toIso8601String().split('T')[0];
        List<String> freeSlots = [];

        mergedAvailabilityData.forEach((date, eventData) {
          if (date == formattedDate) {
            freeSlots.addAll(eventData);
          }
        });

        commonBusySlots.add(freeSlots);
      }
    }

    // Merge overlapping slots within each day
    for (int i = 0; i < commonBusySlots.length; i++) {
      List<String> slots = commonBusySlots[i];
      slots.sort();

      List<String> mergedSlots = [];
      if (slots.isNotEmpty) {
        String currentSlot = slots.first;
        for (int j = 1; j < slots.length; j++) {
          String nextSlot = slots[j];
          int currentEnd = int.parse(currentSlot.split('-')[1]);
          int nextStart = int.parse(nextSlot.split('-')[0]);

          if (nextStart <= currentEnd) {
            // Merge the slots
            currentSlot =
                '${currentSlot.split('-')[0]}-${nextSlot.split('-')[1]}';
          } else {
            // Add the current slot and update currentSlot to the next slot
            mergedSlots.add(currentSlot);
            currentSlot = nextSlot;
          }
        }
        mergedSlots.add(currentSlot); // Add the last slot
      }

      commonBusySlots[i] = mergedSlots;
    }
    // print("common busy slots: $commonBusySlots");

    return commonBusySlots;
  }

  static List<List<String>> findWorkingHoursFreeSlots(
      List<List<String>> commonBusySlots) {
    // print("input: $commonBusySlots");
    List<List<String>> workingHoursFreeSlots = [];

    // formatting and adding working hours to the free slots
    for (List<String> slots in commonBusySlots) {
      List<String> workingHoursSlots = [];

      if (slots.isNotEmpty) {
        int startHour = 9;
        int startMinute = 0;
        int endHour = 17;
        int endMinute = 0;

        int startMinuteOfDay = startHour * 60 + startMinute;
        int endMinuteOfDay = endHour * 60 + endMinute;

        int previousEndMinute = startMinuteOfDay;

        for (String slot in slots) {
          int slotStartHour = int.parse(slot.split('-')[0].substring(0, 2));
          int slotStartMinute = int.parse(slot.split('-')[0].substring(2));
          int slotStartMinuteOfDay = slotStartHour * 60 + slotStartMinute;

          if (slotStartMinuteOfDay > previousEndMinute) {
            // Add the free slot before the current slot
            String formattedPreviousEndMinute =
                '${(previousEndMinute ~/ 60).toString().padLeft(2, '0')}:${(previousEndMinute % 60).toString().padLeft(2, '0')}';
            String formattedSlotStartHour =
                slotStartHour.toString().padLeft(2, '0');
            String formattedSlotStartMinute =
                slotStartMinute.toString().padLeft(2, '0');
            workingHoursSlots.add(
                '$formattedPreviousEndMinute-$formattedSlotStartHour:$formattedSlotStartMinute');
          }

          int slotEndHour = int.parse(slot.split('-')[1].substring(0, 2));
          int slotEndMinute = int.parse(slot.split('-')[1].substring(2));
          int slotEndMinuteOfDay = slotEndHour * 60 + slotEndMinute;

          previousEndMinute = slotEndMinuteOfDay;
        }

        if (previousEndMinute < endMinuteOfDay) {
          // Add the free slot after the last slot
          String formattedPreviousEndMinute =
              '${(previousEndMinute ~/ 60).toString().padLeft(2, '0')}:${(previousEndMinute % 60).toString().padLeft(2, '0')}';
          String formattedEndHour = endHour.toString().padLeft(2, '0');
          String formattedEndMinute = endMinute.toString().padLeft(2, '0');
          workingHoursSlots.add(
              '$formattedPreviousEndMinute-$formattedEndHour:$formattedEndMinute');
        }
      } else {
        // Add the free slot for the whole day
        int startHour = 9;
        int startMinute = 0;
        int endHour = 17;
        int endMinute = 0;

        String formattedStartHour = startHour.toString().padLeft(2, '0');
        String formattedStartMinute = startMinute.toString().padLeft(2, '0');
        String formattedEndHour = endHour.toString().padLeft(2, '0');
        String formattedEndMinute = endMinute.toString().padLeft(2, '0');

        workingHoursSlots.add(
            '$formattedStartHour:$formattedStartMinute-$formattedEndHour:$formattedEndMinute');
      }

      workingHoursFreeSlots.add(workingHoursSlots);
    }
    // print("output: $workingHoursFreeSlots");
    return workingHoursFreeSlots;
  }

  // Function to find the common free slots among users
  static Future<List<List<String>>> findFreeSlots(
      List<String> userIds, DateTime startDate, DateTime endDate) async {
    List<Map<String, List<String>>> availabilityDataList = [];

    // Retrieve availability data for each user
    for (String userId in userIds) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final availabilityData =
          userDoc.data()?['availability'] as Map<String, dynamic>?;

      if (availabilityData != null) {
        availabilityDataList.add(availabilityData
            .map((key, value) => MapEntry(key, List<String>.from(value))));
      }
    }

    // // of empty array means no events scheduled.
    // print("availabilityDataList: $availabilityDataList");
    // // print truncated output
    // // now don't truncate output
    // for (int i = 0; i < availabilityDataList.length; i++) {
    //   print("availabilityDataList[$i]: ${availabilityDataList[i]}");
    // }

    List<List<String>> commonBusySlots =
        findCommonBusySlots(availabilityDataList, startDate, endDate);

    return findWorkingHoursFreeSlots(commonBusySlots);
  }
}
