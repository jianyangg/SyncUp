import 'package:flutter/material.dart';

class TimeSlot extends StatefulWidget {
  final String time;

  const TimeSlot({super.key, required this.time});

  @override
  _TimeSlotState createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      onPanStart: (details) {
        setState(() {
          isSelected = !isSelected;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          // Implement logic for drag-to-select
          // You can determine the selected time slots based on the drag gesture.
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(widget.time),
        ),
      ),
    );
  }
}
