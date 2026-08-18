import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/document_entity.dart';

abstract class DocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load all documents
class LoadAllDocumentsEvent extends DocumentEvent {}

// Search documents
class SearchDocumentsEvent extends DocumentEvent {
  final String query;
  SearchDocumentsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// Filter by status
class FilterByStatusEvent extends DocumentEvent {
  final DocumentStatus status;
  FilterByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

// Add new document
class AddDocumentEvent extends DocumentEvent {
  final File imageFile;
  final String type;
  final String title;
  final String description;
  final String finderId;
  final String finderName;
  final String finderPhone;
  final String location;
  final DocumentStatus status;

  AddDocumentEvent({
    required this.imageFile,
    required this.type,
    required this.title,
    required this.description,
    required this.finderId,
    required this.finderName,
    required this.finderPhone,
    required this.location,
    required this.status,
  });

  @override
  List<Object?> get props => [
        imageFile,
        type,
        title,
        description,
        finderId,
        finderName,
        finderPhone,
        location,
        status,
      ];
}

// Update an existing document
class UpdateDocumentEvent extends DocumentEvent {
  final String id;
  final String type;
  final String title;
  final String description;
  final String imageUrl;
  final File? imageFile;
  final String finderId;
  final String finderName;
  final String finderPhone;
  final String location;
  final DateTime date;
  final DocumentStatus status;

  UpdateDocumentEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.imageFile,
    required this.finderId,
    required this.finderName,
    required this.finderPhone,
    required this.location,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        imageUrl,
        imageFile,
        finderId,
        finderName,
        finderPhone,
        location,
        date,
        status,
      ];
}

// Delete document
class DeleteDocumentEvent extends DocumentEvent {
  final String documentId;
  DeleteDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

// Charger un document par son ID
class LoadDocumentByIdEvent extends DocumentEvent {
  final String documentId;
  LoadDocumentByIdEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
