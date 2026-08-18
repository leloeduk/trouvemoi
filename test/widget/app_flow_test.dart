import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/home/presentation/pages/home_page.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';

import '../helpers/fakes.dart';
import '../helpers/widget_harness.dart';

void main() {
  late AuthBloc authBloc;
  late DocumentBloc documentBloc;
  late ProfileBloc profileBloc;

  tearDown(() {
    authBloc.close();
    documentBloc.close();
    profileBloc.close();
  });

  testWidgets('parcours non authentifié : splash puis redirection vers login',
      (tester) async {
    authBloc = AuthBloc(FakeAuthRepository());
    documentBloc = DocumentBloc(FakeDocumentRepository());
    profileBloc = ProfileBloc(FakeAuthRepository());

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/splash',
    ));

    // Le splash est visible au premier rendu
    await tester.pump();
    expect(find.text('Trouve Moi'), findsOneWidget);

    // L'état non authentifié redirige vers /login
    await settleWithPumps(tester);
    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('parcours authentifié : splash puis redirection vers home',
      (tester) async {
    authBloc = AuthBloc(FakeAuthRepository(user: sampleUser()));
    documentBloc = DocumentBloc(FakeDocumentRepository());
    profileBloc = ProfileBloc(FakeAuthRepository(user: sampleUser()));

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/splash',
    ));

    await tester.pump();
    expect(find.text('Trouve Moi'), findsOneWidget);

    await settleWithPumps(tester);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Bonjour, Jean Congo'), findsOneWidget);
  });

  testWidgets('les routes protégées redirigent vers login si non authentifié',
      (tester) async {
    authBloc = AuthBloc(FakeAuthRepository());
    documentBloc = DocumentBloc(FakeDocumentRepository());
    profileBloc = ProfileBloc(FakeAuthRepository());

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/home',
    ));

    await settleWithPumps(tester);

    expect(find.byType(HomePage), findsNothing);
    expect(find.text('Bienvenue'), findsOneWidget);
  });
}
