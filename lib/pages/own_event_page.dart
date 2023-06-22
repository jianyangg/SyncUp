import "package:flutter/material.dart";
import 'package:sync_up/components/bottom_nav_bar.dart';
import 'package:sync_up/pages/group_page.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/date_scroller.dart';
import '../components/date_tile.dart';
import '../components/event_tile.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

class OwnEventPage extends StatefulWidget {
  const OwnEventPage({super.key});

  @override
  State<OwnEventPage> createState() => _OwnEventPageState();
}

enum _SelectedTab { home, calendar, group, account }

class _OwnEventPageState extends State<OwnEventPage> {
  GoogleSignInAccount? _currentUser;
  late DateTime selectedDate;

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

  Future<List<cal.Event>> _handleGetEvents() async {
    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    // Prepare a gcal authenticated client. ORIGINAL. KEEP THIS CODE
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

  var _selectedTab = _SelectedTab.calendar;

  Color hexToColor(String code) {
    return Color(int.parse(
            code.substring(0, 2) + code.substring(2, 4) + code.substring(4, 6),
            radix: 16) +
        0xFF000000);
  }

  // Method to handle Nav bar click events
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
              primary: Colors.blue.shade800, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade800, // button text color
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
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade800,
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                updateSelectedDate(DateTime.now());
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(10.0)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue.shade700),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              child: const Text(
                "Today",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.calendar_month),
          ),
          // User shoudl go to group to create event.
          // we can add an additional feature to shortcut this using the add button in future versions
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.add),
          // ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      extendBody: true,
      body: Center(
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
                  color: Colors.blue.shade700),
              // divider
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey[200],
                  thickness: 1,
                ),
              ),
              // Currently selected Date:
              DateTile(selectedDate, Colors.blue.shade700, Colors.white),
              // all events for the day:
              const SizedBox(height: 10),
              FutureBuilder<List<cal.Event>>(
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
                      return events.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return EventTile(event,
                                      color: Colors.blue.shade700);
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
      bottomNavigationBar: BottomNavBar(
        _SelectedTab.values.indexOf(_selectedTab),
        _handleIndexChanged,
        color: Colors.blue.shade800,
      ),
    );
  }
}
