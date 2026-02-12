import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_event.dart';

class DocumentTile extends StatelessWidget {
  final Map<String, dynamic> document;

  const DocumentTile({super.key, required this.document});

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
