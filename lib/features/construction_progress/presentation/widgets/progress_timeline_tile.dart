import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';
import '../../data/models/construction_progress_model.dart';
import '../widgets/add_progress_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/construction_progress_bloc.dart';

class ProgressTimelineTile extends StatelessWidget {
  final ConstructionProgressModel progress;

  const ProgressTimelineTile({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress.status == 'Completed';
    final isInProgress = progress.status == 'In Progress';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle_outlined;

    if (isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isInProgress) {
      statusColor = AppColors.primary;
      statusIcon = Icons.timelapse;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.start;
    }

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (childContext) => AddProgressSheet(
            // Reusing Add Sheet for Edit
            projectId: progress.projectId,
            existingProgress: progress,
            bloc: context.read<ConstructionProgressBloc>(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSectionIcon(progress.section),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.section,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            progress.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${progress.progress}%",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.progress / 100,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (progress.startDate.isNotEmpty)
                  _DateBadge(
                    label: "Start",
                    date: progress.startDate,
                    color: Colors.blueGrey,
                  ),
                if (progress.endDate.isNotEmpty)
                  _DateBadge(
                    label: "End",
                    date: progress.endDate,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            if (progress.remarks.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      progress.remarks,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'Foundation':
        return Icons.foundation;
      case 'Structure':
        return Icons
            .apartment; // Material Design doesn't have structure, apartment is close
      case 'Brickwork':
        return Icons.grid_view;
      case 'Plastering':
        return Icons.format_paint;
      case 'Flooring':
        return Icons.layers;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Painting':
        return Icons.format_color_fill;
      case 'Finishing':
        return Icons.check_circle_outline;
      default:
        return Icons.construction;
    }
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  final String date;
  final Color color;

  const _DateBadge({
    required this.label,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _formatDate(date),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date);
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }
}
