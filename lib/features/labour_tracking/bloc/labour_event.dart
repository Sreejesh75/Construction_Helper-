import 'package:equatable/equatable.dart';
import '../data/labour_model.dart';

abstract class LabourEvent extends Equatable {
  const LabourEvent();

  @override
  List<Object> get props => [];
}

class LoadLabourRecords extends LabourEvent {
  final String projectId;

  const LoadLabourRecords(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class AddLabourRecord extends LabourEvent {
  final Labour labour;

  const AddLabourRecord(this.labour);

  @override
  List<Object> get props => [labour];
}
