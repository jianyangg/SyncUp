import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSelectionWidget extends StatefulWidget {
  final String groupId;
  final Function(List<String>) onUserSelectionChanged;

  const UserSelectionWidget(
      {super.key, required this.onUserSelectionChanged, required this.groupId});

  @override
  _UserSelectionWidgetState createState() => _UserSelectionWidgetState();
}

class _UserSelectionWidgetState extends State<UserSelectionWidget> {
  List<String> selectedUsers = [];
  bool selectedAll = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final users = groupData['members'] as List<dynamic>;
        // print(users);

        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Text(
                "Choose users that must be present:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 20,
                    width: 50,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (selectedAll) {
                            selectedUsers.clear();
                          } else {
                            selectedUsers = List<String>.from(users);
                          }
                          selectedAll = !selectedAll;
                        });
                        widget.onUserSelectionChanged(selectedUsers);
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          TextStyle(
                            color: Colors.orange.shade800,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: FittedBox(
                        child: Text(selectedAll ? 'Deselect All' : 'Select All',
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userId = users[index];

                    return FutureBuilder<String>(
                      future: getUserFromFirestore(userId),
                      builder: (context, snapshot) {
                        final userName = snapshot.data;
                        return CheckboxListTile(
                          fillColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade700),
                          title: Text(userName.toString()),
                          value: selectedUsers.contains(userId),
                          onChanged: (checked) {
                            setState(() {
                              if (checked!) {
                                selectedUsers.add(userId);
                              } else {
                                selectedUsers.remove(userId);
                              }
                              selectedAll = false;
                            });
                            widget.onUserSelectionChanged(selectedUsers);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> getUserFromFirestore(String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((snapshot) {
      final userData = snapshot.data() as Map<String, dynamic>;
      // print(userData['name']);
      return userData['name'];
    });
  }
}
