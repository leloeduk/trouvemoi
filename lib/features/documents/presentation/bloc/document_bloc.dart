import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository _repository;

  DocumentBloc(this._repository) : super(DocumentInitial()) {
    on<LoadAllDocumentsEvent>(_onLoadAllDocuments);
    on<SearchDocumentsEvent>(_onSearchDocuments);
    on<FilterByStatusEvent>(_onFilterByStatus);
    on<AddDocumentEvent>(_onAddDocument);
    on<UpdateDocumentEvent>(_onUpdateDocument);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    // Ajouter dans le constructeur du DocumentBloc
    on<LoadDocumentByIdEvent>(_onLoadDocumentById);
  }

  Future<void> _onLoadAllDocuments(
    LoadAllDocumentsEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await emit.forEach<List<DocumentEntity>>(
        _repository.getAllDocuments(),
        onData: (documents) => DocumentLoaded(documents),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onSearchDocuments(
    SearchDocumentsEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await emit.forEach<List<DocumentEntity>>(
        _repository.searchDocuments(event.query),
        onData: (documents) => DocumentLoaded(documents),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatusEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await emit.forEach<List<DocumentEntity>>(
        _repository.getDocumentsByStatus(event.status),
        onData: (documents) => DocumentLoaded(documents),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onAddDocument(
    AddDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      // 1. Upload image
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await _repository.uploadImage(event.imageFile, docId);

      // 2. Créer le document
      final document = DocumentEntity(
        id: docId,
        type: event.type,
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        finderId: event.finderId,
        finderName: event.finderName,
        finderPhone: event.finderPhone,
        location: event.location,
        date: DateTime.now(),
        status: event.status,
      );

      // 3. Sauvegarder dans Firestore
      await _repository.saveDocument(document);

      emit(DocumentAdded());

      // 4. Recharger tous les documents
      add(LoadAllDocumentsEvent());
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onUpdateDocument(
    UpdateDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      var imageUrl = event.imageUrl;
      if (event.imageFile != null) {
        imageUrl = await _repository.uploadImage(event.imageFile!, event.id);
      }

      final document = DocumentEntity(
        id: event.id,
        type: event.type,
        title: event.title,
        description: event.description,
        imageUrl: imageUrl,
        finderId: event.finderId,
        finderName: event.finderName,
        finderPhone: event.finderPhone,
        location: event.location,
        date: event.date,
        status: event.status,
      );

      await _repository.saveDocument(document);

      emit(DocumentUpdated());

      add(LoadAllDocumentsEvent());
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await _repository.deleteDocument(event.documentId);
      emit(DocumentDeleted());

      // Reload all documents
      add(LoadAllDocumentsEvent());
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

// Ajouter cette méthode dans la classe
  Future<void> _onLoadDocumentById(
    LoadDocumentByIdEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final document = await _repository.getDocumentById(event.documentId);
      if (document != null) {
        emit(DocumentDetailLoaded(document));
      } else {
        emit(DocumentDetailNotFound());
      }
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }
}
