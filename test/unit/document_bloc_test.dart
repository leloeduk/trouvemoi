import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_bloc.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_event.dart';
import 'package:trouvemoi/features/documents/presentation/bloc/document_state.dart';

import '../helpers/fakes.dart';

void main() {
  final doc1 =
      sampleDocument(id: 'doc-1', title: 'Passeport', location: 'Brazzaville');
  final doc2 = sampleDocument(
    id: 'doc-2',
    title: "Carte d'étudiant",
    location: 'Pointe-Noire',
    status: DocumentStatus.lost,
  );

  group('DocumentBloc - LoadAllDocumentsEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'émet Loading puis Loaded avec les documents',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(LoadAllDocumentsEvent()),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentLoaded>()
            .having((s) => s.documents.length, 'documents.length', 2),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'émet DocumentError si le repository échoue',
      build: () {
        final repo = FakeDocumentRepository(documents: [doc1]);
        repo.throwOnLoad = true;
        return DocumentBloc(repo);
      },
      act: (bloc) => bloc.add(LoadAllDocumentsEvent()),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentError>()
            .having((s) => s.message, 'message', contains('db error')),
      ],
    );
  });

  group('DocumentBloc - SearchDocumentsEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'retourne uniquement les documents correspondant à la requête',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(SearchDocumentsEvent('Passeport')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having((s) => s.documents, 'documents', [doc1]),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'retourne une liste vide si aucun résultat',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(SearchDocumentsEvent('inexistant')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having((s) => s.documents, 'documents', isEmpty),
      ],
    );
  });

  group('DocumentBloc - FilterByStatusEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'filtre les documents trouvés',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(FilterByStatusEvent(DocumentStatus.found)),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having((s) => s.documents, 'documents', [doc1]),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'filtre les documents perdus',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(FilterByStatusEvent(DocumentStatus.lost)),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having((s) => s.documents, 'documents', [doc2]),
      ],
    );
  });

  group('DocumentBloc - AddDocumentEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'téléverse, sauvegarde puis recharge la liste',
      build: () => DocumentBloc(FakeDocumentRepository()),
      act: (bloc) => bloc.add(
        AddDocumentEvent(
          imageFile: File('photo.jpg'),
          type: 'Passeport',
          title: 'Passeport',
          description: 'Trouvé à Brazzaville',
          finderId: 'user-1',
          finderName: 'Jean Congo',
          finderPhone: '061234567',
          location: 'Brazzaville',
          status: DocumentStatus.found,
        ),
      ),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentAdded>(),
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having(
          (s) => s.documents.length,
          'documents.length',
          1,
        ),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'émet DocumentError si la sauvegarde échoue',
      build: () {
        final repo = FakeDocumentRepository();
        repo.throwOnSave = true;
        return DocumentBloc(repo);
      },
      act: (bloc) => bloc.add(
        AddDocumentEvent(
          imageFile: File('photo.jpg'),
          type: 'Passeport',
          title: 'Passeport',
          description: 'Trouvé à Brazzaville',
          finderId: 'user-1',
          finderName: 'Jean Congo',
          finderPhone: '061234567',
          location: 'Brazzaville',
          status: DocumentStatus.found,
        ),
      ),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentError>().having(
          (s) => s.message,
          'message',
          contains('save failed'),
        ),
      ],
    );
  });

  group('DocumentBloc - LoadDocumentByIdEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'émet DocumentDetailLoaded quand le document existe',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1]),
      ),
      act: (bloc) => bloc.add(LoadDocumentByIdEvent('doc-1')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentDetailLoaded>().having(
          (s) => s.document.id,
          'document.id',
          'doc-1',
        ),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'émet DocumentDetailNotFound quand le document nexiste pas',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1]),
      ),
      act: (bloc) => bloc.add(LoadDocumentByIdEvent('doc-inconnu')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentDetailNotFound>(),
      ],
    );
  });

  group('DocumentBloc - UpdateDocumentEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'enregistre les modifications puis recharge la liste',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1]),
      ),
      act: (bloc) => bloc.add(
        UpdateDocumentEvent(
          id: 'doc-1',
          type: 'Passeport',
          title: 'Titre modifié',
          description: 'Description mise à jour',
          imageUrl: 'https://example.com/cni.jpg',
          finderId: 'user-1',
          finderName: 'Jean Congo',
          finderPhone: '066352455',
          location: 'Pointe-Noire',
          date: DateTime(2026, 7, 30, 14, 30),
          status: DocumentStatus.lost,
        ),
      ),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentUpdated>(),
        isA<DocumentLoading>(),
        isA<DocumentLoaded>().having(
          (s) => s.documents.length,
          'documents.length',
          2,
        ),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'téléverse une nouvelle image quand imageFile est fourni',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1]),
      ),
      act: (bloc) => bloc.add(
        UpdateDocumentEvent(
          id: 'doc-1',
          type: 'Passeport',
          title: 'Titre modifié',
          description: 'Description mise à jour',
          imageUrl: 'https://example.com/cni.jpg',
          imageFile: File('new-photo.jpg'),
          finderId: 'user-1',
          finderName: 'Jean Congo',
          finderPhone: '066352455',
          location: 'Brazzaville',
          date: DateTime(2026, 7, 30, 14, 30),
          status: DocumentStatus.found,
        ),
      ),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentUpdated>(),
        isA<DocumentLoading>(),
        isA<DocumentLoaded>()
            .having(
              (s) => s.documents.any(
                (d) => d.imageUrl == 'https://example.com/uploaded.jpg',
              ),
              'contient la nouvelle image uploadée',
              isTrue,
            ),
      ],
    );

    blocTest<DocumentBloc, DocumentState>(
      'émet DocumentError si la sauvegarde échoue',
      build: () {
        final repo = FakeDocumentRepository(documents: [doc1]);
        repo.throwOnSave = true;
        return DocumentBloc(repo);
      },
      act: (bloc) => bloc.add(
        UpdateDocumentEvent(
          id: 'doc-1',
          type: 'Passeport',
          title: 'Titre modifié',
          description: 'Description mise à jour',
          imageUrl: 'https://example.com/cni.jpg',
          finderId: 'user-1',
          finderName: 'Jean Congo',
          finderPhone: '066352455',
          location: 'Brazzaville',
          date: DateTime(2026, 7, 30, 14, 30),
          status: DocumentStatus.found,
        ),
      ),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentError>().having(
          (s) => s.message,
          'message',
          contains('save failed'),
        ),
      ],
    );
  });

  group('DocumentBloc - DeleteDocumentEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'supprime le document puis recharge la liste',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1, doc2]),
      ),
      act: (bloc) => bloc.add(DeleteDocumentEvent('doc-1')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentDeleted>(),
        isA<DocumentLoading>(),
        isA<DocumentLoaded>()
            .having((s) => s.documents.length, 'documents.length', 1),
      ],
    );
  });

  group('DocumentBloc - MarkDocumentResolvedEvent', () {
    blocTest<DocumentBloc, DocumentState>(
      'marque le document comme résolu puis recharge les données',
      build: () => DocumentBloc(
        FakeDocumentRepository(documents: [doc1]),
      ),
act: (bloc) => bloc.add(MarkDocumentResolvedEvent('doc-1')),
      expect: () => [
        isA<DocumentLoading>(),
        isA<DocumentDetailLoaded>().having(
          (s) => s.document.isResolved,
          'document.isResolved',
          isTrue,
        ),
        isA<DocumentLoaded>().having(
          (s) => s.documents.first.isResolved,
          'documents.first.isResolved',
          isTrue,
        ),
      ],
    );
  });
}
