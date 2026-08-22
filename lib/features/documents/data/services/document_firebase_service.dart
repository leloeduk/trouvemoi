import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/document_model.dart';

class DocumentFirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentFirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String docId) async {
    try {
      final ref = _storage.ref().child('documents/$docId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Save document to Firestore
// Dans document_datasource.dart

  Future<void> saveDocument(DocumentModel document) async {
    try {
      final data = document.toFirestore();
      await _firestore.collection('documents').doc(document.id).set(data);
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  // Get all documents as stream
  Stream<List<DocumentModel>> getAllDocuments() {
    return _firestore
        .collection('documents')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Search documents by title or description
  Stream<List<DocumentModel>> searchDocuments(String query) {
    // Note: For better search, use Algolia or Typesense
    // This is a simple client-side filter
    return _firestore
        .collection('documents')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc.data(), doc.id))
          .where((doc) =>
              doc.title.toLowerCase().contains(query.toLowerCase()) ||
              doc.description.toLowerCase().contains(query.toLowerCase()) ||
              doc.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get documents by status
  Stream<List<DocumentModel>> getDocumentsByStatus(String status) {
    return _firestore
        .collection('documents')
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single document by ID
  Future<DocumentModel?> getDocumentById(String id) async {
    try {
      final doc = await _firestore.collection('documents').doc(id).get();
      if (doc.exists) {
        return DocumentModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  // Update document status only
  Future<void> updateDocumentStatus(String id, String status) async {
    try {
      await _firestore.collection('documents').doc(id).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String id) async {
    try {
      await _firestore.collection('documents').doc(id).delete();
      // Also delete image from storage
      await _storage.ref().child('documents/$id.jpg').delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
