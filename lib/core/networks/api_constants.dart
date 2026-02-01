class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:3000";

  // User APIs
  static const String createUser = "/api/create-user";
  static const String updateName = "/api/update-name";

  // Project APIs
  static const String createProject = "/api/create-project";
  static const String getProjects = "/api/projects"; // /:userId
  static const String updateProject = "/api/update-project"; // /:projectId
  static const String deleteProject = "/api/delete-project"; // /:projectId

  //  Material APIs
  static const String addMaterial = "/api/add-material";
  static const String getMaterials = "/api/materials"; // /:projectId
  static const String updateMaterial = "/api/update-material"; // /:materialId
  static const String deleteMaterial = "/api/delete-material"; // /:materialId

  // Summary API
  static const String projectSummary = "/api/project-summary"; // /:projectId
  
  // Document APIs
  static const String uploadDocument = "/api/upload-document";
  static const String getDocuments = "/api/documents"; // /:projectId
  static const String deleteDocument = "/api/delete-document"; // /:documentId
}
