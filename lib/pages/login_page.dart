import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sync_up/components/my_textfield.dart';
import 'package:sync_up/components/signIn_signUp_button.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sync_up/pages/forgot_password_page.dart';
import 'package:sync_up/services/google_auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  Future<bool> isUserSignedIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();

    // Check if the user is currently signed in
    bool isSignedIn = await googleSignIn.isSignedIn();

    return isSignedIn;
  }

  // add sign user in method
  void signUserIn() async {
    // show loading
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      // show error message
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    String errorType = message == 'user-not-found' ? 'email' : 'password';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid $errorType'),
          content: Text('Please enter a valid $errorType.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  // logo
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.calendar_today,
                  //       color: Colors.orange,
                  //       size: 110,
                  //     ),
                  //     Icon(
                  //       Icons.sync,
                  //       color: Colors.black,
                  //       size: 40,
                  //     ),
                  //     Icon(
                  //       Icons.calendar_today,
                  //       color: Color.fromARGB(255, 0, 126, 228),
                  //       size: 110,
                  //     ),
                  //   ],
                  // ),
                  // replace with image
                  Image.asset(
                    'lib/assets/icon.png',
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SyncUp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 40,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 30),
                  // //email textfield
                  // MyTextField(
                  //     controller: emailController,
                  //     hintText: "Email (e.g., e1234567@u.nus.edu)",
                  //     obscureText: false,
                  //     isPassword: false),

                  // const SizedBox(
                  //   height: 30,
                  // ),

                  // //password textfield
                  // MyTextField(
                  //     controller: passwordController,
                  //     hintText: "Password",
                  //     obscureText: true,
                  //     isPassword: true),

                  // const SizedBox(
                  //   height: 30,
                  // ),
                  // SignInOrSignUpButton(
                  //   text: 'Sign in',
                  //   onPressed: signUserIn,
                  // ),
                  // const SizedBox(
                  //   // forgot password
                  //   height: 25,
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => const ForgotPasswordPage()));
                  //   },
                  //   child: const Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 40),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Text(
                  //           'Forgot password?',
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //             fontSize: 15,
                  //             fontFamily: 'Arial',
                  //             fontStyle: FontStyle.italic,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  // // sign up link
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       const Text(
                  //         "Don't have an account?",
                  //         style: TextStyle(
                  //           color: Color.fromARGB(255, 115, 115, 115),
                  //           fontSize: 15,
                  //           fontFamily: 'Arial',
                  //           fontStyle: FontStyle.italic,
                  //         ),
                  //       ),
                  //       GestureDetector(
                  //         onTap: widget.onTap,
                  //         child: const Text(
                  //           ' Sign up here!',
                  //           style: TextStyle(
                  //             fontFamily: 'Arial',
                  //             fontSize: 15,
                  //             color: Colors.black, fontStyle: FontStyle.italic,
                  //             // fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  // const Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 10),
                  //       child: Text(
                  //         'alternative options',
                  //         style: TextStyle(
                  //             color: Color.fromARGB(255, 134, 134, 134),
                  //             fontStyle: FontStyle.italic),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: SignInButton(
                      padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                      Buttons.Google,
                      elevation: 2,
                      onPressed: () async {
                        // upon log in, we want to save the user's calendar to firestore
                        // this method will be done here once login is complete
                        GoogleAuthService().signInWithGoogle();
                      },
                      text: "Sign in with Google",
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
