import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_event.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/fakes.dart';

void main() {
  final user = sampleUser();

  group('AuthBloc - état initial', () {
    test('commence en AuthStatus.unknown', () {
      final bloc = AuthBloc(FakeAuthRepository());
      expect(bloc.state.status, AuthStatus.unknown);
      bloc.close();
    });
  });

  group('AuthBloc - AuthSubscriptionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet unauthenticated quand aucun utilisateur est connecté',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(AuthSubscriptionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'émet authenticated quand un utilisateur est déjà connecté',
      build: () => AuthBloc(FakeAuthRepository(user: user)),
      act: (bloc) => bloc.add(AuthSubscriptionRequested()),
      expect: () => [AuthState.authenticated(user)],
    );

    test('réagit aux changements du stream authStateChanges', () async {
      final repo = FakeAuthRepository();
      final bloc = AuthBloc(repo);
      final states = <AuthStatus>[];

      final sub = bloc.stream.listen((s) => states.add(s.status));
      bloc.add(AuthSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);

      repo.emitUser(user);
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        AuthStatus.unauthenticated,
        AuthStatus.authenticated,
      ]);

      await sub.cancel();
      repo.dispose();
      await bloc.close();
    });
  });

  group('AuthBloc - GoogleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet authenticated quand la connexion Google réussit',
      build: () => AuthBloc(FakeAuthRepository(user: user)),
      act: (bloc) => bloc.add(GoogleSignInRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'émet une erreur quand la connexion Google échoue',
      build: () {
        final repo = FakeAuthRepository();
        repo.throwOnSignIn = true;
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(GoogleSignInRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', false).having(
            (s) => s.errorMessage, 'errorMessage', contains('signin failed')),
      ],
    );
  });

  group('AuthBloc - SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet unauthenticated après la déconnexion',
      build: () => AuthBloc(FakeAuthRepository(user: user)),
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'émet une erreur si la déconnexion échoue',
      build: () {
        final repo = FakeAuthRepository(user: user);
        repo.throwOnSignOut = true;
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [
        isA<AuthState>().having(
            (s) => s.errorMessage, 'errorMessage', contains('signout failed')),
      ],
    );
  });
}
