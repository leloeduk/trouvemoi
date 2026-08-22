import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user_model.dart';

class UserFirebaseService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserFirebaseService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream des changements d'état de connexion
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final user = UserModel.fromFirebaseUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );

      // Créer/mettre à jour le user dans Firestore à chaque changement
      await _createOrUpdateUserInFirestore(user);

      return user;
    });
  }

  // Créer ou mettre à jour le user dans Firestore
  Future<void> _createOrUpdateUserInFirestore(UserModel user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        await userDoc.update({
          'displayName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.set({
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du user: $e');
    }
  }

  // Récupérer l'utilisateur actuel
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  // Connexion Google (Web + Mobile)
  Future<UserModel> signInWithGoogle() async {
    try {
      UserModel user;

      if (kIsWeb) {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception('Connexion annulée');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;

        user = UserModel.fromFirebaseUser(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception('Connexion annulée');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;

        user = UserModel.fromFirebaseUser(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );
      }

      // ✅ Créer/mettre à jour le user dans Firestore
      await _createOrUpdateUserInFirestore(user);

      return user;
    } catch (e) {
      throw Exception(
          'Échec de la connexion Google peut-etre votre connexion est interrompue : $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }
}
