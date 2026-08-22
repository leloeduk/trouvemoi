import 'dart:io';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';
import '../services/document_firebase_service.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentFirebaseService _datasource;

  DocumentRepositoryImpl(this._datasource);

  @override
  Future<String> uploadImage(File imageFile, String docId) async {
    return await _datasource.uploadImage(imageFile, docId);
  }

  @override
  Future<void> saveDocument(DocumentEntity document) async {
    final model = DocumentModel.fromEntity(document);
    await _datasource.saveDocument(model);
  }

  @override
  Stream<List<DocumentEntity>> getAllDocuments() {
    return _datasource.getAllDocuments();
  }

  @override
  Stream<List<DocumentEntity>> searchDocuments(String query) {
    return _datasource.searchDocuments(query);
  }

  @override
  Stream<List<DocumentEntity>> getDocumentsByStatus(DocumentStatus status) {
    return _datasource.getDocumentsByStatus(_statusString(status));
  }

  static String _statusString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.found:
        return 'found';
      case DocumentStatus.resolved:
        return 'resolved';
      case DocumentStatus.lost:
        return 'lost';
    }
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    return await _datasource.getDocumentById(id);
  }

  @override
  Future<void> updateDocumentStatus(String id, DocumentStatus status) async {
    await _datasource.updateDocumentStatus(id, _statusString(status));
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _datasource.deleteDocument(id);
  }
}
