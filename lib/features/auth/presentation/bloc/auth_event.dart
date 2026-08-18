import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Écouter les changements d'état d'authentification
class AuthSubscriptionRequested extends AuthEvent {}

// Connexion avec Google
class GoogleSignInRequested extends AuthEvent {}

// Déconnexion
class SignOutRequested extends AuthEvent {}
