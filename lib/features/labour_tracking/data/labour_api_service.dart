import '../../../core/networks/dio_client.dart';
import '../../../core/networks/api_constants.dart';
import 'labour_model.dart'; // Import created model

class LabourApiService {
  final _dio = DioClient.instance;

  Future<List<Labour>> getLabourRecords(String projectId) async {
    try {
      final response = await _dio.get("${ApiConstants.getLabour}/$projectId");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => Labour.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load labour records");
      }
    } catch (e) {
      throw Exception("Error fetching labour records: $e");
    }
  }

  Future<void> addLabourRecord(Labour labour) async {
    try {
      // Convert model to JSON for request body
      final response = await _dio.post(
        ApiConstants.addLabour,
        data: labour.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add labour record");
      }
    } catch (e) {
      throw Exception("Error adding labour record: $e");
    }
  }
}
