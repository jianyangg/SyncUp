import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmGroupEventDialog extends StatelessWidget {
  final String title;
  final String dateString;
  final String timeString;
  final String messageBottom;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  ConfirmGroupEventDialog({
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
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.date_range),
                SizedBox(width: 8),
                Text(
                  "Date: ${dateString}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 8),
                Text(
                  "Time: ${timeString}",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              messageBottom,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: onCancel,
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange[50],
                    elevation: 0,
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
