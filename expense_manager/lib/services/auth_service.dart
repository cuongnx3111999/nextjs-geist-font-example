import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to our custom UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    
    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      createdAt: DateTime.now(), // For new users
      lastLoginAt: DateTime.now(),
    );
  }

  // Auth state changes stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An error occurred while signing in.';
      }
      throw Exception(message);
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    {String? displayName}
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      
      if (user != null && displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An error occurred while registering.';
      }
      throw Exception(message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out');
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        default:
          message = 'An error occurred while sending password reset email.';
      }
      throw Exception(message);
    }
  }

  // Get current user
  UserModel? get currentUser {
    final User? user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }

  // Update user profile
  Future<void> updateProfile({String? displayName}) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
      }
    } catch (e) {
      throw Exception('Error updating profile');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate user before changing password
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The new password is too weak.';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before changing your password.';
          break;
        default:
          message = 'An error occurred while changing password.';
      }
      throw Exception(message);
    }
  }
}
