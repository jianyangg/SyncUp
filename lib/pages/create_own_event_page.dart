import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sync_up/pages/own_event_page.dart';

class CreateOwnEventPage extends StatefulWidget {
  const CreateOwnEventPage({super.key});

  @override
  State<CreateOwnEventPage> createState() => _CreateOwnEventPageState();
}

class _CreateOwnEventPageState extends State<CreateOwnEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _newEventStart = DateTime.now();
  DateTime _newEventEnd = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;

  Future<void> _showNewEventStartDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _newEventStart,
      firstDate: _newEventStart.subtract(const Duration(days: 365)),
      lastDate: _newEventStart.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _newEventStart = pickedDate;
      });
    }
  }

  Future<void> _showNewEventEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _newEventEnd,
      firstDate: _newEventEnd.subtract(const Duration(days: 365)),
      lastDate: _newEventEnd.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _newEventEnd = pickedDate;
      });
    }
  }

  // create a time picker
  Future<void> _showNewEventStartTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_newEventStart),
    );

    if (pickedTime != null) {
      setState(() {
        _newEventStart = DateTime(
          _newEventStart.year,
          _newEventStart.month,
          _newEventStart.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // create a time picker
  Future<void> _showNewEventEndTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_newEventEnd),
    );

    if (pickedTime != null) {
      setState(() {
        _newEventEnd = DateTime(
          _newEventEnd.year,
          _newEventEnd.month,
          _newEventEnd.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 14 / 15,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const OwnEventPage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                      _titleController.clear();
                      _descriptionController.clear();
                    },
                    child: Text(
                      "Back",
                      style:
                          TextStyle(color: Colors.blue.shade800, fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _titleController.clear();
                      _descriptionController.clear();
                      // TODO: Integrate with Calendar API
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                        ),
                        cursorColor: Colors.grey.shade500,
                        decoration: InputDecoration(
                          hintText: "Add title",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 25,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "All day",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Switch(
                                  value: _isAllDay,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAllDay = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.calendar_today,
                                      color: Colors.white),
                                ),
                                TextButton(
                                  child: Text(
                                    DateFormat('EEEE, d MMM')
                                        .format(_newEventStart),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showNewEventStartDatePicker();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    // format time
                                    DateFormat('h:mm a').format(_newEventStart),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showNewEventStartTimePicker();
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.calendar_today,
                                      color: Colors.white),
                                ),
                                TextButton(
                                  child: Text(
                                    DateFormat('EEEE, d MMM')
                                        .format(_newEventEnd),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showNewEventEndDatePicker();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    // format time
                                    DateFormat('h:mm a').format(_newEventEnd),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                  onPressed: () {
                                    _showNewEventEndTimePicker();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const SizedBox(
                            height: 30,
                            width: 40,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.0, top: 5.0),
                              child: Icon(
                                Icons.notes,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              autocorrect: true,
                              controller: _descriptionController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              cursorColor: Colors.grey.shade500,
                              decoration: InputDecoration(
                                hintText: "Add description",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                // prefixIcon: const Padding(
                                //   padding: EdgeInsets.only(left: 0.0),
                                //   child: Icon(
                                //     Icons.notes,
                                //     color: Colors.black,
                                //     size: 20,
                                //   ),
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
