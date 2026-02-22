import 'package:flutter_bloc/flutter_bloc.dart';
import 'equipment_event.dart';
import 'equipment_state.dart';
import '../data/equipment_api_service.dart';

class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  final EquipmentApiService _apiService;

  EquipmentBloc(this._apiService) : super(EquipmentInitial()) {
    on<LoadEquipment>(_onLoadEquipment);
    on<AddEquipmentEvent>(_onAddEquipment);
    on<LoadEquipmentLogs>(_onLoadEquipmentLogs);
    on<AddEquipmentLogEvent>(_onAddEquipmentLog);
  }

  Future<void> _onLoadEquipment(
    LoadEquipment event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(EquipmentLoading());
    try {
      final equipment = await _apiService.getEquipmentForProject(
        event.projectId,
      );
      emit(EquipmentLoaded(equipment));
    } catch (e) {
      emit(EquipmentError('Failed to load equipment: $e'));
    }
  }

  Future<void> _onAddEquipment(
    AddEquipmentEvent event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(EquipmentLoading());
    try {
      await _apiService.addEquipment(event.equipment);
      emit(const EquipmentActionSuccess('Equipment added successfully'));
      add(LoadEquipment(event.equipment.projectId)); // Reload list
    } catch (e) {
      emit(EquipmentError('Failed to add equipment: $e'));
    }
  }

  Future<void> _onLoadEquipmentLogs(
    LoadEquipmentLogs event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(EquipmentLoading());
    try {
      final logs = await _apiService.getEquipmentLogs(event.equipmentId);
      emit(EquipmentLogsLoaded(logs));
    } catch (e) {
      emit(EquipmentError('Failed to load equipment logs: $e'));
    }
  }

  Future<void> _onAddEquipmentLog(
    AddEquipmentLogEvent event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(EquipmentLoading());
    try {
      await _apiService.addEquipmentLog(
        equipmentId: event.equipmentId,
        date: event.date,
        hoursUsed: event.hoursUsed,
        fuelConsumed: event.fuelConsumed,
        fuelCost: event.fuelCost,
        remarks: event.remarks,
      );
      emit(const EquipmentActionSuccess('Log added successfully'));
      add(LoadEquipmentLogs(event.equipmentId)); // Reload logs
    } catch (e) {
      emit(EquipmentError('Failed to add log: $e'));
    }
  }
}
