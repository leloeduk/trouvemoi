import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';

import '../helpers/fakes.dart';
import '../helpers/widget_harness.dart';

void main() {
  (AuthBloc, DocumentBloc, ProfileBloc) createBlocs() {
    final authBloc = authenticatedAuthBloc(user: sampleUser());
    final documentBloc = DocumentBloc(FakeDocumentRepository());
    final profileBloc = ProfileBloc(FakeAuthRepository(user: sampleUser()));
    addTearDown(() {
      authBloc.close();
      documentBloc.close();
      profileBloc.close();
    });
    return (authBloc, documentBloc, profileBloc);
  }

  Future<void> pumpAddPage(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required DocumentBloc documentBloc,
    required ProfileBloc profileBloc,
  }) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/add-document',
    ));
    await settleWithPumps(tester);
  }

  Finder submitButton() => find.widgetWithText(FilledButton, 'Publier');

  testWidgets('affiche tous les champs du formulaire', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpAddPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.text('Publier un document'), findsOneWidget);
    expect(find.text('Titre'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Ville'), findsOneWidget);
    expect(find.text('Téléphone'), findsOneWidget);
    expect(submitButton(), findsOneWidget);
    expect(find.text('Ajouter une photo'), findsOneWidget);
    expect(find.text('Statut du document'), findsOneWidget);
  });

  testWidgets('affiche les erreurs de validation pour un formulaire vide',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpAddPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await settleWithPumps(tester);

    expect(find.text('Veuillez entrer un titre'), findsOneWidget);
    expect(find.text('Veuillez entrer une description'), findsOneWidget);
    expect(find.text('Veuillez choisir une ville'), findsOneWidget);
    expect(find.text('Veuillez entrer votre numéro'), findsOneWidget);
  });

  testWidgets(
      'demande une image quand le formulaire est valide mais sans photo',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpAddPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Titre'), 'Passeport');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description'),
        'Trouvé à Brazzaville');

    final villeField = find.widgetWithText(TextFormField, 'Ville');
    await tester.ensureVisible(villeField);
    await settleWithPumps(tester);
    await tester.tap(villeField);
    await settleWithPumps(tester);
    await tester.tap(find.text('Brazzaville').first);
    await settleWithPumps(tester);

    final phoneField = find.widgetWithText(TextFormField, 'Téléphone');
    await tester.ensureVisible(phoneField);
    await settleWithPumps(tester);
    await tester.enterText(phoneField, '061234567');

    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await settleWithPumps(tester);

    expect(find.text('Veuillez sélectionner une image'), findsOneWidget);
  });

  testWidgets('permet de changer le statut du document', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpAddPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.tap(find.text('Perdu'));
    await settleWithPumps(tester);

    expect(find.text('Perdu'), findsOneWidget);
    expect(find.text('Trouvé'), findsOneWidget);
  });
}
