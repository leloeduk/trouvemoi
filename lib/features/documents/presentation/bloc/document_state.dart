import 'package:equatable/equatable.dart';

import '../../domain/entities/document_entity.dart';

abstract class DocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<DocumentEntity> documents;
  DocumentLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentAdded extends DocumentState {}

class DocumentUpdated extends DocumentState {}

class DocumentDeleted extends DocumentState {}

class DocumentError extends DocumentState {
  final String message;
  DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

// État pour un document unique
class DocumentDetailLoaded extends DocumentState {
  final DocumentEntity document;
  DocumentDetailLoaded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentDetailNotFound extends DocumentState {}
