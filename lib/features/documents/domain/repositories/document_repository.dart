import 'dart:io';

import '../entities/document_entity.dart';

abstract class DocumentRepository {
  // Upload image to storage
  Future<String> uploadImage(File imageFile, String docId);

  // Save document to database
  Future<void> saveDocument(DocumentEntity document);

  // Get all documents (stream for real-time updates)
  Stream<List<DocumentEntity>> getAllDocuments();

  // Search documents by query
  Stream<List<DocumentEntity>> searchDocuments(String query);

  // Get documents by status (lost/found)
  Stream<List<DocumentEntity>> getDocumentsByStatus(DocumentStatus status);

  // Get single document by ID
  Future<DocumentEntity?> getDocumentById(String id);

  // Delete document
  Future<void> deleteDocument(String id);
}
