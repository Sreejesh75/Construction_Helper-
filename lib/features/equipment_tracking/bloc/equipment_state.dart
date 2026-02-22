import 'package:equatable/equatable.dart';
import '../models/equipment_model.dart';
import '../models/equipment_log_model.dart';

abstract class EquipmentState extends Equatable {
  const EquipmentState();

  @override
  List<Object> get props => [];
}

class EquipmentInitial extends EquipmentState {}

class EquipmentLoading extends EquipmentState {}

class EquipmentLoaded extends EquipmentState {
  final List<Equipment> equipmentList;
  const EquipmentLoaded(this.equipmentList);

  @override
  List<Object> get props => [equipmentList];
}

class EquipmentLogsLoaded extends EquipmentState {
  final List<EquipmentLog> logs;
  const EquipmentLogsLoaded(this.logs);

  @override
  List<Object> get props => [logs];
}

class EquipmentActionSuccess extends EquipmentState {
  final String message;
  const EquipmentActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EquipmentError extends EquipmentState {
  final String message;
  const EquipmentError(this.message);

  @override
  List<Object> get props => [message];
}
