import 'dart:typed_data';

import 'package:construction_app/core/networks/api_constants.dart';
import 'package:construction_app/core/networks/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EodReportService {
  static Future<void> generateAndShowEodReport(
    String projectId,
    String projectName,
  ) async {
    try {
      final dio = DioClient.instance;
      // Get today's date
      final date = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/daily-summary/$projectId?date=$dateString',
      );

      if (response.data['status'] == true) {
        final data = response.data;
        final pdfBytes = await _createPdf(data, projectName, date);

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'EOD_Report_${projectName}_${dateString}.pdf',
        );
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      print('Error generating EOD report: $e');
      rethrow;
    }
  }

  static Future<Uint8List> _createPdf(
    Map<String, dynamic> data,
    String projectName,
    DateTime date,
  ) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd MMM yyyy').format(date);

    final materials = List<Map<String, dynamic>>.from(data['materials'] ?? []);
    final labour = List<Map<String, dynamic>>.from(data['labour'] ?? []);
    final equipment = List<Map<String, dynamic>>.from(data['equipment'] ?? []);

    final totalLabourCost = data['totalLabourCost'] ?? 0;
    final totalEquipmentCost = data['totalEquipmentCost'] ?? 0;
    final totalDailyCost = data['totalDailyCost'] ?? 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(projectName, dateStr),
            pw.SizedBox(height: 20),

            _buildSectionTitle('Materials Details'),
            materials.isEmpty
                ? pw.Text('No material activity today.')
                : _buildMaterialTable(materials),

            pw.SizedBox(height: 20),

            _buildSectionTitle('Labour Details'),
            labour.isEmpty
                ? pw.Text('No labour logged today.')
                : _buildLabourTable(labour, totalLabourCost),

            pw.SizedBox(height: 20),

            _buildSectionTitle('Equipment Usage Notes'),
            equipment.isEmpty
                ? pw.Text('No equipment usage logged today.')
                : _buildEquipmentTable(equipment, totalEquipmentCost),

            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Today\'s Expenditure:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Rs. ${totalDailyCost.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String projectName, String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'End-of-Day (EOD) Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Project: $projectName', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Date: $dateStr', style: pw.TextStyle(fontSize: 16)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: PdfColors.grey200,
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildMaterialTable(List<Map<String, dynamic>> materials) {
    return pw.TableHelper.fromTextArray(
      headers: ['Material Name', 'Added Qty', 'Used Qty', 'Cost'],
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey600),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      cellAlignment: pw.Alignment.centerLeft,
      data: materials
          .map(
            (m) => [
              m['name'].toString(),
              m['added'].toString(),
              m['used'].toString(),
              'Rs. ${m['cost']?.toStringAsFixed(2) ?? '0.00'}',
            ],
          )
          .toList(),
    );
  }

  static pw.Widget _buildLabourTable(
    List<Map<String, dynamic>> labour,
    dynamic totalCost,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.TableHelper.fromTextArray(
          headers: ['Labour Mode', 'Cost Logged'],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.orange600),
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          cellAlignment: pw.Alignment.centerLeft,
          data: labour
              .map(
                (l) => [
                  (l['mode'] ?? '').toString().toUpperCase(),
                  'Rs. ${l['cost']?.toStringAsFixed(2) ?? '0.00'}',
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Total Labour Cost: Rs. ${totalCost.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildEquipmentTable(
    List<Map<String, dynamic>> equipment,
    dynamic totalCost,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.TableHelper.fromTextArray(
          headers: ['Equipment', 'Hours Used', 'Total Cost'],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green600),
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          cellAlignment: pw.Alignment.centerLeft,
          data: equipment
              .map(
                (e) => [
                  e['name'].toString(),
                  e['hoursUsed'].toString(),
                  'Rs. ${e['totalCost']?.toStringAsFixed(2) ?? '0.00'}',
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Total Equipment Cost: Rs. ${totalCost.toStringAsFixed(2)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
