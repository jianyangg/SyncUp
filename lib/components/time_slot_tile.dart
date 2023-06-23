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

    // if (proportion < 0.5) {
    //   color = Color.lerp(Colors.red, Colors.yellow, proportion * 2)!;
    // } else {
    //   color = Color.lerp(Colors.yellow, Colors.green, (proportion - 0.5) * 2)!;
    // }
    // int shade = 230;

    // if (proportion < 0.5) {
    //   color = Color.lerp(Color.fromARGB(shade, 219, 68, 55),
    //       Color.fromARGB(shade, 244, 180, 0), proportion * 2)!;
    // } else {
    //   color = Color.lerp(Color.fromARGB(shade, 244, 180, 0),
    //       Color.fromARGB(shade, 15, 157, 88), (proportion - 0.5) * 2)!;
    // }
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
          child: Row(children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    startDateTime.day.toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(width: 20),
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
                        style:
                            const TextStyle(fontSize: 13, fontFamily: "Lato"),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: color),
                              child: Text('$numAvailable/$numTotal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54)))))
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
