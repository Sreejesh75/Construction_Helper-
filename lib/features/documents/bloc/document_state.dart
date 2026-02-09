import 'package:equatable/equatable.dart';

class DocumentState extends Equatable {
  final bool isLoading;
  final List<Map<String, dynamic>> documents;
  final String? error;
  final bool uploadSuccess;

  const DocumentState({
    this.isLoading = false,
    this.documents = const [],
    this.error,
    this.uploadSuccess = false,
  });

  DocumentState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? documents,
    String? error,
    bool? uploadSuccess,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      error: error, 
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, documents, error, uploadSuccess];
}
