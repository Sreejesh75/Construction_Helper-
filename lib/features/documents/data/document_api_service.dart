import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/networks/api_constants.dart';

class DocumentApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<Map<String, dynamic>>> getDocuments(String projectId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getDocuments}/$projectId',
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return List<Map<String, dynamic>>.from(
          response.data['documents'] ?? [],
        );
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      throw Exception('Error loading documents: $e');
    }
  }

  Future<void> uploadDocument({
    required String projectId,
    required File file,
    required String category,
  }) async {
    try {
      String fileName = file.path.split('/').last;

      // Determine mime type (basic check, can be expanded)
      String? mimeType;
      if (fileName.toLowerCase().endsWith('.pdf')) {
        mimeType = 'application/pdf';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }

      FormData formData = FormData.fromMap({
        'projectId': projectId,
        'category': category,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadDocument,
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload document');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.deleteDocument}/$documentId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }
}
