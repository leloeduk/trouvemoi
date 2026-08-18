import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc(this._authRepository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        // TODO: Récupérer les statistiques depuis Firestore
        emit(ProfileLoaded(
          user: user,
          documentsFound: 5,
          documentsLost: 2,
        ));
      } else {
        emit(ProfileError('Utilisateur non connecté'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // TODO: Mettre à jour le profil dans Firestore
      emit(ProfileUpdated('Profil mis à jour avec succès'));
      add(LoadProfileEvent());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
