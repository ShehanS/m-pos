// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../entities/user_entity.dart';

typedef AuthResult = Either<String, UserEntity>;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  UserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  // Functional: sign in with email
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final userData = await _getUserFromFirestore(user.uid);
      return Right(userData ?? _userFromFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    } catch (e) {
      return Left('An unexpected error occurred');
    }
  }

  // Functional: register with email
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Check username uniqueness
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return const Left('Username already taken');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(username);

      final fcmToken = await _getFcmToken();

      final userModel = UserEntity(
        uid: user.uid,
        email: email.trim(),
        username: username,
        displayName: username,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      await _saveUserToFirestore(userModel);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    } catch (e) {
      return Left('Registration failed: ${e.toString()}');
    }
  }

  // Functional: Google sign in
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final fcmToken = await _getFcmToken();

      UserEntity? existingUser = await _getUserFromFirestore(user.uid);
      if (existingUser == null) {
        final newUser = UserEntity(
          uid: user.uid,
          email: user.email ?? '',
          username: user.displayName?.replaceAll(' ', '_').toLowerCase(),
          displayName: user.displayName,
          photoUrl: user.photoURL,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          fcmToken: fcmToken,
        );
        await _saveUserToFirestore(newUser);
        return Right(newUser);
      }
      return Right(existingUser);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    } catch (e) {
      return Left('Google sign in failed: ${e.toString()}');
    }
  }

  // Functional: sign out
  Future<Either<String, Unit>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(unit);
    } catch (e) {
      return Left('Sign out failed: ${e.toString()}');
    }
  }

  // Functional: password reset
  Future<Either<String, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    }
  }

  // Functional: update profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Left('Not authenticated');

      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);

      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      final updated = UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName,
        photoUrl: photoUrl ?? user.photoURL,
        emailVerified: user.emailVerified,
      );
      return Right(updated);
    } catch (e) {
      return Left('Profile update failed: ${e.toString()}');
    }
  }

  // Private helpers
  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserEntity.fromFirestore(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUserToFirestore(UserEntity user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  UserEntity _userFromFirebaseUser(User user) {
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  Future<String?> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
