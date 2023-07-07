import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:sync_up/pages/faculty_materials.dart';
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
  TextEditingController _feedbackController = TextEditingController();
  late Future<List<String>> _folders;
  // late Future<List<String>> _groupIds;
  // late Future<List<String>> _groupNames;
  late Future<Map<String, String>> _groupIdToNameMap;
  // late Future<List<String>> _groupNames;

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
  final double? feedbackButtonHeight = 130;
  final double? feedbackButtonWidth = 150;

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

    _folders = FirebaseStorage.instance
        .ref()
        .child('/academicDatabase/')
        .listAll()
        .then(
            (result) => result.prefixes.map((prefix) => prefix.name).toList());

    _groupIdToNameMap = _firestore.collection('/groups/').get().then((value) {
      // List<String> groupIds = [];
      Map<String, String> groupIdToNameMap = {};
      for (final QueryDocumentSnapshot<Map<String, dynamic>> group
          in value.docs) {
        // groupIds.add(group.id);
        groupIdToNameMap[group.id] = group['name'];
      }
      return groupIdToNameMap;
    });

    DateTime now = DateTime.now();
    dateTodayFormatted = DateTime(now.year, now.month, now.day);
    _googleSignIn.onCurrentUserChanged.listen(
      (GoogleSignInAccount? account) {
        setState(() {
          _currentUser = account;
        });
        if (_currentUser != null) {
          SyncCalendar.syncCalendarByDay(
              dateTodayFormatted, _googleSignIn, context);
        }
      },
    );
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
          // IconButton(
          //   // TODO: display notification page
          //   onPressed: () {},
          //   icon: FutureBuilder<bool>(
          //     future: checkAllRequests(),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData && snapshot.data == true) {
          //         return const Icon(
          //           Icons.notifications_active_sharp,
          //           color: Colors.red,
          //         );
          //       } else {
          //         return const Icon(Icons.notifications, color: Colors.white);
          //       }
          //     },
          //   ),
          // ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              SyncCalendar.syncCalendarByDay(
                  dateTodayFormatted, _googleSignIn, context);
            },
          ),
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
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      "Academic Database",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text('Cheatsheets, upcoming assignments and more!',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 30,
                  ),
                  FutureBuilder<List<String>>(
                    future: _folders,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data!.map((folder) {
                              Color randomColor = Colors.primaries[
                                  Random().nextInt(Colors.primaries.length)];
                              return Row(
                                children: [
                                  SizedBox(width: _buttonDistance),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FacultyMaterials(
                                                  folderName: folder),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: randomColor,
                                      ),
                                      width: 170,
                                      child: Center(
                                        child: Text(
                                          folder,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Connect!
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      "Connect!",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      'Find your classmates and connect with them!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  FutureBuilder<Map<String, String>>(
                    future: _groupIdToNameMap,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        Map<String, String>? data = snapshot.data;
                        if (data != null) {
                          return SizedBox(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: data.entries.map((entry) {
                                String groupName = entry.value;
                                Color randomColor = Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)];
                                return Row(
                                  children: [
                                    SizedBox(width: _buttonDistance),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Row(
                                                children: [
                                                  const Icon(Icons.group_add),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    groupName,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              // fetches group description from firestore
                                              content: FutureBuilder<String>(
                                                future: _firestore
                                                    .collection("groups")
                                                    .doc(entry.key)
                                                    .get()
                                                    .then((value) =>
                                                        value.data()![
                                                            "description"]),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Text(
                                                      snapshot.data!,
                                                      textAlign:
                                                          TextAlign.center,
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(snapshot.error
                                                        .toString());
                                                  } else {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                },
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // if user already in group, show error
                                                    // else send request to group
                                                    // add to request field in the group
                                                    _firestore
                                                        .collection("groups")
                                                        .doc(entry.key)
                                                        .update({
                                                      "requests": FieldValue
                                                          .arrayUnion([
                                                        _firestore
                                                            .collection("users")
                                                            .doc(
                                                              // current user's uid
                                                              _auth.currentUser!
                                                                  .uid,
                                                            )
                                                      ])
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    "Request",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: randomColor,
                                        ),
                                        width: 120,
                                        alignment: Alignment.center,
                                        child: Text(
                                          groupName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        } else {
                          return const Text('No data available.');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      "Provide Feedback",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text('Let us know how we can improve!',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: feedbackButtonHeight,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        GestureDetector(
                          onTap: () {
                            // leave feedback
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Feedback"),
                                  content: TextField(
                                    controller: _feedbackController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your feedback here",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // send feedback to firestore
                                        _firestore.collection("feedback").add({
                                          "feedback": _feedbackController.text,
                                          "category": "scheduling",
                                          "uid": _auth.currentUser!.uid,
                                        });
                                        _feedbackController.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: hexToColor('FF7648'),
                            ),
                            width: feedbackButtonWidth,
                            child: const Center(
                              child: Text(
                                "Scheduling",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        GestureDetector(
                          onTap: () {
                            // leave feedback
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Feedback"),
                                  content: TextField(
                                    controller: _feedbackController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your feedback here",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // send feedback to firestore
                                        _firestore.collection("feedback").add({
                                          "feedback": _feedbackController.text,
                                          "category": "database",
                                          "uid": _auth.currentUser!.uid,
                                        });
                                        _feedbackController.clear();

                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: hexToColor('182A88'),
                            ),
                            width: feedbackButtonWidth,
                            child: const Center(
                              child: Text(
                                "Database",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _buttonDistance,
                        ),
                        GestureDetector(
                          onTap: () {
                            // leave feedback
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Feedback"),
                                  content: TextField(
                                    controller: _feedbackController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your feedback here",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // send feedback to firestore
                                        _firestore.collection("feedback").add({
                                          "feedback": _feedbackController.text,
                                          "category": "bugs",
                                          "uid": _auth.currentUser!.uid,
                                        });
                                        _feedbackController.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Submit",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellow,
                            ),
                            width: feedbackButtonWidth,
                            child: const Center(
                              child: Text(
                                "Bugs",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
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
