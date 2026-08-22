import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.finderId,
    required super.finderName,
    required super.finderPhone,
    required super.location,
    super.arrondissement,
    required super.date,
    required super.status,
  });

  // Convert Firestore document to Model
  factory DocumentModel.fromFirestore(Map<String, dynamic> json, String id) {
    final status = json['status'] ?? 'lost';
    return DocumentModel(
      id: id,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      finderId: json['finderId'] ?? '',
      finderName: json['finderName'] ?? '',
      finderPhone: json['finderPhone'] ?? '',
      location: json['location'] ?? '',
      arrondissement: json['arrondissement'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      status: _statusFromString(status),
    );
  }

  static DocumentStatus _statusFromString(String status) {
    switch (status) {
      case 'found':
        return DocumentStatus.found;
      case 'resolved':
        return DocumentStatus.resolved;
      default:
        return DocumentStatus.lost;
    }
  }

  static String _statusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.found:
        return 'found';
      case DocumentStatus.resolved:
        return 'resolved';
      case DocumentStatus.lost:
        return 'lost';
    }
  }

  // Convert Model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'finderId': finderId,
      'finderName': finderName,
      'finderPhone': finderPhone,
      'location': location,
      'arrondissement': arrondissement,
      'date': Timestamp.fromDate(date),
      'status': _statusToString(status),
    };
  }

  // Convert Entity to Model
  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      finderId: entity.finderId,
      finderName: entity.finderName,
      finderPhone: entity.finderPhone,
      location: entity.location,
      arrondissement: entity.arrondissement,
      date: entity.date,
      status: entity.status,
    );
  }
}
