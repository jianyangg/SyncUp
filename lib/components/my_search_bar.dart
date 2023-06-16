import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const MySearchBar({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextField(
          autofocus: true,
          controller: widget.controller, // prop #1
          style: const TextStyle(color: Colors.black, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText, //prop #2
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 115, 115, 115),
            ),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 197, 197, 197))),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.lightBlueAccent)),
            prefixIcon: Visibility(
              child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 115, 115, 115),
                  ),
                  onPressed: () {}),
            ),
          ),
        ),
      ),
    );
  }
}
