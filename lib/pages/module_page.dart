import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModulePage extends StatefulWidget {
  final String folderName;
  final String moduleName;
  const ModulePage({
    Key? key,
    required this.folderName,
    required this.moduleName,
  }) : super(key: key);

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  late Future<List<Reference>> files;
  List<Reference> _filteredFiles = [];
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, double>> ratingsSnapshot;

  Future<Map<String, double>> fetchRatings(String folderName) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('ratings')
        .where('folderName', isEqualTo: folderName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> document = snapshot.docs[0];
      final Map<String, dynamic> moduleData =
          document.data()![widget.moduleName];

      Map<String, double> ratings = {};
      moduleData.forEach((key, value) {
        ratings[key] = value['rating'].toDouble();
      });

      // print(ratings);
      return ratings;
    }

    return {};
  }

  @override
  void initState() {
    super.initState();
    files = FirebaseStorage.instance
        .ref()
        .child("/academicDatabase/${widget.folderName}/${widget.moduleName}/")
        .listAll()
        .then((result) => result.items);
    ratingsSnapshot = fetchRatings(widget.folderName);
  }

  void _filterFiles(String searchText) async {
    List<Reference> filteredList = [];
    List<Reference> allFiles = await files;

    if (searchText.isNotEmpty) {
      filteredList = allFiles
          .where((file) =>
              file.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    } else {
      filteredList = List.from(allFiles);
    }

    setState(() {
      _filteredFiles = filteredList;
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
              "${widget.folderName} / ${widget.moduleName}",
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
                _filterFiles(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by file name',
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
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Reference>>(
              future: files,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final List<Reference> fileReferences =
                      _searchController.text.isEmpty
                          ? snapshot.data!
                          : _filteredFiles;
                  return FutureBuilder<Map<String, double>>(
                    future: ratingsSnapshot,
                    builder: (context, ratingsSnapshot) {
                      if (ratingsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (ratingsSnapshot.hasError) {
                        return Text(ratingsSnapshot.error.toString());
                      } else if (ratingsSnapshot.hasData) {
                        final ratings = ratingsSnapshot.data ?? {};
                        // print("this: $ratings");
                        final sortedFileReferences = fileReferences
                            .map((fileReference) => FileReferenceWithRating(
                                  fileReference: fileReference,
                                  rating: ratings[fileReference.name]! ?? 0,
                                ))
                            .toList()
                          ..sort((a, b) => b.rating.compareTo(a.rating));

                        return ListView.builder(
                          itemCount: sortedFileReferences.length,
                          itemBuilder: (context, index) {
                            final randomColor = Colors
                                .primaries[index % Colors.primaries.length]
                                .withOpacity(0.5);
                            final fileReference =
                                sortedFileReferences[index].fileReference;

                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () async {
                                    String url =
                                        await fileReference.getDownloadURL() ??
                                            '';
                                    try {
                                      await launchUrlString(url);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: randomColor,
                                    ),
                                    height: 80,
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    child: Center(
                                      child: ListTile(
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  fileReference.name,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontFamily: "Lato",
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              RatingBar.builder(
                                                initialRating: 0,
                                                minRating: 0,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 20.0,
                                                unratedColor: Colors.white
                                                    .withOpacity(0.2),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  // take the current ratings and calculate the average rating with the new rating
                                                  // then store the new average rating in the database
                                                  FirebaseFirestore.instance
                                                      .collection('ratings')
                                                      .where('folderName',
                                                          isEqualTo:
                                                              widget.folderName)
                                                      .get()
                                                      .then((snapshot) {
                                                    if (snapshot
                                                        .docs.isNotEmpty) {
                                                      // should only be one document
                                                      final doc =
                                                          snapshot.docs.first;
                                                      final currentRating =
                                                          doc[widget.moduleName]
                                                                  [fileReference
                                                                      .name]
                                                              ['rating'];
                                                      final currentNumberOfRatings =
                                                          doc[widget.moduleName]
                                                                  [fileReference
                                                                      .name]
                                                              ['raters'];
                                                      final tempMap = doc[
                                                          widget.moduleName];
                                                      double newRating;
                                                      int newNumberOfRatings;

                                                      if (currentRating ==
                                                              null ||
                                                          currentNumberOfRatings ==
                                                              null) {
                                                        // aka 0
                                                        newRating =
                                                            rating.toDouble();
                                                        newNumberOfRatings = 1;
                                                      } else {
                                                        newRating = (currentRating *
                                                                    currentNumberOfRatings +
                                                                rating) /
                                                            (currentNumberOfRatings +
                                                                1);
                                                        newNumberOfRatings =
                                                            currentNumberOfRatings +
                                                                1;
                                                      }

                                                      tempMap[fileReference
                                                              .name]['rating'] =
                                                          newRating;
                                                      tempMap[fileReference
                                                              .name]['raters'] =
                                                          newNumberOfRatings;
                                                      // update the database
                                                      doc.reference.update({
                                                        widget.moduleName:
                                                            tempMap,
                                                      });

                                                      setState(() {
                                                        ratings[fileReference
                                                            .name] = newRating;
                                                      });
                                                      // print(ratings);
                                                    }
                                                  });
                                                  // inform user using dialog that the current file name has been rated as $rating
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Rating",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        content: Text(
                                                          "You have rated ${fileReference.name} as ${rating.toStringAsFixed(1)}.",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        subtitle:
                                            FutureBuilder<Map<String, dynamic>>(
                                          future:
                                              fetchRatings(widget.folderName),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const SizedBox();
                                            } else if (snapshot.hasError) {
                                              return const Text(
                                                'Error retrieving rating',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              );
                                            } else if (snapshot.hasData) {
                                              final ratings = snapshot.data!;
                                              final moduleRating =
                                                  ratings[fileReference.name];

                                              if (moduleRating == null) {
                                                return const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 3.0),
                                                  child: Text(
                                                    'No rating',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0),
                                                  child: Text(
                                                    'Current Rating: ${moduleRating.toStringAsFixed(1)} / 5.0',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              return const SizedBox();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FileReferenceWithRating {
  final Reference fileReference;
  final double rating;

  FileReferenceWithRating({
    required this.fileReference,
    required this.rating,
  });
}
