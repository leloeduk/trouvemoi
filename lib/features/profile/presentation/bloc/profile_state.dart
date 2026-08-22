import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;

  ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final String message;
  ProfileUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
