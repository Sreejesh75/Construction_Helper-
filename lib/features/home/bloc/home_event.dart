import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all projects for a user
class LoadProjects extends HomeEvent {
  final String userId;
  final String? userName; // Initialize with userName if available

  const LoadProjects(this.userId, {this.userName});

  @override
  List<Object?> get props => [userId, userName];
}

class UpdateUserName extends HomeEvent {
  final String userId;
  final String name;

  const UpdateUserName({required this.userId, required this.name});

  @override
  List<Object?> get props => [userId, name];
}

class LogoutEvent extends HomeEvent {}

/// Create a new project
class CreateProject extends HomeEvent {
  final String userId;
  final String projectName;
  final double budget;
  final String startDate;
  final String endDate;

  const CreateProject({
    required this.userId,
    required this.projectName,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, projectName, budget, startDate, endDate];
}

/// Update an existing project
class UpdateProject extends HomeEvent {
  final String projectId;
  final String userId;
  final String projectName;
  final double budget;
  final String startDate;
  final String endDate;

  const UpdateProject({
    required this.projectId,
    required this.userId,
    required this.projectName,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
    projectId,
    userId,
    projectName,
    budget,
    startDate,
    endDate,
  ];
}

/// Delete an existing project
class DeleteProject extends HomeEvent {
  final String projectId;
  final String userId;

  const DeleteProject({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

/// Load summary for a specific project
class LoadProjectSummary extends HomeEvent {
  final String projectId;

  const LoadProjectSummary(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
// ... existing events

/// Load materials for a project
class LoadMaterials extends HomeEvent {
  final String projectId;

  const LoadMaterials(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Add a new material
class AddMaterial extends HomeEvent {
  final String projectId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final String supplier;
  final String date;

  const AddMaterial({
    required this.projectId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.supplier,
    required this.date,
  });

  @override
  List<Object?> get props => [
    projectId,
    name,
    category,
    quantity,
    unit,
    price,
    supplier,
    date,
  ];
}

/// Update an existing material
class UpdateMaterial extends HomeEvent {
  final String materialId;
  final String projectId; // Needed to reload list
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final String supplier;
  final String date;

  const UpdateMaterial({
    required this.materialId,
    required this.projectId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.supplier,
    required this.date,
  });

  @override
  List<Object?> get props => [
    materialId,
    projectId,
    name,
    category,
    quantity,
    unit,
    price,
    supplier,
    date,
  ];
}

/// Delete a material
class DeleteMaterial extends HomeEvent {
  final String materialId;
  final String projectId; // Needed to reload list

  const DeleteMaterial({required this.materialId, required this.projectId});

  @override
  List<Object?> get props => [materialId, projectId];
}

class LoadMaterialHistory extends HomeEvent {
  final String materialId;

  const LoadMaterialHistory(this.materialId);

  @override
  List<Object?> get props => [materialId];
}
