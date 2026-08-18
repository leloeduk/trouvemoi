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
  }) {
    final authBloc = authenticatedAuthBloc(user: sampleUser());
    final documentBloc =
        DocumentBloc(FakeDocumentRepository(documents: documents));
    final profileBloc = ProfileBloc(FakeAuthRepository(user: sampleUser()));
    addTearDown(() {
      authBloc.close();
      documentBloc.close();
      profileBloc.close();
    });
    return (authBloc, documentBloc, profileBloc);
  }

  Future<void> pumpSearchPage(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required DocumentBloc documentBloc,
    required ProfileBloc profileBloc,
  }) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/search-document',
    ));
    await settleWithPumps(tester);
  }

  testWidgets('affiche la barre de recherche', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs();
    await pumpSearchPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    expect(find.text('Rechercher'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('filtre les documents selon la recherche', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [
        sampleDocument(id: 'doc-1', title: 'Passeport perdu'),
        sampleDocument(id: 'doc-2', title: 'Permis de conduire'),
      ],
    );

    await pumpSearchPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.enterText(find.byType(TextField), 'passeport');
    await settleWithPumps(tester);

    expect(find.text('Passeport perdu'), findsOneWidget);
    expect(find.text('Permis de conduire'), findsNothing);
  });

  testWidgets('affiche un message quand la recherche ne retourne rien',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [sampleDocument(id: 'doc-1', title: 'Passeport')],
    );

    await pumpSearchPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.enterText(find.byType(TextField), 'zzyzx');
    await settleWithPumps(tester);

    expect(find.text('Aucun résultat'), findsOneWidget);
  });

  testWidgets('recharge tous les documents quand la recherche est effacée',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [sampleDocument(id: 'doc-1', title: 'Passeport')],
    );

    await pumpSearchPage(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
    );

    await tester.enterText(find.byType(TextField), 'zzyzx');
    await settleWithPumps(tester);
    expect(find.text('Aucun résultat'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await settleWithPumps(tester);

    expect(find.text('Passeport'), findsOneWidget);
  });
}
