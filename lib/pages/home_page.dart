import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:sync_up/pages/calendar_page.dart';
import 'package:sync_up/pages/group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  var _selectedTab = _SelectedTab.home;

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
      // TODO: fix the case 1 and 2 once Calendar and Database pages are done.
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

  Color hexToColor(String code) {
    return Color(int.parse(
            code.substring(0, 2) + code.substring(2, 4) + code.substring(4, 6),
            radix: 16) +
        0xFF000000);
  }

  // distance between each Connect! button
  final double _buttonDistance = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Hello, usr_admin",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            )),
        backgroundColor: Colors.blue.shade800,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          constraints: const BoxConstraints(maxHeight: double.infinity),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 0, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big coloured button with text "Create new event"
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      ),
                      child: const Center(
                        child: Text(
                          "New Event",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Academic Database
                  const Text(
                    "Academic Database",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text('Cheatsheets, upcoming assignments and more!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: hexToColor('56D6D5'),
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Computing",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: hexToColor('FFC278'),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Business",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.yellow,
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Mathematics",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Connect!
                  const Text(
                    "Connect!",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Find your classmates and connect with them!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // Horizontal Scrollable containers using list view
                  SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.amber,
                          ),
                          width: 90,
                          alignment: Alignment.center,
                          child: const Text(
                            "Robotic Rookies",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.lightGreen,
                          ),
                          width: 90,
                          child: const Center(
                            child: Text(
                              "NOC\nNorway",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.purple,
                          ),
                          width: 90,
                          child: const Center(
                            child: Text(
                              "Gym\nKFC\nBuddies",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrange,
                          ),
                          width: 90,
                          child: const Center(
                            child: Text(
                              "Gym\nKFC\nBuddies",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          width: 90,
                          child: const Center(
                            child: Text(
                              "Gym\nKFC\nBuddies",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Provide Feedback",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text('Let us know how we can improve!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: hexToColor('FF7648'),
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Scheduling",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: hexToColor('182A88'),
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Database",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.yellow,
                          ),
                          width: 140,
                          child: const Center(
                            child: Text(
                              "Bugs",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

enum _SelectedTab { home, calendar, group, account }

// import 'dart:math';

// import 'package:dot_navigation_bar/dot_navigation_bar.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:sync_up/components/time_slot.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomeState();
// }

// class _HomeState extends State<HomePage> {
//   final user = FirebaseAuth.instance.currentUser;
//   final List<String> timeSlots = [
//     '9:00 AM',
//     '10:00 AM',
//     '11:00 AM',
//     '12:00 PM',
//     '1:00 PM',
//     '2:00 PM',
//     '3:00 PM',
//     '4:00 PM',
//     '5:00 PM',
//   ];

//   List<List<bool>> containerSelected = List.generate(
//     9,
//     // TODO: we can vary the number 7 according to the number of days.
//     (_) => List<bool>.filled(7, false),
//   );

//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(const Duration(seconds: 1));

//   int? startIndex;
//   int? endIndex;

//   var _selectedTab = _SelectedTab.home;

//   void _handleIndexChanged(int i) {
//     setState(() {
//       _selectedTab = _SelectedTab.values[i];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 63, 63, 63),
//       extendBody: true,
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.only(bottom: 10.0),
//         child: DotNavigationBar(
//           margin: EdgeInsets.only(left: 10, right: 10),
//           onTap: _handleSe,
//           items: [
//             DotNavigationBarItem(
//               icon: const Icon(Icons.home),
//               selectedColor: Colors.black,
//             ),
//             DotNavigationBarItem(
//               icon: const Icon(Icons.calendar_today),
//               selectedColor: Colors.black,
//             ),
//             DotNavigationBarItem(
//               icon: const Icon(Icons.person),
//               selectedColor: Colors.black,
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 22, 22, 22),
//         title: const Text("SyncUp"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: DropdownButton(
//               icon: const Icon(Icons.menu),
//               underline: const SizedBox(),
//               items: const [
//                 DropdownMenuItem(
//                   value: "logout",
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.logout,
//                         color: Colors.black,
//                       ),
//                       SizedBox(width: 15),
//                       Text("Logout"),
//                     ],
//                   ),
//                 ),
//               ],
//               onChanged: (String? value) {
//                 if (value == "logout") {
//                   FirebaseAuth.instance.signOut();
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Scrollbar(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // start and end dates are buttons
//                       // when clicked, they will open a date picker calendar
//                       // the selected dates will be displayed on the button
//                       // the selected start and end dates will be used to determine the number of columns
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor:
//                               const Color.fromARGB(255, 22, 22, 22),
//                         ),
//                         onPressed: () async {
//                           DateTime? newDate = await showDatePicker(
//                             context: context,
//                             initialDate: startDate,
//                             // firstDate is current year
//                             firstDate: DateTime(DateTime.now().year),
//                             lastDate: DateTime(2100),
//                           );

//                           if (newDate == null) return;

//                           // means OK was pressed
//                           setState(() {
//                             startDate = newDate;
//                           });
//                         },
//                         child: Text(
//                             "Start: ${startDate.day}/${startDate.month}/${startDate.year}"),
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           backgroundColor:
//                               const Color.fromARGB(255, 22, 22, 22),
//                         ),
//                         onPressed: () async {
//                           DateTime? newDate = await showDatePicker(
//                             context: context,
//                             // add one day to initial date
//                             initialDate: endDate,
//                             // firstDate is current year
//                             firstDate: DateTime(DateTime.now().year),
//                             lastDate: DateTime(2100),
//                           );

//                           if (newDate == null) return;

//                           // means OK was pressed
//                           setState(() {
//                             endDate = newDate;
//                             final int numDays =
//                                 endDate.isAtSameMomentAs(startDate)
//                                     ? 1
//                                     : endDate.difference(startDate).inDays + 2;
//                             containerSelected = List.generate(
//                                 9, (_) => List<bool>.filled(numDays, false));
//                           });
//                         },
//                         // show only date in text button
//                         child: Text(
//                             "End: ${endDate.day}/${endDate.month}/${endDate.year}"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 750,
//                     child: Scrollbar(
//                       child: Column(
//                         children: [
//                           // TODO: this date format is disgusting.
//                           // Have it scroll with the gridview
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: List.generate(
//                               endDate.isBefore(startDate)
//                                   ? 0
//                                   : DateUtils.isSameDay(startDate, endDate)
//                                       ? 1
//                                       : endDate.difference(startDate).inDays +
//                                           2,
//                               (index) {
//                                 final date =
//                                     startDate.add(Duration(days: index));
//                                 return Text(
//                                   '${date.day}/${date.month}',
//                                   style: TextStyle(color: Colors.white),
//                                 );
//                               },
//                             ),
//                           ),
//                           Expanded(
//                             child: GridView.builder(
//                               scrollDirection: Axis.horizontal,
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 9,
//                                 childAspectRatio: 1 / 1.25,
//                                 crossAxisSpacing: 5,
//                                 mainAxisSpacing: 5,
//                               ),
//                               // TOOD: there's a bug here. I want there to only be 1 column
//                               // if the date is the same and 0 columns if the end date is before the start date
//                               itemCount: endDate.isBefore(startDate)
//                                   ? 0
//                                   : DateUtils.isSameDay(startDate, endDate)
//                                       ? 9
//                                       : timeSlots.length *
//                                           (2 +
//                                               endDate
//                                                   .difference(startDate)
//                                                   .inDays),
//                               itemBuilder: (context, index) {
//                                 // get remainder
//                                 final rowIndex =
//                                     index % containerSelected.length;
//                                 // get quotient rounded down
//                                 final columnIndex =
//                                     index ~/ containerSelected.length;
//                                 return GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       containerSelected[rowIndex][columnIndex] =
//                                           !containerSelected[rowIndex]
//                                               [columnIndex];
//                                     });
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: containerSelected[rowIndex]
//                                               [columnIndex]
//                                           ? Colors.green
//                                           : Colors.white,
//                                       border: Border.all(color: Colors.grey),
//                                     ),
//                                     child: Center(
//                                       child: Text(timeSlots[rowIndex]),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
