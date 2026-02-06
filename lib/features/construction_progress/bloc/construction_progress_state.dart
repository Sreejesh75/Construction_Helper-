import '../data/models/construction_progress_model.dart';

abstract class ConstructionProgressState {}

class ConstructionProgressInitial extends ConstructionProgressState {}

class ConstructionProgressLoading extends ConstructionProgressState {}

class ConstructionProgressLoaded extends ConstructionProgressState {
  final List<ConstructionProgressModel> progressList;
  final double overallPercentage;

  ConstructionProgressLoaded(this.progressList)
    : overallPercentage = _calculateOverall(progressList);

  static double _calculateOverall(List<ConstructionProgressModel> list) {
    if (list.isEmpty) return 0.0;
    final total = list.fold(0, (sum, item) => sum + item.progress);
    return total / list.length; // Simple average for now
  }
}

class ConstructionProgressError extends ConstructionProgressState {
  final String message;
  ConstructionProgressError(this.message);
}

class ConstructionProgressOperationSuccess extends ConstructionProgressState {
  final String message;
  ConstructionProgressOperationSuccess(this.message);
}
