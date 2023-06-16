import 'package:flutter/material.dart';

class CalendarScroll extends StatefulWidget {
  final Color color;
  const CalendarScroll({super.key, required this.color});

  @override
  State<CalendarScroll> createState() => _CalendarScrollState();
}

class _CalendarScrollState extends State<CalendarScroll> {
  String _getMonthAbbreviation(int month) {
    List<String> monthAbbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthAbbreviations[month - 1];
  }

  String _getWeekdayAbbreviation(int weekday) {
    List<String> weekdayAbbreviations = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekdayAbbreviations[weekday - 1];
  }

  DateTime date = DateTime.now();
  DateTime? selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
          child: SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 365,
              itemBuilder: (context, index) {
                DateTime indexDate = date.add(Duration(days: index));
                bool isSelected =
                    // check if they are the same date.
                    indexDate.day == selectedDate!.day &&
                        indexDate.month == selectedDate!.month &&
                        indexDate.year == selectedDate!.year;
                // date.add(Duration(days: index)).day == selectedDate?.day;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date.add(Duration(days: index));
                      // selectedDate = date;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Container(
                      width: 45,
                      decoration: BoxDecoration(
                        color: isSelected ? widget.color : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 7),
                          Text(
                              _getWeekdayAbbreviation(
                                  date.add(Duration(days: index)).weekday),
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12)),
                          Text(
                            '${date.add(Duration(days: index)).day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getMonthAbbreviation(
                                date.add(Duration(days: index)).month),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.grey[200],
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
