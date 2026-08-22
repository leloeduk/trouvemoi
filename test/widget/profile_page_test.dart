import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_state.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';

import '../helpers/fakes.dart';
import '../helpers/widget_harness.dart';

void main() {
  (AuthBloc, DocumentBloc, ProfileBloc) createBlocs({
    FakeAuthRepository? authRepository,
  }) {
    final repo = authRepository ?? FakeAuthRepository(user: sampleUser());
    final authBloc = authenticatedAuthBloc(user: sampleUser());
    final documentBloc = DocumentBloc(FakeDocumentRepository());
    final profileBloc = ProfileBloc(repo);
    addTearDown(() {
      authBloc.close();
      documentBloc.close();
      profileBloc.close();
    });
    return (authBloc, documentBloc, profileBloc);
  }

  Future<void> pumpProfile(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required DocumentBloc documentBloc,
    required ProfileBloc profileBloc,
  }) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/profile',
    ));
    await settleWithPumps(tester);
  }

  testWidgets('affiche les informations du profil', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpProfile(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.text('Mon Profil'), findsOneWidget);
    expect(find.text('Jean Congo'), findsOneWidget);
    expect(find.text('jean@example.com'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });

  testWidgets('ouvre la boîte de dialogue de déconnexion', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpProfile(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.pump();
    await tester.tap(find.text('Se déconnecter'));
    await settleWithPumps(tester);

    expect(find.text('Déconnexion'), findsWidgets);
    expect(
      find.text('Voulez-vous vraiment vous déconnecter ?'),
      findsOneWidget,
    );
  });

  testWidgets('se déconnecte et redirige vers login', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpProfile(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.pump();
    await tester.tap(find.text('Se déconnecter'));
    await settleWithPumps(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Déconnexion'));
    await settleWithPumps(tester);

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(authBloc.state.status, isNot(AuthStatus.authenticated));
  });
}
