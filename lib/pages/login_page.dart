import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

      // if (e.code == 'user-not-found') {
      //   wrongEmailNotif();
      // } else if (e.code == 'wrong-password') {
      //   wrongPasswordNotif();
      // }
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
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // logo
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                      size: 110,
                    ),
                    Icon(
                      Icons.sync,
                      color: Colors.black,
                      size: 40,
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(255, 0, 126, 228),
                      size: 110,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'SyncUp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 70,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                //email textfield
                MyTextField(
                    controller: emailController,
                    hintText: "Email (e.g., e1234567@u.nus.edu)",
                    obscureText: false,
                    isPassword: false),

                const SizedBox(
                  height: 30,
                ),

                //password textfield
                MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    isPassword: true),

                const SizedBox(
                  height: 30,
                ),
                SignInOrSignUpButton(
                  text: 'Sign in',
                  onPressed: signUserIn,
                ),
                const SizedBox(
                  // forgot password
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Arial',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                // sign up link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 115, 115, 115),
                          fontSize: 15,
                          fontFamily: 'Arial',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          ' Sign up here!',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 15,
                            color: Colors.black, fontStyle: FontStyle.italic,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'alternative options',
                        style: TextStyle(
                            color: Colors.black, fontStyle: FontStyle.italic),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SignInButton(
                  padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                  Buttons.Google,
                  elevation: 1,
                  onPressed: () => GoogleAuthService().signInWithGoogle(),
                  text: "Sign in with Google",
                ),
                // const SizedBox(
                //   height: 7,
                // ),
                // SignInButton(
                //   padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                //   Buttons.AppleDark,
                //   onPressed: () {},
                //   text: "Sign in with Apple",
                // ),
                const SizedBox(
                  height: 7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
