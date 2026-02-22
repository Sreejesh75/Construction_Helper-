import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/networks/api_constants.dart';
import '../models/equipment_model.dart';
import '../models/equipment_log_model.dart';

class EquipmentApiService {
  Future<List<Equipment>> getEquipmentForProject(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.getEquipment}/$projectId',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Equipment.fromJson(e))
              .toList();
        } else if (data['status'] == null && data['data'] != null) {
          // Fallback if status isn't provided but data is
          return (data['data'] as List)
              .map((e) => Equipment.fromJson(e))
              .toList();
        }
      }
      // Also check 201 or other success codes loosely if typical
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => Equipment.fromJson(e)).toList();
        }
      }
      throw Exception('Failed to load equipment');
    } catch (e) {
      throw Exception('Error loading equipment: $e');
    }
  }

  Future<Equipment> addEquipment(Equipment equipment) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addEquipment}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(equipment.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 'success') {
          return Equipment.fromJson(data['data']);
        } else if (data['status'] == null && data['data'] != null) {
          return Equipment.fromJson(data['data']);
        } else if (data['data'] == null && data['id'] != null) {
          return Equipment.fromJson(data);
        }
        return Equipment.fromJson(data); // Last resort fallback
      }
      throw Exception('Failed to add equipment: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding equipment: $e');
    }
  }

  Future<List<EquipmentLog>> getEquipmentLogs(String equipmentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.getEquipmentLogs}/$equipmentId',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => EquipmentLog.fromJson(e))
              .toList();
        } else if (data['status'] == null && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => EquipmentLog.fromJson(e))
              .toList();
        }
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((e) => EquipmentLog.fromJson(e)).toList();
        }
      }
      throw Exception('Failed to load equipment logs');
    } catch (e) {
      throw Exception('Error loading equipment logs: $e');
    }
  }

  Future<EquipmentLog> addEquipmentLog({
    required String equipmentId,
    required DateTime date,
    required double hoursUsed,
    required double fuelConsumed,
    required double fuelCost,
    required String remarks,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addEquipmentLog}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'equipmentId': equipmentId,
          'date': date.toIso8601String(),
          'hoursUsed': hoursUsed,
          'fuelConsumed': fuelConsumed,
          'fuelCost': fuelCost,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 'success') {
          return EquipmentLog.fromJson(data['data']);
        } else if (data['status'] == null && data['data'] != null) {
          return EquipmentLog.fromJson(data['data']);
        } else if (data['data'] == null && data['id'] != null) {
          return EquipmentLog.fromJson(data);
        }
        return EquipmentLog.fromJson(data);
      }
      throw Exception('Failed to add log: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error adding equipment log: $e');
    }
  }

  Future<void> deleteEquipment(String equipmentId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.deleteEquipment}/$equipmentId',
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete equipment');
      }
    } catch (e) {
      throw Exception('Error deleting equipment: $e');
    }
  }

  Future<void> deleteEquipmentLog(String logId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.deleteEquipmentLog}/$logId',
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete equipment log');
      }
    } catch (e) {
      throw Exception('Error deleting equipment log: $e');
    }
  }
}
