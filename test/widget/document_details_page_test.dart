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

  Future<void> pumpDetails(
    WidgetTester tester, {
    required AuthBloc authBloc,
    required DocumentBloc documentBloc,
    required ProfileBloc profileBloc,
    required String docId,
  }) async {
    await tester.pumpWidget(buildTestApp(
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      initialLocation: '/document/$docId',
    ));
    await settleWithPumps(tester);
  }

  testWidgets('affiche les détails du document chargé', (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [
        sampleDocument(
          id: 'doc-1',
          title: 'Passeport trouvé',
          description: 'Trouvé près de la mairie de Brazzaville',
          finderName: 'Jean Congo',
          finderPhone: '061234567',
          location: 'Brazzaville',
        ),
      ],
    );

    await pumpDetails(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      docId: 'doc-1',
    );

    expect(find.text('Passeport trouvé'), findsOneWidget);
    expect(
        find.text('Trouvé près de la mairie de Brazzaville'), findsOneWidget);
    expect(find.text('Brazzaville'), findsWidgets);
    expect(find.text('Jean Congo'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Contacter le trouveur'), findsOneWidget);
  });

  testWidgets('affiche Document introuvable pour un id inconnu',
      (tester) async {
    final (authBloc, documentBloc, profileBloc) = createBlocs(
      documents: [sampleDocument(id: 'doc-1')],
    );

    await pumpDetails(
      tester,
      authBloc: authBloc,
      documentBloc: documentBloc,
      profileBloc: profileBloc,
      docId: 'doc-inconnu',
    );

    expect(find.text('Document introuvable'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
