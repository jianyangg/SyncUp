import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  bool obscureText;

  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.isPassword,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
                controller: widget.controller, // prop #1
                obscureText: widget.obscureText,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                    hintText: widget.hintText, //prop #2
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 115, 115, 115),
                    ),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 197, 197, 197))),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.lightBlueAccent)),
                    suffixIcon: Visibility(
                      visible: widget.isPassword,
                      child: IconButton(
                          icon: Icon(
                            widget.obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color.fromARGB(255, 115, 115, 115),
                          ),
                          onPressed: () {
                            setState(() {
                              widget.obscureText = !widget.obscureText;
                            });
                          }),
                    )))));
  }
}
