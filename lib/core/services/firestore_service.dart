import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> setDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collection).doc(id).set(data);
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String id,
  }) async {
    final doc = await firestore.collection(collection).doc(id).get();
    return doc.data();
  }

  Future<void> updateDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDocument({
    required String collection,
    required String id,
  }) async {
    await firestore.collection(collection).doc(id).delete();
  }
}
