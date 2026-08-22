import 'package:equatable/equatable.dart';

enum DocumentStatus { lost, found, resolved }

class DocumentEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final String description;
  final String imageUrl;
  final String finderId;
  final String finderName;
  final String finderPhone;
  final String location;
  final String arrondissement;
  final DateTime date;
  final DocumentStatus status;

  const DocumentEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.finderId,
    required this.finderName,
    required this.finderPhone,
    required this.location,
    this.arrondissement = '',
    required this.date,
    required this.status,
  });

  bool get isResolved => status == DocumentStatus.resolved;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        imageUrl,
        finderId,
        finderName,
        finderPhone,
        location,
        arrondissement,
        date,
        status
      ];
}
