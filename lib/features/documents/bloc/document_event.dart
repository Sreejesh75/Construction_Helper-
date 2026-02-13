import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectDocuments extends DocumentEvent {
  final String projectId;

  const LoadProjectDocuments(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class UploadDocument extends DocumentEvent {
  final String projectId;
  final File file;
  final String category;
  final String? customName;

  const UploadDocument({
    required this.projectId,
    required this.file,
    required this.category,
    this.customName,
  });

  @override
  List<Object?> get props => [projectId, file, category, customName];
}

class DeleteDocument extends DocumentEvent {
  final String documentId;
  final String projectId;

  const DeleteDocument({required this.documentId, required this.projectId});

  @override
  List<Object?> get props => [documentId, projectId];
}
