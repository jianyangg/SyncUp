// import 'package:flutter/material.dart';

// class CreateGroupEventModal extends StatelessWidget {
//   final Function() backButtonCallback;
//   // backButtonCallback is this fn () => {
//   //                   setState(() {
//   //                     _eventNameController.clear();
//   //                     _selectedPeriod = -1;
//   //                     // clear selected users
//   //                     _selectedUserIds.clear();
//   //                     selectedDateRangeText =
//   //                         '${DateFormat('yyyy-MM-dd').format(DateTime.now())} to ${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7)))}';
//   //                   });
//   //                   Navigator.pop(context);
//   //                 }

//   final Function() nextButtonCallback;

//   CreateGroupEventModal(this.backButtonCallback, this.nextButtonCallback, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 14 / 15,
//       child: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 TextButton(
//                   onPressed: backButtonCallback,
//                   child: Text(
//                     "< Back",
//                     style:
//                         TextStyle(fontSize: 20, color: Colors.orange.shade800),
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   child: Text(
//                     "Next",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange.shade800),
//                   ),
//                   onPressed: () {
//                     // show availability of members for the event
//                     // once again using showModalBottomSheet
//                     if (_eventNameController.text.trim() == '') {
//                       // show dialog, say set a name for the event and do not showModalBottomSheet
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: const Text(
//                               "Please set a name for the event",
//                               style: TextStyle(color: Colors.black),
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text(
//                                   "OK",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     } else if (_selectedPeriod == -1) {
//                       // show dialog, say pick a period of time and do not showModalBottomSheet
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: const Text(
//                               "Please select an event duration",
//                               style: TextStyle(color: Colors.black),
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text(
//                                   "OK",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     } else if (_selectedUserIds.isEmpty) {
//                       // show dialog, say select at least one member and do not showModalBottomSheet
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: const Text(
//                               "Please select at least one member",
//                               style: TextStyle(color: Colors.black),
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text(
//                                   "OK",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     } else {
//                       showModalBottomSheet(
//                         // window to come in from the right instead of bottom

//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30)),
//                         isScrollControlled: true,
//                         context: context,
//                         builder: (BuildContext context) {
//                           return SizedBox(
//                             height:
//                                 MediaQuery.of(context).size.height * 14 / 15,
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         },
//                                         child: Text(
//                                           "< Back",
//                                           style: TextStyle(
//                                               color: Colors.orange.shade800,
//                                               fontSize: 20),
//                                         ),
//                                       ),
//                                       const Spacer(),
//                                       // another button to create group
//                                       TextButton(
//                                         // once create button is pressed, add to cloud firestore and update the list
//                                         onPressed: () {
//                                           setState(() {
//                                             _eventNameController.clear();
//                                             _selectedPeriod = -1;
//                                             selectedDateRangeText = '';
//                                           });
//                                           Navigator.pushReplacement(
//                                             context,
//                                             PageRouteBuilder(
//                                               pageBuilder: (context, animation1,
//                                                       animation2) =>
//                                                   GroupEventsPage(
//                                                 userId: widget.userId,
//                                                 groupId: widget.groupId,
//                                                 groupName: widget.groupName,
//                                               ),
//                                               transitionDuration: Duration.zero,
//                                               reverseTransitionDuration:
//                                                   Duration.zero,
//                                             ),
//                                           );
//                                         },
//                                         child: Text(
//                                           "Create",
//                                           style: TextStyle(
//                                               color: Colors.orange.shade800,
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 20),
//                                   CommonSlotsTile(
//                                     eventName: _eventNameController.text.trim(),
//                                     selectedPeriod: _selectedPeriod!,
//                                     selectedDateRangeText:
//                                         selectedDateRangeText,
//                                     startDate: startDate,
//                                     endDate: endDate,
//                                     groupId: widget.groupId,
//                                     userIds: _selectedUserIds,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }
//                   },
//                 )
//               ],
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: TextField(
//                 autofocus: true,
//                 controller: _eventNameController,
//                 cursorColor: Colors.orange.shade800,
//                 decoration: InputDecoration(
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide:
//                           BorderSide(color: Colors.orange.shade800, width: 2)),
//                   hintText: "Event Name",
//                   suffixIcon: IconButton(
//                       onPressed: _eventNameController.clear,
//                       icon: Icon(
//                         Icons.clear,
//                         color: Colors.orange.shade800,
//                         size: 20,
//                       )),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.all(15),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButtonFormField<int>(
//                     hint: const Text("Event Duration"),
//                     focusColor: Colors.orange.shade800,
//                     value: _selectedPeriod,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide:
//                             BorderSide(color: Colors.orange.shade800, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.all(15),
//                     ),
//                     onChanged: (int? newValue) {
//                       setState(() {
//                         _selectedPeriod = newValue;
//                       });
//                     },
//                     items: const [
//                       DropdownMenuItem<int>(
//                         value: -1,
//                         child: Text('Event Duration'),
//                       ),
//                       DropdownMenuItem<int>(
//                         value: 30,
//                         child: Text('30 mins'),
//                       ),
//                       DropdownMenuItem<int>(
//                         value: 60,
//                         child: Text('1 hour'),
//                       ),
//                       DropdownMenuItem<int>(
//                         value: 90,
//                         child: Text('1.5 hours'),
//                       ),
//                       // generate similar dropdownmenuitems up to 3 hours
//                       DropdownMenuItem<int>(
//                         value: 120,
//                         child: Text('2 hours'),
//                       ),
//                       DropdownMenuItem<int>(
//                         value: 150,
//                         child: Text('2.5 hours'),
//                       ),
//                       DropdownMenuItem<int>(
//                         value: 180,
//                         child: Text('3 hours'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // allow user to select which members must be present for the event
//             // must be intuitive and easy to use
//             // use a listview with checkboxes
//             // each listtile will have a checkbox and a text
//             // text will be the name of the member
//             // checkbox will be used to select the member
//             // use a list of strings to store the names of the members
//             // use a list of bools to store the state of the checkboxes
//             UserSelectionWidget(
//               onUserSelectionChanged: handleUserSelectionChanged,
//             ),
//             // FloatingActionButton(
//             //   onPressed: () {
//             //     // Access the selected users list and perform desired actions
//             //     final List<String> selectedUsers =
//             //         _selectedUserIds;
//             //     print('Selected Users: $selectedUsers');
//             //   },
//             //   child: Icon(Icons.check),
//             // ),
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: Column(
//                 children: [
//                   TextButton(
//                     style: ButtonStyle(
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       )),
//                       backgroundColor: MaterialStateProperty.all<Color>(
//                           const Color.fromARGB(211, 244, 244, 244)),
//                       padding: MaterialStateProperty.all<EdgeInsets>(
//                           const EdgeInsets.all(15)),
//                     ),
//                     onPressed: () async {
//                       PickerDateRange? pickedDateRange;

//                       // show the sf date range picker
//                       // and allow user to select date range
//                       await showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             content: SizedBox(
//                               height: 500,
//                               width: MediaQuery.of(context).size.width * 0.8,
//                               child: SfDateRangePicker(
//                                 // round the corners of the date range picker
//                                 view: DateRangePickerView.month,
//                                 todayHighlightColor: Colors.orange.shade800,
//                                 selectionColor: Colors.orange.shade300,
//                                 rangeSelectionColor: Colors.orange.shade100,
//                                 startRangeSelectionColor:
//                                     Colors.orange.shade700,
//                                 endRangeSelectionColor: Colors.orange.shade700,
//                                 onSelectionChanged:
//                                     (DateRangePickerSelectionChangedArgs args) {
//                                   if (args.value is PickerDateRange) {
//                                     setState(() {
//                                       pickedDateRange = args.value!;
//                                     });
//                                   }
//                                 },
//                                 selectionMode:
//                                     DateRangePickerSelectionMode.range,
//                                 initialSelectedRange: PickerDateRange(
//                                   DateTime.now(),
//                                   DateTime.now()
//                                       .add(Duration(days: pickerDateRange)),
//                                 ),
//                               ),
//                             ),
//                             actions: <Widget>[
//                               TextButton(
//                                 child: Text(
//                                   'OK',
//                                   style: TextStyle(
//                                       color: Colors.orange.shade800,
//                                       fontSize: 15),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop(pickedDateRange);
//                                 },
//                               ),
//                             ],
//                           );
//                         },
//                       ).then((value) {
//                         if (value != null && value is PickerDateRange) {
//                           setState(() {
//                             pickedDateRange = value;
//                           });
//                         }
//                         if (pickedDateRange != null) {
//                           startDate =
//                               pickedDateRange!.startDate ?? DateTime.now();
//                           endDate = pickedDateRange!.endDate ?? DateTime.now();
//                           selectedDateRangeText =
//                               '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
//                           setState(() {
//                             selectedDateRangeText =
//                                 '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}';
//                           });
//                         }
//                       });
//                     },
//                     child: Column(
//                       children: [
//                         Text(
//                           'Select Date Range',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.orange.shade700,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           '(default: $pickerDateRange days)',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.orange.shade700,
//                             fontWeight: FontWeight.bold,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Text(
//                   //   selectedDateRangeText,
//                   //   textAlign: TextAlign.center,
//                   //   style: const TextStyle(
//                   //     color: Colors.black,
//                   //     fontWeight: FontWeight.bold,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
