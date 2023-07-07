import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlotTile extends StatelessWidget {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int numAvailable;
  final int numTotal;
  Function() handler;
  TimeSlotTile({
    required this.startDateTime,
    required this.endDateTime,
    required this.numAvailable,
    required this.numTotal,
    required this.handler,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double proportion = numAvailable / numTotal;
    Color? color;

    final ColorTween colorTween = ColorTween(
      begin: Colors.orange.shade200, // Faint Orange
      end: Colors.orange.shade700, // Dark Orange
    );

    color = colorTween.lerp(proportion)!;
    return GestureDetector(
      onTap: handler,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          //  width: SizeConfig.screenWidth * 0.78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey, width: 1.0),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 10),
              Text(
                startDateTime.day.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(width: 25),
              // Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM').format(startDateTime),
                    style: const TextStyle(
                        fontFamily: "Lato",
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${DateFormat('HH:mm').format(startDateTime)} - ${DateFormat('HH:mm').format(endDateTime)}",
                    style: const TextStyle(fontSize: 13, fontFamily: "Lato"),
                  ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: color),
                  child: Text(
                    '$numAvailable/$numTotal',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
