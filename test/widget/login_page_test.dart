import 'package:flutter/material.dart';
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

  setUp(() {
    authBloc = AuthBloc(FakeAuthRepository());
    documentBloc = DocumentBloc(FakeDocumentRepository());
    profileBloc = ProfileBloc(FakeAuthRepository());
  });

  tearDown(() {
    authBloc.close();
    documentBloc.close();
    profileBloc.close();
  });

  testWidgets('affiche le logo, le titre et le bouton Google', (tester) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/login',
    ));
    await settleWithPumps(tester);

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(
      find.text('Connectez-vous pour retrouver vos documents perdus au Congo'),
      findsOneWidget,
    );
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.textContaining('J\'accepte les conditions'), findsOneWidget);
  });

  testWidgets('bouton désactivé tant que les conditions ne sont pas acceptées',
      (tester) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/login',
    ));
    await settleWithPumps(tester);

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Continuer avec Google'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await settleWithPumps(tester);

    final enabledButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Continuer avec Google'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('navigue vers Home après une connexion Google réussie',
      (tester) async {
    final fake = FakeAuthRepository();
    fake.signInUser = sampleUser();
    authBloc = AuthBloc(fake);

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/login',
    ));
    await settleWithPumps(tester);

    await tester.tap(find.byType(Checkbox));
    await settleWithPumps(tester);
    await tester.tap(find.text('Continuer avec Google'));
    await settleWithPumps(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Bonjour, Jean Congo'), findsOneWidget);
  });

  testWidgets("affiche un message d'erreur si la connexion échoue",
      (tester) async {
    final fake = FakeAuthRepository();
    fake.throwOnSignIn = true;
    authBloc = AuthBloc(fake);

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/login',
    ));
    await settleWithPumps(tester);

    await tester.tap(find.byType(Checkbox));
    await settleWithPumps(tester);
    await tester.tap(find.text('Continuer avec Google'));
    await settleWithPumps(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('signin failed'), findsOneWidget);
  });
}
