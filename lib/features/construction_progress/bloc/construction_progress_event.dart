import '../data/models/construction_progress_model.dart';

abstract class ConstructionProgressEvent {}

class LoadProgress extends ConstructionProgressEvent {
  final String projectId;
  LoadProgress(this.projectId);
}

class AddOrUpdateProgress extends ConstructionProgressEvent {
  final ConstructionProgressModel progress;
  AddOrUpdateProgress(this.progress);
}
