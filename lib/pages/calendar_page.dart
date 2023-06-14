import "package:flutter/material.dart";
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sync_up/pages/group_page.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:sync_up/pages/account_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum _SelectedTab { home, calendar, group, account }

class _CalendarPageState extends State<CalendarPage> {
  var _selectedTab = _SelectedTab.calendar;

  Color hexToColor(String code) {
    return Color(int.parse(
            code.substring(0, 2) + code.substring(2, 4) + code.substring(4, 6),
            radix: 16) +
        0xFF000000);
  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const HomePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const CalendarPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const GroupPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const AccountPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  String _getMonthAbbreviation(int month) {
    List<String> monthAbbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthAbbreviations[month - 1];
  }

  String _getWeekdayAbbreviation(int weekday) {
    List<String> weekdayAbbreviations = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekdayAbbreviations[weekday - 1];
  }

  DateTime? selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade800,
        shadowColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Your Events",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.sync),
          // ),
          TextButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                // backgroundColor: Color.fromARGB(255, 189, 255, 144),
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue.shade700),
                ),
                onPressed: () {},
                child: const Text(
                  "Groups",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
                child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 365,
                    itemBuilder: (context, index) {
                      DateTime date = DateTime.now();
                      bool isSelected = date.add(Duration(days: index)).day ==
                          selectedDate?.day;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date.add(Duration(days: index));
                            // selectedDate = date;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Container(
                            width: 45,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 7),
                                Text(
                                    _getWeekdayAbbreviation(date
                                        .add(Duration(days: index))
                                        .weekday),
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[400],
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12)),
                                Text(
                                  '${date.add(Duration(days: index)).day}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getMonthAbbreviation(
                                      date.add(Duration(days: index)).month),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DotNavigationBar(
        backgroundColor: Colors.blue.shade800,
        enableFloatingNavBar: true,
        margin: const EdgeInsets.only(left: 10, right: 10),
        currentIndex: _SelectedTab.values.indexOf(_selectedTab),
        dotIndicatorColor: Colors.white,
        unselectedItemColor: Colors.grey[350],
        // enableFloatingNavBar: false,
        onTap: _handleIndexChanged,
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
      ),
    );
  }
}
