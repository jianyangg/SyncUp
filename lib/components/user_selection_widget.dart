import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSelectionWidget extends StatefulWidget {
  final Function(List<String>) onUserSelectionChanged;

  const UserSelectionWidget({required this.onUserSelectionChanged});

  @override
  _UserSelectionWidgetState createState() => _UserSelectionWidgetState();
}

class _UserSelectionWidgetState extends State<UserSelectionWidget> {
  List<String> selectedUsers = [];
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final users = snapshot.data!.docs;

        return Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose users that must be present:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (selectAll) {
                          selectedUsers.clear();
                        } else {
                          selectedUsers = users.map((user) => user.id).toList();
                        }
                        selectAll = !selectAll;
                      });
                      widget.onUserSelectionChanged(selectedUsers);
                    },
                    child: Text(
                      selectAll ? 'Deselect All' : 'Select All',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    final userName = user['name'] as String;

                    return CheckboxListTile(
                      title: Text(userName),
                      value: selectedUsers.contains(userId),
                      onChanged: (checked) {
                        setState(() {
                          if (checked!) {
                            selectedUsers.add(userId);
                          } else {
                            selectedUsers.remove(userId);
                          }
                          selectAll = false;
                        });
                        widget.onUserSelectionChanged(selectedUsers);
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
}
