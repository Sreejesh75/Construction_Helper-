import 'package:equatable/equatable.dart';
import '../models/equipment_model.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object> get props => [];
}

class LoadEquipment extends EquipmentEvent {
  final String projectId;
  const LoadEquipment(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class AddEquipmentEvent extends EquipmentEvent {
  final Equipment equipment;
  const AddEquipmentEvent(this.equipment);

  @override
  List<Object> get props => [equipment];
}

class LoadEquipmentLogs extends EquipmentEvent {
  final String equipmentId;
  const LoadEquipmentLogs(this.equipmentId);

  @override
  List<Object> get props => [equipmentId];
}

class AddEquipmentLogEvent extends EquipmentEvent {
  final String equipmentId;
  final DateTime date;
  final double hoursUsed;
  final double fuelConsumed;
  final double fuelCost;
  final String remarks;

  const AddEquipmentLogEvent({
    required this.equipmentId,
    required this.date,
    required this.hoursUsed,
    required this.fuelConsumed,
    required this.fuelCost,
    required this.remarks,
  });

  @override
  List<Object> get props => [
    equipmentId,
    date,
    hoursUsed,
    fuelConsumed,
    fuelCost,
    remarks,
  ];
}
