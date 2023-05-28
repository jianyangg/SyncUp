import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sync_up/components/time_slot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final List<String> timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  List<List<bool>> containerSelected = List.generate(
    9,
    // TODO: we can vary the number 7 according to the number of days.
    (_) => List<bool>.filled(7, false),
  );

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(seconds: 1));

  int? startIndex;
  int? endIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 63, 63),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        title: const Text("SyncUp"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: DropdownButton(
              icon: const Icon(Icons.menu),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      SizedBox(width: 15),
                      Text("Logout"),
                    ],
                  ),
                ),
              ],
              onChanged: (String? value) {
                if (value == "logout") {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // start and end dates are buttons
                      // when clicked, they will open a date picker calendar
                      // the selected dates will be displayed on the button
                      // the selected start and end dates will be used to determine the number of columns
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 22, 22, 22),
                        ),
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            // firstDate is current year
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(2100),
                          );

                          if (newDate == null) return;

                          // means OK was pressed
                          setState(() {
                            startDate = newDate;
                          });
                        },
                        child: Text(
                            "Start: ${startDate.day}/${startDate.month}/${startDate.year}"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 22, 22, 22),
                        ),
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            // add one day to initial date
                            initialDate: endDate,
                            // firstDate is current year
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(2100),
                          );

                          if (newDate == null) return;

                          // means OK was pressed
                          setState(() {
                            endDate = newDate;
                            final int numDays =
                                endDate.isAtSameMomentAs(startDate)
                                    ? 1
                                    : endDate.difference(startDate).inDays + 2;
                            containerSelected = List.generate(
                                9, (_) => List<bool>.filled(numDays, false));
                          });
                        },
                        // show only date in text button
                        child: Text(
                            "End: ${endDate.day}/${endDate.month}/${endDate.year}"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 750,
                    child: Scrollbar(
                      child: Column(
                        children: [
                          // TODO: this date format is disgusting.
                          // Have it scroll with the gridview
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              endDate.isBefore(startDate)
                                  ? 0
                                  : DateUtils.isSameDay(startDate, endDate)
                                      ? 1
                                      : endDate.difference(startDate).inDays +
                                          2,
                              (index) {
                                final date =
                                    startDate.add(Duration(days: index));
                                return Text(
                                  '${date.day}/${date.month}',
                                  style: TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 9,
                                childAspectRatio: 1 / 1.25,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                              ),
                              // TOOD: there's a bug here. I want there to only be 1 column
                              // if the date is the same and 0 columns if the end date is before the start date
                              itemCount: endDate.isBefore(startDate)
                                  ? 0
                                  : DateUtils.isSameDay(startDate, endDate)
                                      ? 9
                                      : timeSlots.length *
                                          (2 +
                                              endDate
                                                  .difference(startDate)
                                                  .inDays),
                              itemBuilder: (context, index) {
                                // get remainder
                                final rowIndex =
                                    index % containerSelected.length;
                                // get quotient rounded down
                                final columnIndex =
                                    index ~/ containerSelected.length;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      containerSelected[rowIndex][columnIndex] =
                                          !containerSelected[rowIndex]
                                              [columnIndex];
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: containerSelected[rowIndex]
                                              [columnIndex]
                                          ? Colors.green
                                          : Colors.white,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Center(
                                      child: Text(timeSlots[rowIndex]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
