import 'package:flutter/material.dart';
import 'package:sync_up/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      theme: ThemeData(
        primaryColor: Colors.blue.shade800,
        primaryColorLight: Colors.blue.shade700,
        highlightColor: Colors.red,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.blue.shade800,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }
}
