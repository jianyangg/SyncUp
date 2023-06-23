import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        scopes: [CalendarApi.calendarScope],
      ).signIn();

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // Create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Add Firebase Auth to Cloud Firestore
      final db = FirebaseFirestore.instance;
      final res = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = res.user;
      final userRef = db.collection('users').doc(user!.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'email': user.email,
          'name': user.displayName,
          'photoUrl': user.photoURL,
          'createdAt': DateTime.now(),
          'groups': [], // Create empty groups array
        });
        return res;
      }
    } catch (e) {
      print(e);
    }
  }
}
