import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isLoadingMaterials;
  final List<dynamic> projects;
  final List<dynamic> materials;
  final Map<String, dynamic>? projectSummary;
  final String? error;
  final String? userName;

  const HomeState({
    this.isLoading = false,
    this.isLoadingMaterials = false,
    this.projects = const [],
    this.materials = const [],
    this.projectSummary,
    this.error,
    this.userName,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isLoadingMaterials,
    List<dynamic>? projects,
    List<dynamic>? materials,
    Map<String, dynamic>? projectSummary,
    String? error,
    String? userName,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMaterials: isLoadingMaterials ?? this.isLoadingMaterials,
      projects: projects ?? this.projects,
      materials: materials ?? this.materials,
      projectSummary: projectSummary ?? this.projectSummary,
      error: error,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMaterials,
    projects,
    materials,
    projectSummary,
    error,
    userName,
  ];
}
