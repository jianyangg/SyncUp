import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final String groupId;
  const NotificationPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: BackButton(
            color: Colors.orange.shade800,
          ),
        ),
        shadowColor: Colors.transparent,
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.orange.shade800),
        ),
      ),
      backgroundColor: Colors.white,
      // show all requests from the database
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          const Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              "Requests to join group",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection("groups")
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!.data()! as Map<String, dynamic>;
                  final requests = data['requests'] as List<dynamic>;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final requestRef = requests[index] as DocumentReference;
                      return StreamBuilder<DocumentSnapshot>(
                        stream: requestRef.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final requestData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final name = requestData['name'] as String;

                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          "Approve or reject request"),
                                      // content: Text(
                                      //     // TODO: see if can incorporate message from requester
                                      //     "Message: ${requestData['msg']}"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // remove the user from requests
                                            _firestore
                                                .collection("groups")
                                                .doc(widget.groupId)
                                                .update({
                                              "requests":
                                                  FieldValue.arrayRemove(
                                                      [requestRef])
                                            });
                                          },
                                          child: const Text("Reject"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {});
                                            // add the user to the group and remove from requests
                                            _firestore
                                                .collection("groups")
                                                .doc(widget.groupId)
                                                .update({
                                              "members": FieldValue.arrayUnion(
                                                  [requestRef.id.toString()])
                                            });
                                            // add group to user's groups
                                            _firestore
                                                .collection("users")
                                                .doc(requestRef.id.toString())
                                                .update({
                                              "groups": FieldValue.arrayUnion(
                                                  [widget.groupId])
                                            });
                                            // remove from requests
                                            _firestore
                                                .collection("groups")
                                                .doc(widget.groupId)
                                                .update({
                                              "requests":
                                                  FieldValue.arrayRemove(
                                                      [requestRef])
                                            });
                                          },
                                          child: const Text("Approve"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ListTile(
                                title: Text(name),
                                leading: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.person),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const ListTile(
                              title: Text('Loading...'),
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
