import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/module_page.dart';

class FacultyMaterials extends StatefulWidget {
  final String folderName;

  const FacultyMaterials({Key? key, required this.folderName})
      : super(key: key);

  @override
  State<FacultyMaterials> createState() => _FacultyMaterialsState();
}

class _FacultyMaterialsState extends State<FacultyMaterials> {
  late Future<List<String>> _moduleFolders;
  List<String> _filteredModuleFolders = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _moduleFolders = FirebaseStorage.instance
        .ref()
        .child('academicDatabase/${widget.folderName}/')
        .listAll()
        .then((result) => result.prefixes.map((e) => e.name).toList());
  }

  void _filterModuleFolders(String searchText) async {
    List<String> filteredList = [];
    List<String> moduleFolders = await _moduleFolders;

    if (searchText.isNotEmpty) {
      filteredList = moduleFolders
          .where((folder) =>
              folder.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    } else {
      filteredList = List.from(moduleFolders);
    }

    setState(() {
      _filteredModuleFolders = filteredList;
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _filterModuleFolders(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by module code',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                )),
          ),
          Expanded(
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
                  final List<String> moduleFolders =
                      _searchController.text.isEmpty
                          ? snapshot.data!
                          : _filteredModuleFolders;
                  return ListView.builder(
                    itemCount: moduleFolders.length,
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
                                  moduleFolders[index],
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
                                        moduleName: moduleFolders[index],
                                      ),
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
        ],
      ),
    );
  }
}
