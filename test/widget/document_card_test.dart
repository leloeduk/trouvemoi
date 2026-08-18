import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';
import 'package:trouvemoi/features/documents/presentation/pages/document_card.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('affiche le titre, la description et le lieu du document',
      (tester) async {
    final doc = sampleDocument(
      title: 'Passeport perdu',
      description: 'Trouvé près de la mairie',
      location: 'Brazzaville',
      status: DocumentStatus.lost,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DocumentCard(document: doc))),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Passeport perdu'), findsOneWidget);
    expect(find.text('Trouvé près de la mairie'), findsOneWidget);
    expect(find.text('Brazzaville'), findsOneWidget);
    expect(find.text('PERDU'), findsOneWidget);
  });

  testWidgets('affiche le badge TROUVÉ pour un document trouvé',
      (tester) async {
    final doc = sampleDocument(title: 'CNI', status: DocumentStatus.found);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DocumentCard(document: doc))),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('TROUVÉ'), findsOneWidget);
  });
}
