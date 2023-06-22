import 'package:cloud_firestore/cloud_firestore.dart';

class GetCommonTime {
  // Function to find the common free slots among users
  static Future<List<List<String>>> findFreeSlots(List<String> userIds,
      DateTime startDate, DateTime endDate, String period) async {
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

    // Find the common free slots among users
    List<List<String>> commonFreeSlots = [];

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
          date.isBefore(endDate);
          date = date.add(Duration(days: 1))) {
        datesInRange.add(date);
      }

      for (DateTime date in datesInRange) {
        String formattedDate = date.toIso8601String().split('T')[0];
        List<String> freeSlots = [];

        mergedAvailabilityData.forEach((date, eventData) {
          if (date == formattedDate) {
            freeSlots.addAll(eventData);
          }
        });

        commonFreeSlots.add(freeSlots);
      }
    }

    // Merge overlapping slots within each day
    for (int i = 0; i < commonFreeSlots.length; i++) {
      List<String> slots = commonFreeSlots[i];
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
                currentSlot.split('-')[0] + '-' + nextSlot.split('-')[1];
          } else {
            // Add the current slot and update currentSlot to the next slot
            mergedSlots.add(currentSlot);
            currentSlot = nextSlot;
          }
        }
        mergedSlots.add(currentSlot); // Add the last slot
      }

      commonFreeSlots[i] = mergedSlots;
    }

    return commonFreeSlots;
  }

  // Function to retrieve user IDs (example implementation)
  static List<String> getUserIds() {
    // Example implementation to retrieve user IDs
    // Modify this method according to your specific logic
    return [
      'KkMnmPrOIJhvNTsLHShrK8KGUOi1',
      'XcZygk9eyMS01aAbC89x88eKv452',
      'ZIYN8Be81af2RNUhaPlrMV2ScyL2',
    ];
  }

  // Example usage of the findFreeSlots() function
  static void exampleUsage(DateTime startDate, DateTime endDate) async {
    print(startDate);
    print(endDate);
    List<String> userIds =
        getUserIds(); // Retrieve user IDs from within the class

    List<List<String>> commonFreeSlots =
        await findFreeSlots(userIds, startDate, endDate, '30');

    List<List<String>> workingHoursFreeSlots = [];

    for (List<String> slots in commonFreeSlots) {
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
                '${slotStartHour.toString().padLeft(2, '0')}';
            String formattedSlotStartMinute =
                '${slotStartMinute.toString().padLeft(2, '0')}';
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
          String formattedEndHour = '${endHour.toString().padLeft(2, '0')}';
          String formattedEndMinute = '${endMinute.toString().padLeft(2, '0')}';
          workingHoursSlots.add(
              '$formattedPreviousEndMinute-$formattedEndHour:$formattedEndMinute');
        }
      }

      workingHoursFreeSlots.add(workingHoursSlots);
    }
    print(workingHoursFreeSlots);
  }
}

void main() {
  GetCommonTime.exampleUsage(
      DateTime.now(), DateTime.now().add(Duration(days: 7)));
}
