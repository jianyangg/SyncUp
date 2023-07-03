import 'package:flutter/material.dart';

class FacultyMaterials extends StatefulWidget {
  final String folderName;
  const FacultyMaterials({super.key, required this.folderName});

  @override
  State<FacultyMaterials> createState() => _FacultyMaterialsState();
}

class _FacultyMaterialsState extends State<FacultyMaterials> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: Center(
        child: Text("Faculty Materials"),
      ),
    );
  }
}
