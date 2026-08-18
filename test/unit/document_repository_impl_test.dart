import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trouvemoi/features/documents/data/models/document_model.dart';
import 'package:trouvemoi/features/documents/data/repositories/document_repository_impl.dart';
import 'package:trouvemoi/features/documents/data/services/document_firebase_service.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';

import '../helpers/fakes.dart';

class MockDocumentFirebaseService extends Mock
    implements DocumentFirebaseService {}

void main() {
  late MockDocumentFirebaseService service;
  late DocumentRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(DocumentModel.fromEntity(sampleDocument()));
  });

  setUp(() {
    service = MockDocumentFirebaseService();
    repository = DocumentRepositoryImpl(service);
  });

  group('DocumentRepositoryImpl.uploadImage', () {
    test('délègue le téléversement au service', () async {
      when(() => service.uploadImage(any(), any()))
          .thenAnswer((_) async => 'https://example.com/doc-1.jpg');

      final url = await repository.uploadImage(File('photo.jpg'), 'doc-1');

      expect(url, 'https://example.com/doc-1.jpg');
      verify(() => service.uploadImage(any(), any())).called(1);
    });
  });

  group('DocumentRepositoryImpl.saveDocument', () {
    test('convertit lentité en modèle puis délègue au service', () async {
      when(() => service.saveDocument(any())).thenAnswer((_) async {});

      final doc = sampleDocument();
      await repository.saveDocument(doc);

      verify(() => service.saveDocument(any())).called(1);
    });
  });

  group('DocumentRepositoryImpl.getAllDocuments', () {
    test('délègue au service', () async {
      final model = DocumentModel.fromEntity(sampleDocument());
      when(() => service.getAllDocuments()).thenAnswer(
        (_) => Stream.value([model]),
      );

      final stream = repository.getAllDocuments();
      final docs = await stream.first;

      expect(docs, hasLength(1));
      verify(() => service.getAllDocuments()).called(1);
    });
  });

  group('DocumentRepositoryImpl.searchDocuments', () {
    test('délègue au service avec la requête', () async {
      final model = DocumentModel.fromEntity(sampleDocument());
      when(() => service.searchDocuments('passeport')).thenAnswer(
        (_) => Stream.value([model]),
      );

      final docs = await repository.searchDocuments('passeport').first;

      expect(docs, hasLength(1));
      verify(() => service.searchDocuments('passeport')).called(1);
    });
  });

  group('DocumentRepositoryImpl.getDocumentsByStatus', () {
    test('convertit DocumentStatus.found en "found"', () async {
      final model = DocumentModel.fromEntity(
        sampleDocument(status: DocumentStatus.found),
      );
      when(() => service.getDocumentsByStatus('found')).thenAnswer(
        (_) => Stream.value([model]),
      );

      final docs =
          await repository.getDocumentsByStatus(DocumentStatus.found).first;

      expect(docs, hasLength(1));
      verify(() => service.getDocumentsByStatus('found')).called(1);
    });

    test('convertit DocumentStatus.lost en "lost"', () async {
      final model = DocumentModel.fromEntity(
        sampleDocument(status: DocumentStatus.lost),
      );
      when(() => service.getDocumentsByStatus('lost')).thenAnswer(
        (_) => Stream.value([model]),
      );

      final docs =
          await repository.getDocumentsByStatus(DocumentStatus.lost).first;

      expect(docs, hasLength(1));
      verify(() => service.getDocumentsByStatus('lost')).called(1);
    });
  });

  group('DocumentRepositoryImpl.getDocumentById', () {
    test('délègue au service', () async {
      final model = DocumentModel.fromEntity(sampleDocument());
      when(() => service.getDocumentById('doc-1'))
          .thenAnswer((_) async => model);

      final result = await repository.getDocumentById('doc-1');

      expect(result?.id, 'doc-1');
      verify(() => service.getDocumentById('doc-1')).called(1);
    });
  });

  group('DocumentRepositoryImpl.deleteDocument', () {
    test('délègue au service', () async {
      when(() => service.deleteDocument('doc-1')).thenAnswer((_) async {});

      await repository.deleteDocument('doc-1');

      verify(() => service.deleteDocument('doc-1')).called(1);
    });
  });
}
