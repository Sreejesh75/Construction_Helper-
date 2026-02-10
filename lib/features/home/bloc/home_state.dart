import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isLoadingMaterials;
  final List<dynamic> projects;
  final List<dynamic> materials;
  final Map<String, dynamic>? projectSummary;
  final String? error;
  final String? userName;
  final String? userId; // Added userId
  final bool isLoggedOut;
  final String? updateMessage; // Added updateMessage

  const HomeState({
    this.isLoading = false,
    this.isLoadingMaterials = false,
    this.projects = const [],
    this.materials = const [],
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
    List<dynamic>? projects,
    List<dynamic>? materials,
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
      projects: projects ?? this.projects,
      materials: materials ?? this.materials,
      projectSummary: projectSummary ?? this.projectSummary,
      error: error,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      updateMessage:
          updateMessage, // Don't persist old messages by default, or handle manually. Here we accept null to clear.
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
