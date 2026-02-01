import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_color.dart';
import '../data/document_api_service.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';

class ProjectDocumentsScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectDocumentsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DocumentBloc(DocumentApiService())
            ..add(LoadProjectDocuments(projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Documents - $projectName",
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const _DocumentList(),
        floatingActionButton: _UploadFab(projectId: projectId),
      ),
    );
  }
}

class _DocumentList extends StatelessWidget {
  const _DocumentList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state.isLoading && state.documents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.documents.isEmpty) {
          return Center(child: Text("Error: ${state.error}"));
        }

        if (state.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No documents found",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Group by category (optional optimization, for now flat list)
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: state.documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = state.documents[index];
              return _DocumentTile(document: doc);
            },
          ),
        );
      },
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final Map<String, dynamic> document;

  const _DocumentTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final fileName = document['originalName'] ?? 'Unknown File';
    final category = document['category'] ?? 'Uncategorized';
    final uploadedAt = document['createdAt'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: AppColors.primary),
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(category, style: const TextStyle(fontSize: 10)),
                ),
                if (uploadedAt.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    uploadedAt, // Consider formatting date if string is ISO
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            // Confirm delete
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete Document"),
                content: const Text("Are you sure you want to delete this?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<DocumentBloc>().add(
                        DeleteDocument(
                          documentId: document['_id'],
                          projectId: document['project'], // Or use passed ID
                        ),
                      );
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UploadFab extends StatelessWidget {
  final String projectId;
  const _UploadFab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listenWhen: (previous, current) =>
          previous.uploadSuccess != current.uploadSuccess,
      listener: (context, state) {
        if (state.uploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Document uploaded successfully")),
          );
        }
      },
      child: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        label: const Text("Upload"),
        icon: const Icon(Icons.upload_file),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showUploadDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => _UploadDialog(
        bloc: parentContext.read<DocumentBloc>(),
        projectId: projectId,
      ),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  final DocumentBloc bloc;
  final String projectId;

  const _UploadDialog({required this.bloc, required this.projectId});

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
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
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
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
          // File Selection
          Material(
            color: Colors.grey[50], // Background color here for InkWell
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile == null
                          ? Icons.cloud_upload_outlined
                          : Icons.check_circle_outline,
                      color: _selectedFile == null ? Colors.grey : Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile == null
                          ? "Tap to select file"
                          : _selectedFile!.path.split('/').last,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedFile == null
                            ? Colors
                                  .black87 // Darker for visibility
                            : Colors.black,
                        fontWeight: FontWeight.bold, // "baviagh -> bold"?
                        fontSize: 16, // Larger
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
}
