import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> pumpBrowsePage(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required DocumentBloc documentBloc,
    required ProfileBloc profileBloc,
  }) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/browse',
    ));
    await settleWithPumps(tester);
  }

  testWidgets('affiche les filtres et la liste des documents', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [
        sampleDocument(id: 'doc-1', title: 'Passeport trouvé'),
        sampleDocument(
          id: 'doc-2',
          title: 'Permis de conduire',
          status: DocumentStatus.lost,
        ),
      ],
    );

    await pumpBrowsePage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Tous'), findsOneWidget);
    expect(find.text('Perdus'), findsOneWidget);
    expect(find.text('Trouvés'), findsOneWidget);
    expect(find.text('Passeport trouvé'), findsOneWidget);
    expect(find.text('Permis de conduire'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('filtre les documents par statut "Perdus"', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [
        sampleDocument(id: 'doc-1', title: 'Passeport trouvé'),
        sampleDocument(
          id: 'doc-2',
          title: 'Permis de conduire',
          status: DocumentStatus.lost,
        ),
      ],
    );

    await pumpBrowsePage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.tap(find.text('Perdus'));
    await settleWithPumps(tester);

    expect(find.text('Permis de conduire'), findsOneWidget);
    expect(find.text('Passeport trouvé'), findsNothing);
  });

  testWidgets('affiche un message quand aucun document', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpBrowsePage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.text('Aucun document trouvé'), findsOneWidget);
  });

  testWidgets('affiche une erreur si le chargement échoue', (tester) async {
    final fake = FakeDocumentRepository();
    fake.throwOnLoad = true;
    final (authBloc, documentBloc, profileBloc) = createBlocs(repository: fake);

    await pumpBrowsePage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.textContaining('Erreur'), findsOneWidget);
  });
}
