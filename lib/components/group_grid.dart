import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_up/pages/group_events_page.dart';

import '../pages/group_page.dart';

class GroupGrid extends StatelessWidget {
  final String userId;
  const GroupGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // create a firestore instnace to access the database
    final firestore = FirebaseFirestore.instance;

    // using the userId, retrieve id of the groups associated with the user
    // and save it in a list
    List<String> groupNames = [];

    // return a future builder to get the data from the database
    Future getGroupIds() async {
      final snapshot = await firestore.collection("users").doc(userId).get();
      final data = snapshot.data();
      final groupIds = data?["groups"] as List<dynamic>;
      // retrieve the group names
      for (var groupId in groupIds) {
        final groupSnapshot =
            await firestore.collection("groups").doc(groupId).get();
        final groupData = groupSnapshot.data();
        final groupName = groupData?["name"] as String;
        groupNames.add(groupName);
      }
      return groupIds;
    }

    return RefreshIndicator(
      onRefresh: () async {
        // refresh the page
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const GroupPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: FutureBuilder(
        future: getGroupIds(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final groupIds = snapshot.data!;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 4 / 5,
              child: GridView.builder(
                itemCount: groupIds.length,
                // make it blue and evenly spaced out with 2 columns
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // crossAxisSpacing: 0,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.4,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // navigate to group page
                            // print(context);
                            // push to group_events_page
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        GroupEventsPage(
                                  userId: userId,
                                  groupId: groupIds[index],
                                  groupName: groupNames[index],
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              // retrieve group name from firestore
                              groupNames[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 9,
                        right: 10,
                        child: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'leave_group',
                              child: const Text('Leave Group'),
                              onTap: () {
                                // remove the group from the user's list of groups
                                // if the user is the owner of the group,
                                // delete the group
                                firestore
                                    .collection("groups")
                                    .doc(groupIds[index])
                                    .get()
                                    .then((value) {
                                  final data = value.data();
                                  final ownerId = data?["owner"] as String;
                                  if (ownerId == userId) {
                                    // delete the group from all users
                                    firestore
                                        .collection("users")
                                        .get()
                                        .then((value) {
                                      for (var doc in value.docs) {
                                        final userData = doc.data();
                                        final userGroups =
                                            userData["groups"] as List;
                                        if (userGroups
                                            .contains(groupIds[index])) {
                                          firestore
                                              .collection("users")
                                              .doc(doc.id)
                                              .update({
                                            "groups": FieldValue.arrayRemove(
                                                [groupIds[index]])
                                          });
                                        }
                                      }
                                    });
                                    firestore
                                        .collection("groups")
                                        .doc(groupIds[index])
                                        .delete();
                                  } else {
                                    firestore
                                        .collection("groups")
                                        .doc(groupIds[index])
                                        .update({
                                      "members":
                                          FieldValue.arrayRemove([userId])
                                    });
                                    firestore
                                        .collection("users")
                                        .doc(userId)
                                        .update({
                                      "groups": FieldValue.arrayRemove(
                                          [groupIds[index]])
                                    });
                                  }
                                });
                              },
                            ),
                            PopupMenuItem(
                              value: 'copy_grp_name',
                              child: const Text('Copy Group Name'),
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: groupNames[index]));
                              },
                            ),
                            const PopupMenuItem(
                                value: 'back', child: Text('Back')),
                          ],
                          icon: const Icon(Icons.more_vert),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
