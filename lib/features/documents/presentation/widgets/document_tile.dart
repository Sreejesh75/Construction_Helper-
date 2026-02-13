import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/networks/api_constants.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_event.dart';

class DocumentTile extends StatelessWidget {
  final Map<String, dynamic> document;
  final String projectId;

  const DocumentTile({
    super.key,
    required this.document,
    required this.projectId,
  });

  Future<void> _openDocument(BuildContext context) async {
    try {
      final String? path = document['path'] ?? document['url'];
      if (path != null && path.isNotEmpty) {
        // Construct full URL if it's a relative path
        final uri = Uri.parse(
          path.startsWith('http') ? path : '${ApiConstants.baseUrl}/$path',
        );

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not launch document'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document URL not found. Keys: ${document.keys.join(", ")}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      child: InkWell(
        onTap: () => _openDocument(context),
        borderRadius: BorderRadius.circular(12),
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
              // Capture the bloc from the valid context
              final documentBloc = context.read<DocumentBloc>();

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
                        documentBloc.add(
                          DeleteDocument(
                            documentId: document['_id'],
                            projectId: projectId,
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
      ),
    );
  }
}
