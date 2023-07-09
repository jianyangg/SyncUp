import 'package:flutter_test/flutter_test.dart';
import 'package:sync_up/components/common_slots_tile.dart'; // Replace with the actual file containing the function
import 'package:sync_up/services/get_common_time.dart';

void main() {
  // Test the function finds common busy slots, in a group with only one user.
  test(
      'Takes in the individual availability of each user, and outputs the combined busy slots',
      () {
    // Inputs passes in the free slots that are within working hours
    // each entry in the dataList is the availability data of a user
    final List<Map<String, List<String>>> availabilityDataList = [
      {
        "2023-07-09": [],
        "2023-07-10": ["1130-1230"],
        "2023-07-11": ["1400-1500"],
        "2023-07-12": ["1500-1600"],
        "2023-07-13": [],
        "2023-07-14": ["1230-1330", "1500-1600"],
        "2023-07-15": [],
        "2023-07-16": [],
        "2023-07-17": ["1330-1430"],
        "2023-07-18": [],
        "2023-07-19": [],
        "2023-07-20": [],
        "2023-07-21": [],
        "2023-07-22": [],
        "2023-07-23": [],
        "2023-07-24": [],
        "2023-07-25": [],
        "2023-07-26": [],
        "2023-07-27": [],
        "2023-07-28": [],
        "2023-07-29": [],
        "2023-07-30": [],
        "2023-07-31": [],
        "2023-08-01": [],
        "2023-08-02": [],
        "2023-08-03": [],
        "2023-08-04": [],
        "2023-08-05": [],
        "2023-08-06": [],
        "2023-08-07": [],
        "2023-08-08": [],
      },
    ];

    // Range is within the start and end date; hence less entries in the list
    List<List<String>> expectedCommonBusySlots = [
      [],
      ["1130-1230"],
      ["1400-1500"],
      ["1500-1600"],
      [],
      ["1230-1330", "1500-1600"],
      [],
      []
    ];

    // Call the function to get the actual output
    // Time means 9th July 2023, 0.00am
    final startDate = DateTime(2023, 7, 9, 00, 00, 0);
    final endDate = DateTime(2023, 7, 16, 23, 59, 59);
    final actualCommonBusySlots = GetCommonTime.findCommonBusySlots(
        availabilityDataList, startDate, endDate);

    // Verify that the actual output matches the expected output
    expect(actualCommonBusySlots, expectedCommonBusySlots);
  });

  // Test the function finds common busy slots, in a group with two users.
  test(
      'Takes in the individual availability of each user, and outputs the combined busy slots',
      () {
    // Inputs passes in the free slots that are within working hours
    // each entry in the dataList is the availability data of a user
    final List<Map<String, List<String>>> availabilityDataList = [
      {
        "2023-07-09": [],
        "2023-07-10": ["1130-1230"],
        "2023-07-11": ["1400-1500"],
        "2023-07-12": ["1500-1600"],
        "2023-07-13": [],
        "2023-07-14": ["1230-1330", "1500-1600"],
        "2023-07-15": [],
        "2023-07-16": [],
        "2023-07-17": ["1330-1430"],
        "2023-07-18": [],
        "2023-07-19": [],
        "2023-07-20": [],
        "2023-07-21": [],
        "2023-07-22": [],
        "2023-07-23": [],
        "2023-07-24": [],
        "2023-07-25": [],
        "2023-07-26": [],
        "2023-07-27": [],
        "2023-07-28": [],
        "2023-07-29": [],
        "2023-07-30": [],
        "2023-07-31": [],
        "2023-08-01": [],
        "2023-08-02": [],
        "2023-08-03": [],
        "2023-08-04": [],
        "2023-08-05": [],
        "2023-08-06": [],
        "2023-08-07": [],
        "2023-08-08": [],
      },
      {
        "2023-07-09": [],
        "2023-07-10": ["1100-1200"],
        "2023-07-11": ["1430-1530"],
        "2023-07-12": ["1600-1700"],
        "2023-07-13": [],
        "2023-07-14": ["1200-1300"],
        "2023-07-15": [],
        "2023-07-16": [],
        "2023-07-17": ["0615-1245", "0000-2359"],
        "2023-07-18": ["0000-2359"],
        "2023-07-19": ["0000-2359"],
        "2023-07-20": [],
        "2023-07-21": [],
        "2023-07-22": ["0000-2359"],
        "2023-07-23": ["0000-2359", "0000-2359"],
        "2023-07-24": ["0000-2359", "1900-2050", "0000-2359"],
        "2023-07-25": ["0000-2359"],
        "2023-07-26": ["0000-2359"],
        "2023-07-27": ["1805-2235", "2340-0420", "0000-2359"],
        "2023-07-28": ["2340-0420"],
        "2023-07-29": [],
        "2023-07-30": [],
        "2023-07-31": [],
        "2023-08-01": [],
        "2023-08-02": [],
        "2023-08-03": [],
        "2023-08-04": [],
        "2023-08-05": [],
        "2023-08-06": [],
        "2023-08-07": [],
        "2023-08-08": [],
      },
    ];

    // Range is within the start and end date
    List<List<String>> expectedCommonBusySlots = [
      [], // No common busy slots on index 0
      ["1100-1230"], // Common busy slots on index 1
      ["1400-1530"], // Common busy slots on index 2
      ["1500-1700"], // Common busy slots on index 3
      [], // No common busy slots on index 4
      ["1200-1330", "1500-1600"], // Common busy slots on index 5
      [], // No common busy slots on index 6
      [] // No common busy slots on index 7
    ];

    // Call the function to get the actual output
    // Time means 9th July 2023, 3.30pm
    final startDate = DateTime(2023, 7, 9, 00, 00, 0);
    final endDate = DateTime(2023, 7, 16, 23, 59, 59);
    final actualCommonBusySlots = GetCommonTime.findCommonBusySlots(
        availabilityDataList, startDate, endDate);

    // Verify that the actual output matches the expected output
    expect(actualCommonBusySlots, expectedCommonBusySlots);
  });

  // Test the function that finds the combined workingHoursFreeSlots from the commonBusySlots
  test(
      'Takes in the combined free slots within working hours, and outputs the suggested slots for each day',
      () {
    // Inputs passes in the commonBusySlots
    final List<List<String>> commonBusySlots = [
      [],
      ["1130-1230"],
      ["1400-1500"],
      ["1500-1600"],
      [],
      ["1230-1330", "1500-1600"],
      [],
      []
    ];

    // Expected output slots suggestions; this isn't split up by the selected period yet.
    final expectedWorkingHoursFreeSlots = [
      ["09:00-17:00"],
      ["09:00-11:30", "12:30-17:00"],
      ["09:00-14:00", "15:00-17:00"],
      ["09:00-15:00", "16:00-17:00"],
      ["09:00-17:00"],
      ["09:00-12:30", "13:30-15:00", "16:00-17:00"],
      ["09:00-17:00"],
      ["09:00-17:00"]
    ];

    final actualWorkingHoursFreeSlots =
        GetCommonTime.findWorkingHoursFreeSlots(commonBusySlots);

    // Verify that the actual output matches the expected output
    expect(actualWorkingHoursFreeSlots, expectedWorkingHoursFreeSlots);
  });

  // Test the function that returns the suggested slots for each day from the combined workingHoursFreeSlots
  // using the selected period
  test(
      'Takes in the combined free slots within working hours, and outputs the suggested slots for each day',
      () {
    // Inputs passes in the free slots that are within working hours
    final workingHoursFreeSlots = [
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00'],
      ['09:00-17:00']
    ];

    // Expected output slots suggestions
    final expectedSlotsSuggestions = [
      [],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00'],
      ['09:00', '10:30', '12:00', '13:30', '15:00']
    ];

    // Call the function to get the actual output
    // Time means 9th July 2023, 3.30pm
    final fixedTimestamp = DateTime(2023, 7, 9, 15, 30, 0);
    const selectedPeriod = 90;
    final actualSlotsSuggestions = getSlotsSuggestionsHelper(
        workingHoursFreeSlots, fixedTimestamp, selectedPeriod, fixedTimestamp);

    // Verify that the actual output matches the expected output
    expect(actualSlotsSuggestions, expectedSlotsSuggestions);
  });
}
