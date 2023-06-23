import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSelectionWidget extends StatefulWidget {
  final Function(List<String>) onUserSelectionChanged;

  const UserSelectionWidget({required this.onUserSelectionChanged});

  @override
  _UserSelectionWidgetState createState() => _UserSelectionWidgetState();
}

class _UserSelectionWidgetState extends State<UserSelectionWidget> {
  List<String> selectedUsers = [];
  bool selectedAll = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final users = snapshot.data!.docs;

        return Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.orange[100],
                    ),
                    child: Text("Choose users that must be present:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )),
                  ),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedAll) {
                              selectedUsers.clear();
                            } else {
                              selectedUsers =
                                  users.map((user) => user.id).toList();
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
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade800),
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: FittedBox(
                          child: Text(
                            selectedAll ? 'Deselect All' : 'Select All',
                          ),
                        ),
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
                          selectedAll = false;
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
