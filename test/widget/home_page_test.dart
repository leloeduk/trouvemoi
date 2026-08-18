import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';
import 'package:trouvemoi/features/profile/presentation/bloc/profile_bloc.dart';

import '../helpers/fakes.dart';
import '../helpers/widget_harness.dart';

void main() {
  (AuthBloc, DocumentBloc, ProfileBloc) createBlocs({
    List<DocumentEntity> documents = const [],
    FakeDocumentRepository? repository,
  }) {
    final authBloc = authenticatedAuthBloc(user: sampleUser());
    final documentBloc = DocumentBloc(
        repository ?? FakeDocumentRepository(documents: documents));
    final profileBloc = ProfileBloc(FakeAuthRepository(user: sampleUser()));
    addTearDown(() {
      authBloc.close();
      documentBloc.close();
      profileBloc.close();
    });
    return (authBloc, documentBloc, profileBloc);
  }

  testWidgets('affiche le message de bienvenue', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/home',
    ));
    await settleWithPumps(tester);

    expect(find.text('Bonjour, Jean Congo'), findsOneWidget);
    expect(find.text('Actions rapides'), findsOneWidget);
    expect(find.text('Rechercher'), findsWidgets);
    expect(find.text('Parcourir'), findsOneWidget);
  });

  testWidgets('affiche les documents récents', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [
        sampleDocument(id: 'doc-1', title: 'Passeport perdu'),
        sampleDocument(id: 'doc-2', title: "Carte d'étudiant"),
      ],
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(buildTestApp(
        authBloc: authBloc,
        documentBloc: documentBloc,
        profileBloc: profileBloc,
        initialLocation: '/home',
      ));
      await settleWithPumps(tester);

      expect(find.text('Documents récents'), findsOneWidget);
      expect(find.text('Passeport perdu'), findsOneWidget);
      expect(find.text("Carte d'étudiant"), findsOneWidget);
    });
  });

  testWidgets("affiche un message quand il n'y a aucun document",
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/home',
    ));
    await settleWithPumps(tester);

    expect(find.text('Aucun document pour le moment'), findsOneWidget);
    expect(find.text('Publiez le premier document trouvé !'), findsOneWidget);
  });

  testWidgets('la barre de navigation contient les 4 destinations',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/home',
    ));
    await settleWithPumps(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('affiche une erreur quand le chargement échoue', (tester) async {
    final fake = FakeDocumentRepository();
    fake.throwOnLoad = true;
    final (authBloc, documentBloc, profileBloc) = createBlocs(repository: fake);

    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/home',
    ));
    await settleWithPumps(tester);

    expect(find.textContaining('Erreur'), findsOneWidget);
  });
}
