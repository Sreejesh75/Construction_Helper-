import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/networks/api_constants.dart';
import 'models/construction_progress_model.dart';

class ConstructionProgressApiService {
  Future<List<ConstructionProgressModel>> getProgress(String projectId) async {
    try {
      final url = Uri.parse(
        "${ApiConstants.baseUrl}${ApiConstants.getProgress}/$projectId",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => ConstructionProgressModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No progress found, return empty list
      } else {
        throw Exception("Failed to load progress: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching progress: $e");
    }
  }

  Future<void> addOrUpdateProgress(ConstructionProgressModel progress) async {
    try {
      // Check if it's an update (has ID)
      final isUpdate = progress.id != null && progress.id!.isNotEmpty;

      final url = Uri.parse(
        isUpdate
            ? "${ApiConstants.baseUrl}${ApiConstants.updateProgress}"
            : "${ApiConstants.baseUrl}${ApiConstants.addProgress}",
      );

      final response = await (isUpdate ? http.put : http.post)(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(progress.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to save progress: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error saving progress: $e");
    }
  }
}
