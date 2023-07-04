import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  @override
  void initState() {
    super.initState();
    files = FirebaseStorage.instance
        .ref()
        .child("/academicDatabase/${widget.folderName}/${widget.moduleName}/")
        .listAll()
        .then((result) => result.items);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      extendBody: true,
      body: FutureBuilder<List<Reference>>(
        future: files,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final fileReferences = snapshot.data!;
            return ListView.builder(
              itemCount: fileReferences.length,
              itemBuilder: (context, index) {
                final randomColor = Colors
                    .primaries[index % Colors.primaries.length]
                    .withOpacity(0.5);
                final fileReference = fileReferences[index];
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: randomColor,
                      ),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Center(
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
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
                          onTap: () async {
                            String url =
                                await fileReference.getDownloadURL() ?? '';
                            print(url);
                            // launchUrlString(url);
                            try {
                              await launchUrlString(url);
                            } catch (e) {
                              print(e);
                            }
                          },
                          trailing: const Icon(
                            Icons.star,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
