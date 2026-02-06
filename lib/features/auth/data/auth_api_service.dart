import 'package:construction_app/core/networks/api_constants.dart';
import 'package:construction_app/core/networks/dio_client.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  /// Create or return existing user
  Future<Map<String, dynamic>> loginWithEmail({
    required String name,
    required String email,
  }) async {
    print(
      "AuthApiService: Attempting login for $email at ${ApiConstants.baseUrl}${ApiConstants.createUser}",
    );
    try {
      final response = await _dio.post(
        ApiConstants.createUser,
        data: {"name": name, "email": email},
      );
      print("AuthApiService: Response received: ${response.statusCode}");

      if (response.data["status"] == true) {
        final isNew =
            response.statusCode == 201 || (response.data["isNewUser"] ?? false);

        return {
          "userId": response.data["userId"],
          "name": response.data["name"] ?? name,
          "isNewUser": isNew,
        };
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("AuthApiService: DioException caught: ${e.type} - ${e.message}");
      String errorMessage = "Login failed";

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Connection timed out. Is the server running?";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Unable to connect to server. Check your connection.";
      } else if (e.response != null) {
        print("AuthApiService: Server Error Data: ${e.response?.data}");
        errorMessage =
            e.response?.data["message"] ??
            "Server error: ${e.response?.statusCode}";
      } else {
        errorMessage = e.message ?? "Unknown error occurred";
      }

      throw Exception(errorMessage);
    } catch (e) {
      print("AuthApiService: Unexpected error: $e");
      rethrow;
    }
  }

  /// Update user name
  Future<void> updateUserName({
    required String userId,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateName,
        data: {"userId": userId, "name": name},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data["message"] ?? "Failed to update name");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Update failed");
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);

      if (response.statusCode != 200) {
        // Even if it fails server-side, we should probably still assume logout on client
        // but let's throw for now if strictly checking
        // throw Exception(response.data["message"] ?? "Failed to logout");
        // Actually, for logout, best effort is usually fine.
      }
    } on DioException catch (e) {
      // Log error but generally we want to proceed with client-side logout
      print("Logout API error: ${e.message}");
    }
  }
}
