import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../bloc/construction_progress_bloc.dart';
import '../../bloc/construction_progress_event.dart';
import '../../bloc/construction_progress_state.dart';
import '../../data/construction_progress_api_service.dart';
import '../widgets/add_progress_sheet.dart';
import '../widgets/progress_timeline_tile.dart';

class ConstructionProgressScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ConstructionProgressScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConstructionProgressBloc(ConstructionProgressApiService())
            ..add(LoadProgress(projectId)),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Light background
        appBar: AppBar(
          title: Text(
            "$projectName Progress",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: _AddProgressFab(projectId: projectId),
        body: const _ProgressBody(),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConstructionProgressBloc, ConstructionProgressState>(
      builder: (context, state) {
        if (state is ConstructionProgressLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ConstructionProgressError) {
          return Center(child: Text("Error: ${state.message}"));
        } else if (state is ConstructionProgressLoaded) {
          if (state.progressList.isEmpty) {
            return _EmptyState();
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _OverallProgressCard(percentage: state.overallPercentage),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.progressList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return ProgressTimelineTile(
                        progress: state.progressList[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  final double percentage;
  const _OverallProgressCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Progress",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No progress tracked yet.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add a stage.",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AddProgressFab extends StatelessWidget {
  final String projectId;
  const _AddProgressFab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final bloc = context.read<ConstructionProgressBloc>();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddProgressSheet(projectId: projectId, bloc: bloc),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
