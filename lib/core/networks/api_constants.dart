class ApiConstants {
  static const String baseUrl = "https://api-construction-ehe5.onrender.com";

  // "http://10.0.2.2:3000";

  // User APIs
  static const String createUser = "/api/create-user";
  static const String updateName = "/api/update-name";
  static const String logout = "/api/logout";

  // Project APIs
  static const String createProject = "/api/create-project";
  static const String getProjects = "/api/projects";
  static const String updateProject = "/api/update-project";
  static const String deleteProject = "/api/delete-project";

  //  Material APIs
  static const String addMaterial = "/api/add-material";
  static const String getMaterials = "/api/materials";
  static const String updateMaterial = "/api/update-material";
  static const String deleteMaterial = "/api/delete-material";

  // Summary API
  static const String projectSummary = "/api/project-summary";

  // Document APIs
  static const String uploadDocument = "/api/upload-document";
  static const String getDocuments = "/api/documents";
  static const String deleteDocument = "/api/delete-document";

  // Construction Progress APIs
  static const String addProgress = "/api/progress/add";
  static const String getProgress = "/api/progress";
  static const String updateProgress = "/api/progress/update";
}
