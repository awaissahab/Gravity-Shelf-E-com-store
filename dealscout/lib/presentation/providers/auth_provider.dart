import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(const AuthState.initial()) {
    _initAuthState();
  }

  void _initAuthState() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      state = const AuthState.loading();
      
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        state = AuthState.authenticated(
          user: _auth.currentUser!,
          userData: data,
        );
      } else {
        state = AuthState.error('User data not found');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = const AuthState.loading();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_handleAuthError(e));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    try {
      state = const AuthState.loading();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'preferences': {
          'categories': [],
          'brands': [],
          'maxDistance': 10,
        },
        'gamification': {
          'coins': 0,
          'streak': 0,
          'level': 1,
          'achievements': [],
        },
        'role': 'user',
      });

      await _loadUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(_handleAuthError(e));
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    // Implementation for Google Sign-In
    // Requires google_sign_in package
    try {
      state = const AuthState.loading();
      // Google sign-in implementation here
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    // Implementation for Apple Sign-In
    try {
      state = const AuthState.loading();
      // Apple sign-in implementation here
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}

/// Authentication state
class AuthState {
  final bool isLoading;
  final User? user;
  final Map<String, dynamic>? userData;
  final String? error;
  final bool isAuthenticated;

  const AuthState._({
    required this.isLoading,
    this.user,
    this.userData,
    this.error,
    required this.isAuthenticated,
  });

  const AuthState.initial() : this._(isLoading: false, isAuthenticated: false);
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
  
  factory AuthState.authenticated({
    required User user,
    required Map<String, dynamic> userData,
  }) {
    return AuthState._(
      isLoading: false,
      user: user,
      userData: userData,
      isAuthenticated: true,
    );
  }
  
  factory AuthState.error(String message) {
    return AuthState._(
      isLoading: false,
      error: message,
      isAuthenticated: false,
    );
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(FirebaseAuth.instance, FirebaseFirestore.instance);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// User data provider
final userDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).userData;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
