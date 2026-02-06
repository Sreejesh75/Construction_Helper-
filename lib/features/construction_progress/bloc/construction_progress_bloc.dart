import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/construction_progress_api_service.dart';
import 'construction_progress_event.dart';
import 'construction_progress_state.dart';

class ConstructionProgressBloc
    extends Bloc<ConstructionProgressEvent, ConstructionProgressState> {
  final ConstructionProgressApiService apiService;

  ConstructionProgressBloc(this.apiService)
    : super(ConstructionProgressInitial()) {
    on<LoadProgress>(_onLoadProgress);
    on<AddOrUpdateProgress>(_onAddOrUpdateProgress);
  }

  Future<void> _onLoadProgress(
    LoadProgress event,
    Emitter<ConstructionProgressState> emit,
  ) async {
    emit(ConstructionProgressLoading());
    try {
      final progressList = await apiService.getProgress(event.projectId);
      emit(ConstructionProgressLoaded(progressList));
    } catch (e) {
      emit(ConstructionProgressError(e.toString()));
    }
  }

  Future<void> _onAddOrUpdateProgress(
    AddOrUpdateProgress event,
    Emitter<ConstructionProgressState> emit,
  ) async {
    // Keep the current list while saving to avoid UI flicker
    final currentState = state;
    if (currentState is ConstructionProgressLoaded) {
      // Optimistic update could go here, but for now we'll just wait
    } else {
      emit(ConstructionProgressLoading());
    }

    try {
      await apiService.addOrUpdateProgress(event.progress);
      // Reload the list to get fresh data and accurate %
      add(LoadProgress(event.progress.projectId));
      // Optionally emit a success separate side-effect or just reload
      // For simplicity in this iteration: Reload triggers Loaded state.
    } catch (e) {
      emit(ConstructionProgressError(e.toString()));
    }
  }
}
