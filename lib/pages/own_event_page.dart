import "package:flutter/material.dart";
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:sync_up/components/calendar_scroll.dart';
import 'package:sync_up/pages/group_page.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:sync_up/pages/account_page.dart';

class OwnEventPage extends StatefulWidget {
  const OwnEventPage({super.key});

  @override
  State<OwnEventPage> createState() => _OwnEventPageState();
}

enum _SelectedTab { home, calendar, group, account }

class _OwnEventPageState extends State<OwnEventPage> {
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
                const OwnEventPage(),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const GroupPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
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
              SizedBox(height: 10),
              CalendarScroll(color: Colors.blue.shade700),
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    "Time",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color.fromARGB(143, 158, 158, 158),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  const Text(
                    'Event',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color.fromARGB(143, 158, 158, 158),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sort,
                      color: Color.fromARGB(143, 158, 158, 158),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    // for time
                    const Column(
                      children: [
                        Text(
                          "11:35",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "12:00",
                          style: TextStyle(
                            color: Color.fromARGB(143, 158, 158, 158),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // for divider
                    const VerticalDivider(
                      color: Color.fromARGB(71, 158, 158, 158),
                      thickness: 2.5,
                    ),
                    const SizedBox(width: 10),
                    // for event
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width * 0.68,
                          decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              'MA2001 Group Meeeting',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
