import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_state.dart';
import 'document_upload_dialog.dart';

class UploadFab extends StatelessWidget {
  final String projectId;
  const UploadFab({super.key, required this.projectId});

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
      builder: (context) => DocumentUploadDialog(
        bloc: parentContext.read<DocumentBloc>(),
        projectId: projectId,
      ),
    );
  }
}
