import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/components/common_slots_tile.dart';
import 'package:sync_up/components/user_selection_widget.dart';
import '../components/bottom_nav_bar.dart';
import 'account_page.dart';
import 'notification_page.dart';
import 'own_event_page.dart';
import 'group_page.dart';
import 'home_page.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/date_scroller.dart';
import '../components/date_tile.dart';
import '../components/event_tile.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

// TODO: The add event page is only complete on the front end side! We need to add the event to the database and the calendar
// once we have figured out the calendar API.

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

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
  GoogleSignInAccount? _currentUser;
  late DateTime selectedDate;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
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

  List<String> _selectedUserIds = [];
  void handleUserSelectionChanged(List<String> selectedUserIds) {
    setState(() {
      _selectedUserIds = selectedUserIds;
    });
  }

  final int pickerDateRange = 5;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // have a future boolean method to check requests to join group
  Future<bool> checkRequests() async {
    final doc = await _firestore.collection("groups").doc(widget.groupId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['requests'].length > 0;
    }
    return false;
  }

  Future<List<cal.Event>> _handleGetEvents() async {
    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    // Prepare a gcal authenticated client.
    final cal.CalendarApi gcalApi = cal.CalendarApi(client!);
    // calEvents should contain the events on the selected date.
    final cal.Events calEvents = await gcalApi.events.list(
      "primary",
      timeMin: selectedDate,
      timeMax:
          selectedDate.add(const Duration(hours: 23, minutes: 59, seconds: 59)),
    );
    final List<cal.Event> appointments = <cal.Event>[];

    // add all events to appointments which is a Future<List<Event>>
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final cal.Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        appointments.add(event);
      }
    }
    return appointments;
  }

  void _showDatePicker() {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = initialDate.subtract(const Duration(days: 365));
    DateTime lastDate = initialDate.add(const Duration(days: 365));
    showDatePicker(
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            dialogTheme: const DialogTheme(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)))),
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade800, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade800, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime date) {
        // Check if the date is unavailable
        if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
          return false;
        }
        return true;
      },
    ).then((newDate) {
      // THIS IS NECESSARY - there is something about the widget
      // that won't update properly unless we use a new DateTime.now() object
      if (newDate!.day == initialDate.day &&
          newDate.month == initialDate.month &&
          newDate.year == initialDate.year) {
        updateSelectedDate(DateTime.now());
      } else {
        updateSelectedDate(newDate);
      }
    });
  }

  void updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _dateScrollerController.setDateAndAnimate(newDate);
    });
  }

  final DatePickerController _dateScrollerController = DatePickerController();

  final TextEditingController _eventNameController = TextEditingController();
  int? _selectedPeriod = -1;
  String selectedDateRangeText =
      '${DateFormat('yyyy-MM-dd').format(DateTime.now())} to ${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)))}';

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetEvents();
      }
    });
    _googleSignIn.signInSilently();
  }

  void executeAfterBuild() {
    updateSelectedDate(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      executeAfterBuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    // show userId and groupId
    // using text widget for now

    return MaterialApp(
      // supposedly allows for swipe back gesture
      // for easier access to general group page.
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
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
              onPressed: _showDatePicker,
              icon: const Icon(
                Icons.calendar_month,
                color: Colors.black,
              ),
            ),
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
                    return Icon(
                      Icons.notifications_active_sharp,
                      color: Colors.orange.shade800,
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
                                    setState(() {
                                      _eventNameController.clear();
                                      _selectedPeriod = -1;
                                      // clear selected users
                                      _selectedUserIds.clear();
                                      selectedDateRangeText =
                                          '${DateFormat('yyyy-MM-dd').format(DateTime.now())} to ${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)))}';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "< Back",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.orange.shade800),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800),
                                  ),
                                  onPressed: () {
                                    // show availability of members for the event
                                    // once again using showModalBottomSheet
                                    if (_eventNameController.text.trim() ==
                                        '') {
                                      // show dialog, say set a name for the event and do not showModalBottomSheet
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Please set a name for the event",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (_selectedPeriod == -1) {
                                      // show dialog, say pick a period of time and do not showModalBottomSheet
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Please select an event duration",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (_selectedUserIds.isEmpty) {
                                      // show dialog, say select at least one member and do not showModalBottomSheet
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Please select at least one member",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
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
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          "< Back",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .orange
                                                                  .shade800,
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      // another button to create group
                                                      TextButton(
                                                        // once create button is pressed, add to cloud firestore and update the list
                                                        onPressed: () {
                                                          setState(() {
                                                            _eventNameController
                                                                .clear();
                                                            _selectedPeriod =
                                                                -1;
                                                            selectedDateRangeText =
                                                                '';
                                                          });
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            PageRouteBuilder(
                                                              pageBuilder: (context,
                                                                      animation1,
                                                                      animation2) =>
                                                                  GroupEventsPage(
                                                                userId: widget
                                                                    .userId,
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
                                                              color: Colors
                                                                  .orange
                                                                  .shade800,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  CommonSlotsTile(
                                                    eventName:
                                                        _eventNameController
                                                            .text
                                                            .trim(),
                                                    selectedPeriod:
                                                        _selectedPeriod!,
                                                    selectedDateRangeText:
                                                        selectedDateRangeText,
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                    groupId: widget.groupId,
                                                    userIds: _selectedUserIds,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
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
                                cursorColor: Colors.orange.shade800,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.orange.shade800,
                                          width: 2)),
                                  hintText: "Event Name",
                                  suffixIcon: IconButton(
                                      onPressed: _eventNameController.clear,
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.orange.shade800,
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
                                  DropdownButtonFormField<int>(
                                    hint: const Text("Event Duration"),
                                    focusColor: Colors.orange.shade800,
                                    value: _selectedPeriod,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.orange.shade800,
                                            width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.all(15),
                                    ),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        _selectedPeriod = newValue;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem<int>(
                                        value: -1,
                                        child: Text('Event Duration'),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 30,
                                        child: Text('30 mins'),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 60,
                                        child: Text('1 hour'),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 90,
                                        child: Text('1.5 hours'),
                                      ),
                                      // generate similar dropdownmenuitems up to 3 hours
                                      DropdownMenuItem<int>(
                                        value: 120,
                                        child: Text('2 hours'),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 150,
                                        child: Text('2.5 hours'),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 180,
                                        child: Text('3 hours'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // allow user to select which members must be present for the event
                            // must be intuitive and easy to use
                            // use a listview with checkboxes
                            // each listtile will have a checkbox and a text
                            // text will be the name of the member
                            // checkbox will be used to select the member
                            // use a list of strings to store the names of the members
                            // use a list of bools to store the state of the checkboxes
                            UserSelectionWidget(
                              onUserSelectionChanged:
                                  handleUserSelectionChanged,
                            ),
                            // FloatingActionButton(
                            //   onPressed: () {
                            //     // Access the selected users list and perform desired actions
                            //     final List<String> selectedUsers =
                            //         _selectedUserIds;
                            //     print('Selected Users: $selectedUsers');
                            //   },
                            //   child: Icon(Icons.check),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  211, 244, 244, 244)),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(15)),
                                    ),
                                    onPressed: () async {
                                      PickerDateRange? pickedDateRange;

                                      // show the sf date range picker
                                      // and allow user to select date range
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: SizedBox(
                                              height: 500,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: SfDateRangePicker(
                                                // round the corners of the date range picker
                                                view: DateRangePickerView.month,
                                                todayHighlightColor:
                                                    Colors.orange.shade800,
                                                selectionColor:
                                                    Colors.orange.shade300,
                                                rangeSelectionColor:
                                                    Colors.orange.shade100,
                                                startRangeSelectionColor:
                                                    Colors.orange.shade700,
                                                endRangeSelectionColor:
                                                    Colors.orange.shade700,
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
                                                  DateTime.now().add(Duration(
                                                      days: pickerDateRange)),
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(
                                                  'OK',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .orange.shade800,
                                                      fontSize: 15),
                                                ),
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
                                          startDate =
                                              pickedDateRange!.startDate ??
                                                  DateTime.now();
                                          endDate = pickedDateRange!.endDate ??
                                              DateTime.now();
                                          selectedDateRangeText =
                                              '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                          setState(() {
                                            selectedDateRangeText =
                                                '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                          });
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Select Date Range',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '(default: $pickerDateRange days)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Text(
                                  //   selectedDateRangeText,
                                  //   textAlign: TextAlign.center,
                                  //   style: const TextStyle(
                                  //     color: Colors.black,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
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
                            // insert horizontal bar for intuitive UI
                            Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 15),
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
                                            final memberPhotoUrl =
                                                data['photoUrl'] as String;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                        memberPhotoUrl,
                                                      ),
                                                      radius: 30,
                                                    ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // all dates here
                  DateScroller(
                      selectedDate, updateSelectedDate, _dateScrollerController,
                      color: Colors.orange.shade700),
                  // divider
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      color: Colors.grey[200],
                      thickness: 1,
                    ),
                  ),
                  // Currently selected Date:
                  DateTile(selectedDate, Colors.orange.shade700, Colors.white),
                  // all events for the day:
                  const SizedBox(height: 10),
                  FutureBuilder<List<cal.Event>>(
                      future: _handleGetEvents(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child:
                                CircularProgressIndicator(), // Display a loading indicator
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Error: ${snapshot.error}'), // Display an error message
                          );
                        } else if (snapshot.hasData) {
                          final List<cal.Event> events = snapshot.data!;
                          return events.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      final event = events[index];
                                      return EventTile(event,
                                          color: Colors.orange.shade700);
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: Center(
                                      child: Text('You\'re clear for the day!',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.bold))),
                                );
                        } else {
                          return const Center(
                            child: Text(
                                'No data available'), // Display a message when no data is available
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          _SelectedTab.values.indexOf(_selectedTab),
          _handleIndexChanged,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}

enum _SelectedTab { home, calendar, group, account }
