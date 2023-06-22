import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color color;
  const BottomNavBar(this.currentIndex, this.onTap,
      {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return DotNavigationBar(
      backgroundColor: color,
      enableFloatingNavBar: true,
      margin: const EdgeInsets.only(left: 10, right: 10),
      currentIndex: currentIndex,
      dotIndicatorColor: Colors.white,
      unselectedItemColor: Colors.grey[350],
      // enableFloatingNavBar: false,
      onTap: onTap,
      items: [
        /// Home
        DotNavigationBarItem(
          icon: const Icon(Icons.home),
          selectedColor: Colors.white,
        ),

        /// Likes
        DotNavigationBarItem(
          icon: const Icon(Icons.calendar_month),
          selectedColor: Colors.white,
        ),

        /// Search
        DotNavigationBarItem(
          icon: const Icon(Icons.group),
          selectedColor: Colors.white,
        ),

        /// Profile
        DotNavigationBarItem(
          icon: const Icon(Icons.person),
          selectedColor: Colors.white,
        ),
      ],
    );
  }
}
