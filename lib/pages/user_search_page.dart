import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/group_page.dart';

import '../components/my_search_bar.dart';
import 'account_page.dart';

class UserSearchPage extends StatefulWidget {
  final String groupName;
  final String groupDescription;
  const UserSearchPage(
      {super.key, required this.groupName, required this.groupDescription});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchUserController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> selectedUsers = [];

  Future<void> createGroup(List<Map<String, dynamic>> selectedUsers) async {
    final currentUserID = _auth.currentUser!.uid;

    selectedUsers.add({"name": await getUserName(), "uid": currentUserID});

    final groupRef = await _firestore.collection("groups").add({
      "name": widget.groupName,
      "owner": currentUserID,
      "members": selectedUsers.map((user) => user['uid']).toList(),
      "requests": [],
      "description": widget.groupDescription,
    });

    for (final user in selectedUsers) {
      await _firestore.collection("users").doc(user['uid']).update({
        "groups": FieldValue.arrayUnion([groupRef.id]),
      });
    }

    // Refresh the page
    setState(() {});
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const GroupPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          const SizedBox(
            width: 15,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "< Add Users",
              style: TextStyle(color: Colors.blue.shade800, fontSize: 20),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              createGroup(selectedUsers);
            },
            child: Text(
              "Create",
              style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          MySearchBar(
            controller: _searchUserController,
            hintText: "Search",
          ),
          if (selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedUsers
                    .where((user) =>
                        user['uid'] !=
                        _auth.currentUser!.uid) // Exclude the current user
                    .map(
                      (user) => Chip(
                        label: Text(user['name']),
                        onDeleted: () {
                          setState(() {
                            selectedUsers.remove(user);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchUserController.text.isNotEmpty
                  ? _firestore
                      .collection('users')
                      .where('name',
                          isGreaterThanOrEqualTo: _searchUserController.text)
                      .where('name',
                          isLessThan: '${_searchUserController.text}z')
                      .snapshots()
                  : _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No users found.'),
                  );
                }
                final users = snapshot.data!.docs;
                final List<Widget> userWidgets = [];
                for (var user in users) {
                  // ignore current user
                  if (user.id == _auth.currentUser!.uid) {
                    continue;
                  }
                  final userName = user['name'];
                  final userWidget = ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      userName,
                      style: TextStyle(
                        color: selectedUsers.any((selectedUser) =>
                                selectedUser['uid'] == user.id)
                            ? Colors.blue.shade800
                            : null,
                        fontWeight: selectedUsers.any((selectedUser) =>
                                selectedUser['uid'] == user.id)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (selectedUsers.any(
                            (selectedUser) => selectedUser['uid'] == user.id)) {
                          selectedUsers.removeWhere((selectedUser) =>
                              selectedUser['name'] == user.id);
                        } else {
                          // only add if not already added
                          selectedUsers.add({
                            'name': userName,
                            'uid': user.id,
                          });
                        }
                      });
                    },
                    iconColor: selectedUsers.any(
                            (selectedUser) => selectedUser['uid'] == user.id)
                        ? Colors.blue.shade700
                        : Colors.black,
                  );
                  userWidgets.add(userWidget);
                }
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, top: 10, right: 30),
                  child: ListView(
                    children: userWidgets,
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
