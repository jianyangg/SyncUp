import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:sync_up/pages/own_event_page.dart';
import 'package:sync_up/pages/group_page.dart';
import '../components/bottom_nav_bar.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:sync_up/services/sync_calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

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

  Color hexToColor(String code) {
    return Color(int.parse(
            code.substring(0, 2) + code.substring(2, 4) + code.substring(4, 6),
            radix: 16) +
        0xFF000000);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkAllRequests() async {
    // check all groups owned by the user
    // if there is any request, return true
    // else return false
    final QuerySnapshot<Map<String, dynamic>> groups = await _firestore
        .collection('groups')
        .where('owner', isEqualTo: _auth.currentUser!.uid)
        .get();
    // // display groups for debugging
    // for (final QueryDocumentSnapshot<Map<String, dynamic>> group
    //     in groups.docs) {
    //   print(group.id);
    // }
    for (final QueryDocumentSnapshot<Map<String, dynamic>> group
        in groups.docs) {
      final Map<String, dynamic> data = group.data();
      final List<dynamic> requests = data['requests'];
      if (requests.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // distance between each Connect! button
  final double _buttonDistance = 15.0;

  GoogleSignInAccount? _currentUser;
  late DateTime dateTodayFormatted;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    dateTodayFormatted = DateTime(now.year, now.month, now.day);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        SyncCalendar.syncCalendarByDay(dateTodayFormatted, _googleSignIn);
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    String username = _auth.currentUser!.displayName.toString();
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              "Hello, $username",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            // TODO: display notification page
            onPressed: () {},
            icon: FutureBuilder<bool>(
              future: checkAllRequests(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return const Icon(
                    Icons.notifications_active_sharp,
                    color: Colors.red,
                  );
                } else {
                  return const Icon(Icons.notifications, color: Colors.white);
                }
              },
            ),
          ),
          // User shoudl go to group to create event.
          // we can add an additional feature to shortcut this using the add button in future versions
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {},
          // ),
          const SizedBox(
            width: 15,
          )
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
      bottomNavigationBar: BottomNavBar(
        _SelectedTab.values.indexOf(_selectedTab),
        _handleIndexChanged,
        color: Colors.blue.shade700,
      ),
    );
  }
}

enum _SelectedTab { home, calendar, group, account }
