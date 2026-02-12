import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isLoadingMaterials;
  final bool isLoadingHistory; // Added
  final List<dynamic> projects;
  final List<dynamic> materials;
  final List<dynamic> materialHistory; // Added
  final Map<String, dynamic>? projectSummary;
  final String? error;
  final String? userName;
  final String? userId;
  final bool isLoggedOut;
  final String? updateMessage;

  const HomeState({
    this.isLoading = false,
    this.isLoadingMaterials = false,
    this.isLoadingHistory = false, // Added
    this.projects = const [],
    this.materials = const [],
    this.materialHistory = const [], // Added
    this.projectSummary,
    this.error,
    this.userName,
    this.userId,
    this.isLoggedOut = false,
    this.updateMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isLoadingMaterials,
    bool? isLoadingHistory, // Added
    List<dynamic>? projects,
    List<dynamic>? materials,
    List<dynamic>? materialHistory, // Added
    Map<String, dynamic>? projectSummary,
    String? error,
    String? userName,
    String? userId,
    bool? isLoggedOut,
    String? updateMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMaterials: isLoadingMaterials ?? this.isLoadingMaterials,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory, // Added
      projects: projects ?? this.projects,
      materials: materials ?? this.materials,
      materialHistory: materialHistory ?? this.materialHistory, // Added
      projectSummary: projectSummary ?? this.projectSummary,
      error: error,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      updateMessage: updateMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingMaterials,
    isLoadingHistory, // Added
    projects,
    materials,
    materialHistory, // Added
    projectSummary,
    error,
    userName,
    userId,
    isLoggedOut,
    updateMessage,
  ];

  Map<String, dynamic> toJson() {
    return {
      'projects': projects,
      'materials': materials,
      'projectSummary': projectSummary,
      'userName': userName,
      'userId': userId,
      'isLoggedOut': isLoggedOut,
    };
  }

  factory HomeState.fromJson(Map<String, dynamic> json) {
    return HomeState(
      projects: json['projects'] ?? [],
      materials: json['materials'] ?? [],
      projectSummary: json['projectSummary'],
      userName: json['userName'],
      userId: json['userId'],
      isLoggedOut: json['isLoggedOut'] ?? false,
    );
  }
}
