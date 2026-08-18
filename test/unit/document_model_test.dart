import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trouvemoi/features/documents/data/models/document_model.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';

import '../helpers/fakes.dart';

void main() {
  final date = DateTime(2026, 7, 30, 14, 30);

  group('DocumentModel.fromFirestore', () {
    test('convertit correctement un document Firestore "found"', () {
      final json = <String, dynamic>{
        'type': 'Passeport',
        'title': "Carte d'identité",
        'description': 'Trouvée à Brazzaville',
        'imageUrl': 'https://example.com/img.jpg',
        'finderId': 'user-1',
        'finderName': 'Jean Congo',
        'finderPhone': '061234567',
        'location': 'Brazzaville',
        'date': Timestamp.fromDate(date),
        'status': 'found',
      };

      final model = DocumentModel.fromFirestore(json, 'doc-1');

      expect(model.id, 'doc-1');
      expect(model.type, 'Passeport');
      expect(model.title, "Carte d'identité");
      expect(model.description, 'Trouvée à Brazzaville');
      expect(model.imageUrl, 'https://example.com/img.jpg');
      expect(model.finderId, 'user-1');
      expect(model.finderName, 'Jean Congo');
      expect(model.finderPhone, '061234567');
      expect(model.location, 'Brazzaville');
      expect(model.date, date);
      expect(model.status, DocumentStatus.found);
    });

    test('convertit correctement un document Firestore "lost"', () {
      final json = <String, dynamic>{
        'title': 'Passeport',
        'description': 'Perdu à Pointe-Noire',
        'imageUrl': '',
        'finderId': 'user-2',
        'finderName': 'Marie Nkounkou',
        'finderPhone': '055123456',
        'location': 'Pointe-Noire',
        'date': Timestamp.fromDate(date),
        'status': 'lost',
      };

      final model = DocumentModel.fromFirestore(json, 'doc-2');

      expect(model.status, DocumentStatus.lost);
      expect(model.location, 'Pointe-Noire');
    });

    test('applique des valeurs par défaut si des champs manquent', () {
      final json = <String, dynamic>{
        'date': Timestamp.fromDate(date),
        'status': 'found',
      };

      final model = DocumentModel.fromFirestore(json, 'doc-3');

      expect(model.title, '');
      expect(model.description, '');
      expect(model.imageUrl, '');
      expect(model.location, '');
      expect(model.finderPhone, '');
    });
  });

  group('DocumentModel.toFirestore', () {
    test('sérialise correctement un document found', () {
      final model = DocumentModel.fromEntity(
        sampleDocument(date: date, status: DocumentStatus.found),
      );

      final json = model.toFirestore();

      expect(json['type'], "Carte Nationale d'Identité");
      expect(json['title'], "Carte nationale d'identité");
      expect(json['status'], 'found');
      expect(json['date'], isA<Timestamp>());
      expect((json['date'] as Timestamp).toDate(), date);
      expect(json['location'], 'Brazzaville');
      expect(json['finderPhone'], '061234567');
    });

    test('sérialise correctement un document lost', () {
      final model = DocumentModel.fromEntity(
        sampleDocument(date: date, status: DocumentStatus.lost),
      );

      expect(model.toFirestore()['status'], 'lost');
    });
  });

  group('DocumentModel.fromEntity', () {
    test('copie toutes les propriétés de lentité', () {
      final entity = sampleDocument(date: date);
      final model = DocumentModel.fromEntity(entity);

      expect(model, isA<DocumentModel>());
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.date, entity.date);
      expect(model.status, entity.status);
    });

    test(
        'le round-trip fromEntity -> toFirestore -> fromFirestore conserve les données',
        () {
      final entity = sampleDocument(date: date);
      final model = DocumentModel.fromEntity(entity);
      final json = model.toFirestore();

      final back = DocumentModel.fromFirestore(json, entity.id);

      expect(back.id, entity.id);
      expect(back.type, entity.type);
      expect(back.title, entity.title);
      expect(back.description, entity.description);
      expect(back.finderName, entity.finderName);
      expect(back.finderPhone, entity.finderPhone);
      expect(back.location, entity.location);
      expect(back.date, entity.date);
      expect(back.status, entity.status);
    });
  });
}
