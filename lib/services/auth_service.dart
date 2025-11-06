import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  GoogleSignIn _createFreshGoogleSignIn() {
    return GoogleSignIn(
      serverClientId: '804464780497-mert1d3i9bcvvd9ur0gk8jd6dc7q5lb7.apps.googleusercontent.com',
      forceCodeForRefreshToken: true,
      signInOption: SignInOption.standard,
      scopes: ['openid', 'email', 'profile'],
    );
  }
  
  GoogleSignIn get _googleSignIn => _createFreshGoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = _googleSignIn;
      
      print('🔄 Clear cache...');
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        print('Info: $e');
      }
      
      try {
        await _auth.signOut();
      } catch (e) {
        print('Info: $e');
      }
      
      await Future.delayed(const Duration(seconds: 2));

      print('📱 Signing in...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Cancelled');
        return null;
      }

      print('✅ ${googleUser.email}');

      print('🔐 Getting tokens...');
      await Future.delayed(const Duration(seconds: 2));
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('No tokens');
        return null;
      }

      print('✅ Firebase auth...');
      try {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          await _saveUserData(user);
          print('✅✅✅ LOGIN: ${user.email}');
          return user;
        }
      } catch (firebaseError) {
        print('Firebase error: $firebaseError');
        
        if (firebaseError.toString().contains('stale')) {
          print('ERROR: Google account has stale cached token on server');
          print('SOLUTION: Use the working account or clear Google cache');
          return null;
        }
        rethrow;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('Auth error [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails')) {
        final User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _saveUserData(currentUser);
          print('✅✅✅ ${currentUser.email}');
          return currentUser;
        }
      }
      
      print('Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final googleSignIn = _googleSignIn;
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
      print('Signed out');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<void> refreshUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        print('Token refreshed');
      }
    } catch (e) {
      print('Refresh error: $e');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_name', user.displayName ?? '');
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_photo_url', user.photoURL ?? '');
    } catch (e) {
      print('Save error: $e');
    }
  }

  Future<String?> getUserPhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_photo_url');
    } catch (e) {
      print('Photo error: $e');
      return null;
    }
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo_url', photoUrl);
    } catch (e) {
      print('Update photo error: $e');
    }
  }

  Future<String?> getUserMobileNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_mobile');
    } catch (e) {
      print('Mobile error: $e');
      return null;
    }
  }

  Future<void> updateUserMobileNumber(String mobileNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_mobile', mobileNumber);
      print('Mobile updated: $mobileNumber');
    } catch (e) {
      print('Mobile update error: $e');
    }
  }
}
