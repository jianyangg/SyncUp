import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/services/get_common_time.dart';

class CommonSlotsTile extends StatefulWidget {
  final String eventName;
  final String selectedPeriod;
  final String selectedDateRangeText;
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;
  const CommonSlotsTile(
      {super.key,
      required this.eventName,
      required this.selectedPeriod,
      required this.selectedDateRangeText,
      required this.startDate,
      required this.endDate,
      required this.groupId});

  @override
  State<CommonSlotsTile> createState() => _CommonSlotsTileState();
}

class _CommonSlotsTileState extends State<CommonSlotsTile> {
  // retrieve userIDs from groupID
  final _firestore = FirebaseFirestore.instance;
  List<String> userIDs = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event Name: ${widget.eventName}",
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text("Duration: ${widget.selectedPeriod}",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          "Date Range: ${widget.selectedDateRangeText}",
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        // create a list view common time slots
        // where each tile represents one element in the List<String> from GetCommonTime.findFreeSlots() function.
        // use a test button for now
        Center(
          child: IconButton(
            icon: const Icon(Icons.type_specimen_sharp),
            color: Colors.black,
            iconSize: 50,
            alignment: Alignment.center,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
            ),
            onPressed: () {
              GetCommonTime.exampleUsage(widget.startDate, widget.endDate);
            },
          ),
        ),
      ],
    );
  }
}
