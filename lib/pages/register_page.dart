import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/components/signIn_signUp_button.dart';

import '../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;

  // add sign user in method
  void signUserUp() async {
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
      if (passwordController.text != cfmPasswordController.text) {
        Navigator.pop(context);
        showErrorMessage('Passwords don\'t match');
        return;
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    String errorType = message == 'user-not-found'
        ? 'Invalid email'
        : message == 'wrong-password'
            ? 'Invalid password'
            : message;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(errorType),
          content: errorType == 'Passwords don\'t match'
              ? const Text('Please enter matching passwords.')
              : Text('Please enter a valid $errorType.'),
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
  final cfmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    cfmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible1 = true;
    _passwordVisible2 = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 20),
                const Text(
                  'SyncUp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 90,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                MyTextField(
                    controller: emailController,
                    hintText: "Email (e.g., e1234567@u.nus.edu)",
                    obscureText: false,
                    isPassword: false),
                const SizedBox(
                  height: 30,
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: _passwordVisible1,
                  isPassword: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                MyTextField(
                  controller: cfmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: _passwordVisible2,
                  isPassword: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                // forgot password
                SignInOrSignUpButton(
                  text: 'Sign Up',
                  onPressed: signUserUp,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Already have an account?",
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
                          ' Login!',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: Colors.black,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(
                //   height: 30,
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
                //             color: Colors.white, fontStyle: FontStyle.italic),
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
                // SignInButton(
                //   padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                //   Buttons.Google,
                //   onPressed: () {},
                //   text: "Sign up with Google",
                // ),
                // const SizedBox(
                //   height: 7,
                // ),
                // SignInButton(
                //   padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                //   Buttons.AppleDark,
                //   onPressed: () {},
                //   text: "Sign up with Apple",
                // ),
                // const SizedBox(
                //   height: 7,
                // ),
              ],
            ),
          ),
        ),
        // sign in button
        // google or apple sign in button
      ),
    );
  }
}
