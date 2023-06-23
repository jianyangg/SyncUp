import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String memberPhotoUrl;
  final String memberName;

  const ProfileTile({
    required this.memberPhotoUrl,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.start, // Adjust the alignment as needed
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(memberPhotoUrl),
            radius: 30,
          ),
          SizedBox(height: 6), // Add spacing between the avatar and the text
          Expanded(
            child: Text(
              memberName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
