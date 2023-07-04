import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/module_page.dart';

class FacultyMaterials extends StatefulWidget {
  final String folderName;
  const FacultyMaterials({super.key, required this.folderName});

  @override
  State<FacultyMaterials> createState() => _FacultyMaterialsState();
}

class _FacultyMaterialsState extends State<FacultyMaterials> {
  late Future<List<String>> _moduleFolders;

  @override
  void initState() {
    super.initState();
    _moduleFolders = FirebaseStorage.instance
        .ref()
        .child('academicDatabase/${widget.folderName}/')
        .listAll()
        .then((result) => result.prefixes.map((e) => e.name).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.blue.shade800,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              widget.folderName,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      body: Expanded(
        child: FutureBuilder<List<String>>(
          future: _moduleFolders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Color randomColor = Colors
                      .primaries[Random().nextInt(Colors.primaries.length)];
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          color: randomColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: ListTile(
                            title: Text(
                              snapshot.data![index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModulePage(
                                      folderName: widget.folderName,
                                      moduleName: snapshot.data![index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
