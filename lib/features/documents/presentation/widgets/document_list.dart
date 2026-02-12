import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_state.dart';
import 'document_tile.dart';

class DocumentList extends StatelessWidget {
  const DocumentList({super.key});

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
              return DocumentTile(document: doc);
            },
          ),
        );
      },
    );
  }
}
