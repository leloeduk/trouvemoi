import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_event.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_state.dart';

import '../helpers/fakes.dart';

void main() {
  group('ProfileBloc - LoadProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'émet ProfileLoaded avec lutilisateur connecté',
      build: () => ProfileBloc(FakeAuthRepository(user: sampleUser())),
      act: (bloc) => bloc.add(LoadProfileEvent()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having(
            (s) => s.user.displayName, 'user.displayName', 'Jean Congo'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'émet ProfileError si aucun utilisateur est connecté',
      build: () => ProfileBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(LoadProfileEvent()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('non connecté'),
        ),
      ],
    );
  });

  group('ProfileBloc - UpdateProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'émet ProfileUpdated puis recharge le profil',
      build: () => ProfileBloc(FakeAuthRepository(user: sampleUser())),
      act: (bloc) => bloc.add(
        UpdateProfileEvent(displayName: 'Jean', phone: '061234567'),
      ),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileUpdated>().having(
          (s) => s.message,
          'message',
          contains('mis à jour'),
        ),
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
    );
  });
}
