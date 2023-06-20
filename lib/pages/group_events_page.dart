import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/components/calendar_scroll.dart';
import '../components/my_textfield.dart';
import 'account_page.dart';
import 'notification_page.dart';
import 'own_event_page.dart';
import 'group_page.dart';
import 'home_page.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class GroupEventsPage extends StatefulWidget {
  final String userId;
  final String groupId;
  final String groupName;
  const GroupEventsPage(
      {super.key,
      required this.userId,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupEventsPage> createState() => _GroupEventsPageState();
}

class _GroupEventsPageState extends State<GroupEventsPage> {
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  /// called whenever a selection changed on the date picker widget.
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  var _selectedTab = _SelectedTab.group;
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
      // TODO: fix the case 1 and 2 once Calendar and Database pages are done.
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // have a future boolean method to check requests to join group
  Future<bool> checkRequests() async {
    final doc = await _firestore.collection("groups").doc(widget.groupId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['requests'].length > 0;
    }
    return false;
  }

  final TextEditingController _eventNameController = TextEditingController();
  String? _selectedPeriod = "Should not be chosen";
  String selectedDateRangeText = '';

  @override
  Widget build(BuildContext context) {
    // show userId and groupId
    // using text widget for now
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          shadowColor: Colors.transparent,
          title: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colors.orange.shade800,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationPage(
                              groupId: widget.groupId,
                            )));
              },
              icon: FutureBuilder<bool>(
                future: checkRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return const Icon(
                      Icons.notifications_active_sharp,
                      color: Colors.red,
                    );
                  } else {
                    return const Icon(Icons.notifications, color: Colors.black);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                // allow user to create events for the grou
                // design is based on our Figma sketch
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  context: context,
                  builder: (context) {
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
                                  },
                                  child: Text(
                                    "< Back",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    // show availability of members for the event
                                    // once again using showModalBottomSheet
                                    showModalBottomSheet(
                                      // window to come in from the right instead of bottom

                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              14 /
                                              15,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "< Back",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    // another button to create group
                                                    TextButton(
                                                      // once create button is pressed, add to cloud firestore and update the list
                                                      onPressed: () {
                                                        // reset event name
                                                        _eventNameController
                                                            .clear();
                                                        // reset selected period
                                                        _selectedPeriod =
                                                            "Should not be chosen";
                                                        // reset selected date range
                                                        selectedDateRangeText =
                                                            '';
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context,
                                                                    animation1,
                                                                    animation2) =>
                                                                GroupEventsPage(
                                                              userId:
                                                                  widget.userId,
                                                              groupId: widget
                                                                  .groupId,
                                                              groupName: widget
                                                                  .groupName,
                                                            ),
                                                            transitionDuration:
                                                                Duration.zero,
                                                            reverseTransitionDuration:
                                                                Duration.zero,
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        "Create",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Event Name: ${_eventNameController.text}",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                        "Duration: ${_selectedPeriod!}",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      "Date Range: $selectedDateRangeText",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: TextField(
                                autofocus: true,
                                controller: _eventNameController,
                                decoration: InputDecoration(
                                  hintText: "Event Name",
                                  suffixIcon: IconButton(
                                      onPressed: _eventNameController.clear,
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
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    hint: const Text("Event Duration"),
                                    value: _selectedPeriod,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.all(15),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedPeriod = newValue;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem<String>(
                                        value: 'Should not be chosen',
                                        child: Text('Event Duration'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '30 mins',
                                        child: Text('30 mins'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '1 hour',
                                        child: Text('1 hour'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '1.5 hours',
                                        child: Text('1.5 hours'),
                                      ),
                                      // generate similar dropdownmenuitems up to 3 hours
                                      DropdownMenuItem<String>(
                                        value: '2 hours',
                                        child: Text('2 hours'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '2.5 hours',
                                        child: Text('2.5 hours'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: '3 hours',
                                        child: Text('3 hours'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      PickerDateRange? pickedDateRange;

                                      // show the sf date range picker
                                      // and allow user to select date range
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Container(
                                              height: 500,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: SfDateRangePicker(
                                                onSelectionChanged:
                                                    (DateRangePickerSelectionChangedArgs
                                                        args) {
                                                  if (args.value
                                                      is PickerDateRange) {
                                                    setState(() {
                                                      pickedDateRange =
                                                          args.value!;
                                                    });
                                                  }
                                                },
                                                selectionMode:
                                                    DateRangePickerSelectionMode
                                                        .range,
                                                initialSelectedRange:
                                                    PickerDateRange(
                                                  DateTime.now(),
                                                  DateTime.now().add(
                                                      const Duration(days: 7)),
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(pickedDateRange);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((value) {
                                        if (value != null &&
                                            value is PickerDateRange) {
                                          setState(() {
                                            pickedDateRange = value;
                                          });
                                        }
                                        if (pickedDateRange != null) {
                                          final startDate =
                                              pickedDateRange!.startDate ??
                                                  DateTime.now();
                                          final endDate =
                                              pickedDateRange!.endDate ??
                                                  DateTime.now();

                                          setState(() {
                                            selectedDateRangeText =
                                                '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                          });
                                        }
                                      });
                                    },
                                    child: const Text(
                                      'Select Date Range',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    selectedDateRangeText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              color: Colors.black,
            ),
            IconButton(
              onPressed: () {
                // display all members in the group
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Members",
                                  style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: _firestore
                                    .collection("groups")
                                    .doc(widget.groupId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    final members =
                                        data['members'] as List<dynamic>;
                                    List<Widget> memberWidgets = [];
                                    for (var member in members) {
                                      final memberWidget =
                                          FutureBuilder<DocumentSnapshot>(
                                        future: _firestore
                                            .collection("users")
                                            .doc(member as String)
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final data = snapshot.data!.data()
                                                as Map<String, dynamic>;
                                            final memberName =
                                                data['name'] as String;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    const Icon(Icons.person),
                                                    Text(
                                                      memberName,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      );
                                      memberWidgets.add(memberWidget);
                                    }
                                    return GridView(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      children: memberWidgets,
                                    );
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
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.info_outline,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CalendarScroll(color: Colors.orange.shade700),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      const Text(
                        "Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromARGB(143, 158, 158, 158),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      const Text(
                        'Event',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromARGB(143, 158, 158, 158),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.sort,
                          color: Color.fromARGB(143, 158, 158, 158),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        // for time
                        const Column(
                          children: [
                            Text(
                              "11:35",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "12:00",
                              style: TextStyle(
                                color: Color.fromARGB(143, 158, 158, 158),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        // for divider
                        const VerticalDivider(
                          color: Color.fromARGB(71, 158, 158, 158),
                          thickness: 2.5,
                        ),
                        const SizedBox(width: 10),
                        // for event
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 120,
                              width: MediaQuery.of(context).size.width * 0.68,
                              decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(
                                  'MA2001 Group Meeeting',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DotNavigationBar(
          backgroundColor: Colors.orange.shade800,
          enableFloatingNavBar: true,
          margin: const EdgeInsets.only(left: 10, right: 10),
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          dotIndicatorColor: Colors.white,
          unselectedItemColor: Colors.grey[350],
          // enableFloatingNavBar: false,
          onTap: _handleIndexChanged,
          items: [
            /// Home
            DotNavigationBarItem(
              icon: const Icon(Icons.home),
              selectedColor: Colors.white,
            ),

            /// Likes
            DotNavigationBarItem(
              icon: const Icon(Icons.calendar_month),
              selectedColor: Colors.white,
            ),

            /// Search
            DotNavigationBarItem(
              icon: const Icon(Icons.group),
              selectedColor: Colors.white,
            ),

            /// Profile
            DotNavigationBarItem(
              icon: const Icon(Icons.person),
              selectedColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

enum _SelectedTab { home, calendar, group, account }
