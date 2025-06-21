import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously (for testing/development)
  static Future<UserCredential?> signInAnonymously() async {
    try {
      MixologistLogger.info('🔓 Attempting anonymous sign-in');
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        MixologistLogger.logAuth('anonymous_signin', 
          userId: credential.user!.uid,
          success: true,
          extra: {'method': 'anonymous'}
        );
      }
      
      return credential;
    } catch (e) {
      MixologistLogger.logAuth('anonymous_signin', 
        success: false,
        extra: {'method': 'anonymous', 'error': e.toString()}
      );
      return null;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      MixologistLogger.info('🔍 Attempting Google sign-in');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        MixologistLogger.logAuth('google_signin', 
          success: false,
          extra: {'method': 'google', 'reason': 'user_cancelled'}
        );
        return null;
      }

      MixologistLogger.info('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        MixologistLogger.logAuth('google_signin', 
          userId: userCredential.user!.uid,
          userEmail: userCredential.user!.email,
          success: true,
          extra: {
            'method': 'google',
            'display_name': userCredential.user!.displayName,
            'email_verified': userCredential.user!.emailVerified
          }
        );
      }
      
      return userCredential;
    } catch (e) {
      MixologistLogger.logAuth('google_signin', 
        success: false,
        extra: {'method': 'google', 'error': e.toString()}
      );
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid;
      final userEmail = currentUser?.email;
      
      MixologistLogger.info('📤 Attempting sign out');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _auth.signOut();
      
      MixologistLogger.logAuth('signout', 
        userId: userId,
        userEmail: userEmail,
        success: true
      );
    } catch (e) {
      MixologistLogger.logAuth('signout', 
        success: false,
        extra: {'error': e.toString()}
      );
    }
  }

  // Get ID token for API authentication
  static Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        MixologistLogger.debug('🎫 ID token retrieved for user ${user.uid}');
        return token;
      }
      MixologistLogger.warning('⚠️ Attempted to get ID token but no user signed in');
      return null;
    } catch (e) {
      MixologistLogger.error('❌ Failed to get ID token', error: e, extra: {
        'user_id': _auth.currentUser?.uid,
        'operation': 'get_id_token'
      });
      return null;
    }
  }

  // Get user display name
  static String getUserDisplayName() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.displayName ?? user.email ?? 'Anonymous User';
    }
    return 'Guest';
  }

  // Get user email
  static String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user photo URL
  static String? getUserPhotoUrl() {
    return _auth.currentUser?.photoURL;
  }

  // Get user ID for backend requests
  static String? getUserId() {
    return _auth.currentUser?.uid;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Check if user is anonymous
  static bool isAnonymous() {
    final user = _auth.currentUser;
    return user?.isAnonymous ?? false;
  }
}