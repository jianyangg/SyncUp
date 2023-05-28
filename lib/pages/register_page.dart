import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sync_up/components/signIn_signUp_button.dart';

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
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
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
                      color: Colors.white,
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
                Text(
                  '< SyncUp >',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 90,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'an Orbital project',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Courier New',
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Padding(
                  // set input text to be white
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: 'Email (i.e., e1234567@u.nus.edu)',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 115, 115, 115),
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  // set input text to be white
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: _passwordVisible1,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 115, 115, 115),
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromARGB(255, 115, 115, 115),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _passwordVisible1 = !_passwordVisible1;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // for confirming password
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  // set input text to be white
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: TextField(
                        controller: cfmPasswordController,
                        obscureText: _passwordVisible2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 115, 115, 115),
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromARGB(255, 115, 115, 115),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _passwordVisible2 = !_passwordVisible2;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
