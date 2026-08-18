import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc(this._authRepository, {AuthState? initialState})
      : super(initialState ?? const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
    on<_AuthStateChanged>(_onAuthStateChanged);
  }

  // ✅ Écouter les changements d'état de Firebase
  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Annuler l'ancien subscription s'il existe
    await _authSubscription?.cancel();

    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          add(_AuthStateChanged(AuthState.authenticated(user)));
        } else {
          add(_AuthStateChanged(AuthState.unauthenticated()));
        }
      },
      onError: (error) {
        add(_AuthStateChanged(const AuthState.unauthenticated()));
      },
    );

    // Vérifier l'état actuel immédiatement
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthState.authenticated(currentUser));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  // ✅ Event interne pour gérer les changements d'état
  Future<void> _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(event.state);
  }

  // Connexion Google
  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // Déconnexion
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

// ✅ Event interne pour les changements d'état
class _AuthStateChanged extends AuthEvent {
  final AuthState state;
  _AuthStateChanged(this.state);

  @override
  List<Object?> get props => [state];
}
