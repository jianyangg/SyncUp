import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_search_bar.dart';

class GroupSearchPage extends StatefulWidget {
  const GroupSearchPage({Key? key}) : super(key: key);

  @override
  State<GroupSearchPage> createState() => _GroupSearchPageState();
}

class _GroupSearchPageState extends State<GroupSearchPage> {
  final TextEditingController _searchBarController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _searchBarController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchBarController.removeListener(_performSearch);
    _searchBarController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Search Groups",
          style: TextStyle(color: Colors.blue.shade800),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: BackButton(
            color: Colors.blue.shade800,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          MySearchBar(
            controller: _searchBarController,
            hintText: "Search",
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchBarController.text.isNotEmpty
                  ? _firestore
                      .collection('groups')
                      .where('name',
                          isGreaterThanOrEqualTo: _searchBarController.text)
                      .where('name',
                          isLessThan: '${_searchBarController.text}z')
                      .snapshots()
                  : _firestore.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No groups found.'),
                  );
                }
                final groups = snapshot.data!.docs;
                final List<Widget> groupWidgets = [];
                for (var group in groups) {
                  final groupName = group['name'];
                  final groupWidget = ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(groupName),
                    onTap: () {
                      // show popup dialog with group info and request to join button
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
                            // TODO: for content, create horizontal scrollable list view showing all members
                            // for now we will settle with the group description.
                            content: const Text(
                              'Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                              textAlign: TextAlign.center,
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
                                      .doc(group.id)
                                      .update({
                                    "requests": FieldValue.arrayUnion([
                                      _firestore.collection("users").doc(
                                            // current user's uid
                                            _auth.currentUser!.uid,
                                          )
                                    ])
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Request",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  groupWidgets.add(groupWidget);
                }
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, top: 10, right: 30),
                  child: ListView(
                    children: groupWidgets,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
