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
    required super.date,
    required super.status,
  });

  // Convert Firestore document to Model
  factory DocumentModel.fromFirestore(Map<String, dynamic> json, String id) {
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
      date: (json['date'] as Timestamp).toDate(),
      status: json['status'] == 'found'
          ? DocumentStatus.found
          : DocumentStatus.lost,
    );
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
      'date': Timestamp.fromDate(date),
      'status': status == DocumentStatus.found ? 'found' : 'lost',
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
      date: entity.date,
      status: entity.status,
    );
  }
}
