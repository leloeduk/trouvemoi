import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String displayName;
  final String phone;

  UpdateProfileEvent({
    required this.displayName,
    required this.phone,
  });

  @override
  List<Object?> get props => [displayName, phone];
}
