import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  signInWithGoogle() async {
    try {
      // begin interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        scopes: [CalendarApi.calendarScope],
      ).signIn();
      // obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      // create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // finally, sign in.
      return await FirebaseAuth.instance.signInWithCredential(credential);
      // add firebase auth to cloud_firestore
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
          // create empty groups array
          'groups': [],
        });
      }
      // return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }
}
