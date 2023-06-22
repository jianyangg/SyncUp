import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:sync_up/components/group_grid.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:sync_up/pages/own_event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_up/pages/group_search_page.dart';

import '../components/bottom_nav_bar.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

enum _SelectedTab { home, calendar, group, account }

class _GroupPageState extends State<GroupPage> {
  var _selectedTab = _SelectedTab.group;

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
            pageBuilder: (context, animation1, animation2) => const HomePage(),
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

  final _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  // need a firebase instance to get current user's uid
  final _auth = FirebaseAuth.instance;

  String searchQuery = '';
  List<DocumentSnapshot> searchResults = [];

  void _performSearch() async {
    // Perform the search query in Firestore
    QuerySnapshot snapshot = await _firestore
        .collection("groups")
        .where("name", isGreaterThanOrEqualTo: searchQuery)
        .where("name", isLessThan: searchQuery + "z")
        .get();

    // Process the search results
    List<DocumentSnapshot> documents = snapshot.docs;

    // Print the search results (for debugging)
    for (var doc in documents) {
      print(doc.data());
    }

    // You can store the search results in a state variable or use them as needed
    // For example, you can update a List variable to hold the search results
    setState(() {
      searchResults = documents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue.shade800,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue.shade800,
          shadowColor: Colors.transparent,
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Groups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 14 / 15,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _controller.clear();
                                  },
                                  child: Text(
                                    "< Back",
                                    style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 20),
                                  ),
                                ),
                                const Spacer(),
                                // another button to create group
                                TextButton(
                                  // once create button is pressed, add to cloud firestore and update the list
                                  onPressed: () {
                                    // take the text from the text field and add it to the user's array of groups in cloud firestore
                                    // and update the list
                                    // and then close the bottom sheet
                                    // first add to the "groups" collection
                                    // and give the group a unique id
                                    // then add the group name to the user's array of groups
                                    _firestore.collection("groups").add({
                                      "name": _controller.text.trim(),
                                      "owner": _auth.currentUser!.uid,
                                      "members": [
                                        // currently we only add one user to the group
                                        _auth.currentUser!.uid
                                      ],
                                      // requests
                                      "requests": [],
                                    }).then((docRef) {
                                      // then add the group id to the user's array of groups
                                      _firestore
                                          .collection("users")
                                          .doc(_auth.currentUser!.uid)
                                          .update({
                                        // store groupID instead.
                                        "groups":
                                            FieldValue.arrayUnion([docRef.id])
                                      }).then((value) {
                                        // then close the bottom sheet
                                        // then refresh the page
                                        // with the updated groups
                                        Navigator.pop(context);
                                        _controller.clear();
                                        // refresh the page
                                        setState(() {});
                                      }).catchError((error) {
                                        print(error);
                                      });
                                    });
                                  },
                                  child: Text(
                                    "Create",
                                    style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // have a text field for group name with a cross to clear everything at oncec
                            // and have another text field to add members
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: TextField(
                                autofocus: true,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Group Name",
                                  suffixIcon: IconButton(
                                      onPressed: _controller.clear,
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 20,
                                      )),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // show a search bar
                // search for group using input
                // if group exists, show the group
                // as a list view
                // if no groups found
                // show a message saying no groups found
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GroupSearchPage()));
              },
            ),
            const SizedBox(
              width: 15,
            )
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                    // create a grid of groups based on the user's groups
                    // have the groups updated automatically as and when the user creates a new group
                    // first retrieve the user's groups from cloud firestore
                    // then create a grid of groups
                    // where each grid item is a clickable button
                    child: GroupGrid(
                      userId: _auth.currentUser!.uid,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          _SelectedTab.values.indexOf(_selectedTab),
          _handleIndexChanged,
        ),
      ),
    );
  }
}
