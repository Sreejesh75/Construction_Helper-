import '../../../core/networks/dio_client.dart';
import '../../../core/networks/api_constants.dart';

class HomeApiService {
  final _dio = DioClient.instance;

  /// CREATE PROJECT

  Future<String> createProject({
    required String userId,
    required String projectName,
    required double budget,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.post(
      ApiConstants.createProject,
      data: {
        "userId": userId,
        "projectName": projectName,
        "budget": budget,
        "startDate": startDate,
        "endDate": endDate,
      },
    );

    if (response.data['status'] == true) {
      return response.data['projectId'];
    } else {
      throw Exception(response.data['message']);
    }
  }

  // GET PROJECTS (by userId)

  Future<List<dynamic>> getProjects(String userId) async {
    final response = await _dio.get("${ApiConstants.getProjects}/$userId");

    if (response.data['status'] == true) {
      return response.data['projects'];
    } else {
      throw Exception("Failed to fetch projects");
    }
  }

  /// UPDATE PROJECT

  Future<void> updateProject({
    required String projectId,
    required String projectName,
    required double budget,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.put(
      "${ApiConstants.updateProject}/$projectId",
      data: {
        "projectName": projectName,
        "budget": budget,
        "startDate": startDate,
        "endDate": endDate,
      },
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// DELETE PROJECT

  Future<void> deleteProject(String projectId) async {
    final response = await _dio.delete(
      "${ApiConstants.deleteProject}/$projectId",
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// PROJECT SUMMARY

  Future<Map<String, dynamic>> getProjectSummary(String projectId) async {
    final response = await _dio.get(
      "${ApiConstants.projectSummary}/$projectId",
    );

    if (response.data['status'] == true) {
      return response.data;
    } else {
      throw Exception("Failed to fetch project summary");
    }
  }
  // ... inside HomeApiService class

  /// ADD MATERIAL
  Future<void> addMaterial(Map<String, dynamic> materialData) async {
    final response = await _dio.post(
      ApiConstants.addMaterial,
      data: materialData,
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// GET MATERIALS
  Future<List<dynamic>> getMaterials(String projectId) async {
    final response = await _dio.get("${ApiConstants.getMaterials}/$projectId");

    if (response.data['status'] == true) {
      return response.data['materials'] ?? [];
    } else {
      throw Exception("Failed to fetch materials");
    }
  }

  /// UPDATE MATERIAL
  Future<void> updateMaterial(
    String materialId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      "${ApiConstants.updateMaterial}/$materialId",
      data: data,
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message']);
    }
  }

  /// DELETE MATERIAL
  Future<void> deleteMaterial(String materialId) async {
    final response = await _dio.delete(
      "${ApiConstants.deleteMaterial}/$materialId",
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['message']);
    }
  }
}
