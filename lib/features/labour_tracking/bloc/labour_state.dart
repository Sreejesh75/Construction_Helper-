import 'package:equatable/equatable.dart';
import '../data/labour_model.dart';

abstract class LabourState extends Equatable {
  const LabourState();

  @override
  List<Object?> get props => [];
}

class LabourInitial extends LabourState {}

class LabourLoading extends LabourState {}

class LabourLoaded extends LabourState {
  final List<Labour> records;
  final List<Labour> filteredRecords;
  final DateTime? selectedDate;
  final double totalContractPaid;
  final double totalContractEstimated;
  final double totalDailyWage;

  const LabourLoaded({
    required this.records,
    List<Labour>? filteredRecords,
    this.selectedDate,
    required this.totalContractPaid,
    required this.totalContractEstimated,
    required this.totalDailyWage,
  }) : filteredRecords = filteredRecords ?? records;

  @override
  List<Object?> get props => [
    records,
    filteredRecords,
    selectedDate,
    totalContractPaid,
    totalContractEstimated,
    totalDailyWage,
  ];
}

class LabourOperationSuccess extends LabourState {
  final String message;

  const LabourOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class LabourError extends LabourState {
  final String message;

  const LabourError(this.message);

  @override
  List<Object> get props => [message];
}
