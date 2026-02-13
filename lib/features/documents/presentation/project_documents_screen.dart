import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../data/document_api_service.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import 'widgets/document_list.dart';
import 'widgets/upload_fab.dart';

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
      child: BlocListener<DocumentBloc, DocumentState>(
        listenWhen: (previous, current) =>
            previous.deleteSuccess != current.deleteSuccess,
        listener: (context, state) {
          if (state.deleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Documents - $projectName",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: DocumentList(projectId: projectId),
          floatingActionButton: UploadFab(projectId: projectId),
        ),
      ),
    );
  }
}
