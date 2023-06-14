import "package:flutter/material.dart";
import "package:sync_up/components/reset_pass_button.dart";
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            'Password reset email sent to ${emailController.text.trim()}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Center(child: Text('OK')),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
            e.message.toString(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Center(child: Text('OK')),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Password Reset', style: TextStyle(color: Colors.white)),
        // backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your email for password reset.',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  // set input text to be white
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                          color: const Color.fromARGB(255, 197, 197, 197)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 115, 115, 115),
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ResetPassButton(
                  onTap: passwordReset,
                  text: "Reset Password",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
