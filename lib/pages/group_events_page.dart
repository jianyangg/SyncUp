import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/components/common_slots_tile.dart';
import 'package:sync_up/components/user_selection_widget.dart';
import 'package:sync_up/components/users/profile_tile.dart';
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
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
  File? _imageFile;
  String? _imageUrl;
  final _picker = ImagePicker();
  final _storage = firebase_storage.FirebaseStorage.instance;
  final int pickerDateRange = 5;
  // initialised as false, overriden by data in firestore first, then by user input
  bool isRecreational = false;

  late DateTime selectedDate;
  DateTime startDate = DateTime.now();
  // change this if your default date range has changed!
  DateTime endDate = DateTime.now().add(const Duration(days: 5));
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

  // retrieve number of members in group
  Future<int> getMemberCount() async {
    final doc = await _firestore.collection("groups").doc(widget.groupId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['members'].length;
    }
    return 0;
  }

  List<String> _selectedUserIds = [];
  void handleUserSelectionChanged(List<String> selectedUserIds) {
    print(selectedUserIds);
    setState(() {
      _selectedUserIds = selectedUserIds;
    });
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

  Future<List<cal.Event>> _handleGetEvents() async {
    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    // Prepare a gcal authenticated client.
    final cal.CalendarApi gcalApi = cal.CalendarApi(client!);
    // calEvents should contain the events on the selected date.
    final cal.Events calEvents = await gcalApi.events.list(
      "primary",
      timeMin: DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0),
      timeMax: DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59),
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
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
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
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedPeriod = -1;
  String selectedDateRangeText =
      '${DateFormat('yyyy-MM-dd').format(DateTime.now())} to ${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 5)))}';

  int memberCount = 1;

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
    // read from firestore to see if group is recreational
    _firestore
        .collection("groups")
        .doc(widget.groupId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          isRecreational = documentSnapshot['isRecreational'];
        });
      }
    });
  }

  void executeAfterBuild() async {
    updateSelectedDate(DateTime.now());
    // TODO: No point syncing calendar all the time because we only need to sync when the user adds an event
    // TODO: plus, we already did it once in the beginning when the user logs in.
    // SyncCalendar.syncCalendarByDay(
    //   DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
    //   _googleSignIn,
    //   context,
    // );
    memberCount = await getMemberCount();
  }

  void _openEditDescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController editedDescriptionController =
            TextEditingController(text: _descriptionController.text);

        return AlertDialog(
          title: const Text("Edit Description"),
          content: TextField(
            controller: editedDescriptionController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _descriptionController.text =
                      editedDescriptionController.text;
                });
                FirebaseFirestore.instance
                    .collection("groups")
                    .doc(widget.groupId)
                    .update({
                  'description': editedDescriptionController.text,
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      executeAfterBuild();
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      final fileName =
          'groupImages/${widget.groupId}_groupPhoto'; // Adjust the file path to match your desired location in Firebase Storage

      final storageRef =
          firebase_storage.FirebaseStorage.instance.ref(fileName);

      // Delete the previous group photo if it exists
      try {
        await storageRef.delete();
      } catch (e) {
        print('Error deleting previous group photo: $e');
      }

      // Upload the new group photo to Firebase Storage
      await storageRef.putFile(imageFile);

      // Fetch the download URL of the newly uploaded image
      final downloadURL = await storageRef.getDownloadURL();

      setState(() {
        _imageFile = imageFile;
        _imageUrl = downloadURL; // Update the URL of the image
      });
    }
  }

  Future<String> doesGrpPhotoExist() async {
    final fileName =
        'groupImages/${widget.groupId}_groupPhoto'; // Adjust the file path to match your desired location in Firebase Storage

    final storageRef = firebase_storage.FirebaseStorage.instance.ref(fileName);

    // if photo exists, return the downloadURL
    try {
      final metadata = await storageRef.getMetadata();
      final doesExist = metadata.size != null;

      if (doesExist) {
        // Fetch the group photo from Firebase Storage
        final downloadURL = await storageRef.getDownloadURL();

        // Use the downloadURL as needed (e.g., display the image)
        // print('Download URL: $downloadURL');
        return downloadURL;
      }
    } catch (e) {
      print('Error: $e');
    }
    return 'NA';
  }

  @override
  Widget build(BuildContext context) {
    // show userId and groupId
    // using text widget for now
    Future<String> grpPhotoExists = doesGrpPhotoExist();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade100,
        shadowColor: Colors.transparent,
        title: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: Colors.orange.shade800,
          ),
          child: Row(
            children: [
              // clickable button to change group photo
              // but with a placeholder icon if there's no photo
              FutureBuilder<String>(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the future is still loading, you can show a loading indicator
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // If an error occurred while fetching the value, you can handle it here
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // The future has completed successfully, and you have obtained the boolean value
                      final String grpPhotoStatus = snapshot.data!;
                      // if grpphoto exists,
                      // display the photo from firebase storage
                      // else display a placeholder icon
                      return IconButton(
                        icon: grpPhotoStatus != "NA"
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(grpPhotoStatus),
                                radius: 20,
                              )
                            : const Icon(
                                Icons.photo,
                                color: Colors.white,
                                size: 30,
                              ),
                        onPressed: _pickImage,
                      );
                    }
                  },
                  future: grpPhotoExists),
              const SizedBox(width: 5),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    widget.groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
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
              // allow user to create events for the group
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
                          Container(
                            height: 3,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _eventNameController.clear();
                                    _selectedPeriod = -1;
                                    // clear selected users
                                    _selectedUserIds.clear();
                                    startDate = DateTime.now();
                                    endDate = DateTime.now()
                                        .add(Duration(days: pickerDateRange));
                                    selectedDateRangeText =
                                        '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Back",
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
                                  if (_eventNameController.text.trim() == '') {
                                    // show dialog, say set a name for the event and do not showModalBottomSheet
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Please set a name for the event",
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                                Container(
                                                  height: 3,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Back",
                                                        style: TextStyle(
                                                            color: Colors.orange
                                                                .shade800,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                CommonSlotsTile(
                                                  eventName:
                                                      _eventNameController.text
                                                          .trim(),
                                                  selectedPeriod:
                                                      _selectedPeriod!,
                                                  selectedDateRangeText:
                                                      selectedDateRangeText,
                                                  startDate: startDate,
                                                  endDate: endDate,
                                                  userId: widget.userId,
                                                  groupId: widget.groupId,
                                                  groupName: widget.groupName,
                                                  userIds: _selectedUserIds,
                                                  memberCount: memberCount,
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
                          UserSelectionWidget(
                            onUserSelectionChanged: handleUserSelectionChanged,
                            groupId: widget.groupId,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey.shade200),
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
                                            content: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              height: 500,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: SfDateRangePicker(
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
                                                minDate: DateTime.now(),
                                                maxDate: DateTime.now().add(
                                                    const Duration(days: 30)),
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
                                          setState(() {
                                            startDate =
                                                pickedDateRange!.startDate ??
                                                    DateTime.now();
                                            endDate =
                                                pickedDateRange!.endDate ??
                                                    DateTime.now();
                                            print(
                                                "previous startdate: $startDate}");
                                            print(
                                                "previous enddate: $endDate}");
                                            if (endDate.isBefore(startDate)) {
                                              endDate = startDate.add(
                                                  const Duration(
                                                      microseconds: 1));
                                            }

                                            print("new startDate: $startDate}");
                                            print("new endDate: $endDate}");

                                            selectedDateRangeText =
                                                '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
                                          });
                                        }
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                    height: MediaQuery.of(context).size.height * 14 / 15,
                    // height: 900,
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
                            height: 3,
                          ),
                          StreamBuilder<DocumentSnapshot>(
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
                                // save member count
                                memberCount = members.length;
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
                                        return ProfileTile(
                                            memberPhotoUrl: memberPhotoUrl,
                                            memberName: memberName);
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  );
                                  memberWidgets.add(memberWidget);
                                }
                                return SizedBox(
                                  height: 130,
                                  child: GridView(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    children: memberWidgets,
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 3),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 40),
                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 15, color: Colors.black),
                                    onPressed: () {
                                      _openEditDescriptionDialog();
                                    },
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 3),
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("groups")
                                    .doc(widget.groupId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    String description;
                                    if (data['description'] == null) {
                                      description =
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
                                    } else {
                                      description =
                                          data['description'] as String;
                                    }
                                    _descriptionController.text = description;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              // create a toggle button that toggles between recreational and work
                              // and if recreational is selected, the text below displays "Recreational Hours: 0000 to 2359"
                              // and if work is selected, the text below displays "Work Hours: 0900 to 1700"
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Recreational",
                                        style: TextStyle(
                                            color: Colors.orange.shade800,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Switch(
                                        value: !isRecreational,
                                        onChanged: (value) {
                                          setState(() {
                                            isRecreational = !value;
                                            // show dialog, informing user that the group type has been changed
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                // update group type in firestore
                                                FirebaseFirestore.instance
                                                    .collection("groups")
                                                    .doc(widget.groupId)
                                                    .update({
                                                  'isRecreational':
                                                      isRecreational,
                                                });
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  title: const Text(
                                                    "Group type changed",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Text(
                                                    "Group type has been changed from ${isRecreational ? "Work" : "Recreational"} to ${isRecreational ? "Recreational" : "Work"}.",
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "OK",
                                                        style: TextStyle(
                                                            color: Colors.orange
                                                                .shade800),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            Navigator.pop(context);
                                          });
                                        },
                                        activeTrackColor: Colors.orange,
                                        activeColor: Colors.orange.shade800,
                                      ),
                                      Text(
                                        "Work",
                                        style: TextStyle(
                                            color: Colors.orange.shade800,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(isRecreational
                                      ? "Recreational Hours: 0000 to 2359"
                                      : "Work Hours: 0900 to 1700"),
                                ],
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
                DateTile(
                    dateToDisplay: selectedDate,
                    bgColor: Colors.orange.shade700,
                    textColor: Colors.white),
                // all events for the day:
                const SizedBox(height: 10),
                FutureBuilder<List<cal.Event>>(
                    initialData: const [],
                    future: _handleGetEvents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        List<cal.Event> currentGroupEvents = events
                            .where((e) =>
                                e.extendedProperties?.shared?['GROUP_NAME'] ==
                                    widget.groupName &&
                                e.extendedProperties?.shared?['CREATOR'] ==
                                    'SYNCUP')
                            .toList();
                        return currentGroupEvents.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: currentGroupEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = currentGroupEvents[index];
                                    return EventTile(
                                      event,
                                      color: Colors.orange.shade700,
                                      groupName: widget.groupName,
                                    );
                                  },
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(top: 25.0),
                                child: Center(
                                  child: Text(
                                    'No events to show.',
                                    style: TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(106, 0, 0, 0)),
                                  ),
                                ));
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
        color: Colors.orange.shade700,
      ),
    );
  }
}

enum _SelectedTab { home, calendar, group, account }
