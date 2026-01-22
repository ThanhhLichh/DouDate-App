import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Sign in with Google and return Firebase ID Token
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('Google Sign In cancelled by user');
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // Get Firebase ID Token (THIS is what we send to backend)
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get ID token from Firebase');
      }

      debugPrint('Google Sign In successful');
      debugPrint('Firebase ID Token obtained');

      return idToken;
    } catch (e) {
      debugPrint('Error during Google Sign In: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);
      debugPrint('Google Sign Out successful');
    } catch (e) {
      debugPrint('Error during Google Sign Out: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in with Google
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get current user info
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
