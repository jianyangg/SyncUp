import 'package:flutter/material.dart';

class ConfirmGroupEventDialog extends StatelessWidget {
  final String title;
  final String dateString;
  final String timeString;
  final String messageBottom;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmGroupEventDialog({
    super.key,
    required this.title,
    required this.dateString,
    required this.timeString,
    required this.messageBottom,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     const Icon(Icons.text_fields),
            //     const SizedBox(width: 8),
            //     Text(
            //       title,
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // Row(
            //   children: [
            //     const Icon(Icons.date_range),
            //     const SizedBox(width: 8),
            //     Text(
            //       "Date: $dateString",
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   children: [
            //     const Icon(Icons.access_time),
            //     const SizedBox(width: 8),
            //     Text(
            //       "Time: $timeString",
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            Text(
              title,
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
              dateString,
              style: const TextStyle(
                fontFamily: "Lato",
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeString,
              style: const TextStyle(
                fontFamily: "Lato",
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              messageBottom,
              style: const TextStyle(
                fontFamily: "Lato",
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  // on press, color should be orange
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                  ),

                  onPressed: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 18,
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const SizedBox(width: 3),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.orange[50],
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 18,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
