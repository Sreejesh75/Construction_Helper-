import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/document_api_service.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentApiService _documentApiService;

  DocumentBloc(this._documentApiService) : super(const DocumentState()) {
    on<LoadProjectDocuments>(_onLoadProjectDocuments);
    on<UploadDocument>(_onUploadDocument);
    on<DeleteDocument>(_onDeleteDocument);
  }

  Future<void> _onLoadProjectDocuments(
    LoadProjectDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final documents = await _documentApiService.getDocuments(event.projectId);
      emit(state.copyWith(isLoading: false, documents: documents));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        uploadSuccess: false,
        deleteSuccess: false,
      ),
    );
    try {
      await _documentApiService.uploadDocument(
        projectId: event.projectId,
        file: event.file,
        category: event.category,
        customName: event.customName,
      );

      // Refresh list
      final documents = await _documentApiService.getDocuments(event.projectId);
      emit(
        state.copyWith(
          isLoading: false,
          documents: documents,
          uploadSuccess: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, deleteSuccess: false));
    try {
      await _documentApiService.deleteDocument(event.documentId);
      final documents = await _documentApiService.getDocuments(event.projectId);
      emit(
        state.copyWith(
          isLoading: false,
          documents: documents,
          deleteSuccess: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
