import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../../../core/theme/app_color.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_event.dart';

class DocumentUploadDialog extends StatefulWidget {
  final DocumentBloc bloc;
  final String projectId;

  const DocumentUploadDialog({
    super.key,
    required this.bloc,
    required this.projectId,
  });

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  File? _selectedFile;
  String _selectedCategory = "Invoice";
  final List<String> _categories = [
    "Invoice",
    "Blueprint",
    "Permit",
    "Contract",
    "Receipt",
    "Other",
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Ensure any file type
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _scanReceipt() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Camera permission is required to scan"),
            ),
          );
        }
        return;
      }
    }

    try {
      final documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          mode: ScannerMode.full,
          isGalleryImport: true,
          pageLimit: 1,
        ),
      );

      final result = await documentScanner.scanDocument();
      if (result.images != null && result.images!.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.images!.first);
          _selectedCategory = "Receipt"; // Auto-select Receipt
        });
      }
    } catch (e) {
      debugPrint("Error scanning document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Upload Document"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Selection Area
          if (_selectedFile != null)
            Material(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  // Allow re-selection
                  setState(() => _selectedFile = null);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile!.path.split('/').last,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Tap to change",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildSelectionButton(
                    icon: Icons.upload_file,
                    label: "Pick File",
                    onTap: _pickFile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectionButton(
                    icon: Icons.document_scanner,
                    label: "Scan",
                    onTap: _scanReceipt,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),
          // Category Dropdown
          const Text(
            "Category",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _selectedFile == null
              ? null
              : () {
                  widget.bloc.add(
                    UploadDocument(
                      projectId: widget.projectId,
                      file: _selectedFile!,
                      category: _selectedCategory,
                    ),
                  );
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Upload"),
        ),
      ],
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[50], // Background
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
