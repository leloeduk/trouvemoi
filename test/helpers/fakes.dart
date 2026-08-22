import 'dart:async';
import 'dart:io';

import 'package:trouvemoi/features/auth/domain/entities/user_entity.dart';
import 'package:trouvemoi/features/auth/domain/repositories/auth_repository.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trouvemoi/features/auth/presentation/bloc/auth_state.dart';
import 'package:trouvemoi/features/documents/domain/entities/document_entity.dart';
import 'package:trouvemoi/features/documents/domain/repositories/document_repository.dart';

/// Construit un [AuthBloc] authentifié de manière synchrone pour les widget
/// tests. L'état initial étant injecté, aucune souscription au stream
/// d'authentification n'est nécessaire.
AuthBloc authenticatedAuthBloc({UserEntity? user}) {
  return AuthBloc(
    FakeAuthRepository(user: user),
    initialState: AuthState.authenticated(user ?? sampleUser()),
  );
}

/// Construit un [DocumentEntity] de test avec des valeurs par défaut
/// typiques du Congo Brazzaville.
DocumentEntity sampleDocument({
  String id = 'doc-1',
  String type = "Carte Nationale d'Identité",
  String title = "Carte nationale d'identité",
  String description = 'Trouvée près de la mairie de Brazzaville',
  String imageUrl = 'https://example.com/cni.jpg',
  String finderId = 'user-1',
  String finderName = 'Jean Congo',
  String finderPhone = '061234567',
  String location = 'Brazzaville',
  String arrondissement = '',
  DateTime? date,
  DocumentStatus status = DocumentStatus.found,
}) {
  return DocumentEntity(
    id: id,
    type: type,
    title: title,
    description: description,
    imageUrl: imageUrl,
    finderId: finderId,
    finderName: finderName,
    finderPhone: finderPhone,
    location: location,
    arrondissement: arrondissement,
    date: date ?? DateTime(2026, 7, 30, 14, 30),
    status: status,
  );
}

/// Construit un [UserEntity] de test.
UserEntity sampleUser({
  String uid = 'user-1',
  String displayName = 'Jean Congo',
  String email = 'jean@example.com',
  String? photoUrl,
}) {
  return UserEntity(
    uid: uid,
    displayName: displayName,
    email: email,
    photoUrl: photoUrl,
  );
}

/// Implémentation de [DocumentRepository] en mémoire pour les tests.
class FakeDocumentRepository implements DocumentRepository {
  List<DocumentEntity> _documents;
  bool throwOnLoad = false;
  bool throwOnSave = false;
  bool throwOnDelete = false;
  bool throwOnUpload = false;
  bool throwOnGetById = false;
  String uploadedUrl = 'https://example.com/uploaded.jpg';

  FakeDocumentRepository({List<DocumentEntity>? documents})
      : _documents = documents ?? [];

  List<DocumentEntity> get documents => List.unmodifiable(_documents);

  void setDocuments(List<DocumentEntity> documents) => _documents = documents;

  @override
  Future<String> uploadImage(File imageFile, String docId) async {
    if (throwOnUpload) throw Exception('upload failed');
    return uploadedUrl;
  }

  @override
  Future<void> saveDocument(DocumentEntity document) async {
    if (throwOnSave) throw Exception('save failed');
    _documents.insert(0, document);
  }

  @override
  Stream<List<DocumentEntity>> getAllDocuments() async* {
    if (throwOnLoad) throw Exception('db error');
    yield List.of(_documents);
  }

  @override
  Stream<List<DocumentEntity>> searchDocuments(String query) async* {
    if (throwOnLoad) throw Exception('db error');
    final q = query.toLowerCase();
    yield _documents
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  Stream<List<DocumentEntity>> getDocumentsByStatus(
      DocumentStatus status) async* {
    if (throwOnLoad) throw Exception('db error');
    yield _documents.where((d) => d.status == status).toList();
  }

  @override
  Future<DocumentEntity?> getDocumentById(String id) async {
    if (throwOnGetById) throw Exception('get failed');
    for (final doc in _documents) {
      if (doc.id == id) return doc;
    }
    return null;
  }

  @override
  Future<void> deleteDocument(String id) async {
    if (throwOnDelete) throw Exception('delete failed');
    _documents.removeWhere((d) => d.id == id);
  }

  @override
  Future<void> updateDocumentStatus(String id, DocumentStatus status) async {
    if (throwOnLoad) throw Exception('update failed');
    _documents = _documents
        .map((d) => d.id == id ? _copyWithStatus(d, status) : d)
        .toList();
  }

  DocumentEntity _copyWithStatus(DocumentEntity doc, DocumentStatus status) {
    return DocumentEntity(
      id: doc.id,
      type: doc.type,
      title: doc.title,
      description: doc.description,
      imageUrl: doc.imageUrl,
      finderId: doc.finderId,
      finderName: doc.finderName,
      finderPhone: doc.finderPhone,
      location: doc.location,
      arrondissement: doc.arrondissement,
      date: doc.date,
      status: status,
    );
  }
}

/// Implémentation de [AuthRepository] en mémoire pour les tests.
class FakeAuthRepository implements AuthRepository {
  UserEntity? user;
  UserEntity? _signInUser;
  bool throwOnSignIn = false;
  bool throwOnSignOut = false;
  StreamController<UserEntity?>? _controller;

  FakeAuthRepository({this.user});

  /// Utilisateur retourné par [signInWithGoogle], indépendant de [user].
  /// Permet de simuler une connexion alors que `currentUser` est null.
  set signInUser(UserEntity? user) => _signInUser = user;

  void emitUser(UserEntity? user) {
    _controller?.add(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    _controller ??= StreamController<UserEntity?>.broadcast();
    return _controller!.stream;
  }

  @override
  UserEntity? get currentUser => user;

  @override
  Future<UserEntity> signInWithGoogle() async {
    if (throwOnSignIn) throw Exception('signin failed');
    final result = _signInUser ?? user;
    if (result == null) throw Exception('no user');
    user = result;
    return result;
  }

  @override
  Future<void> signOut() async {
    if (throwOnSignOut) throw Exception('signout failed');
    user = null;
  }

  void dispose() {
    _controller?.close();
  }
}
