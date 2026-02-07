import '../../../documents/presentation/project_documents_screen.dart';
import '../../../construction_progress/presentation/screens/construction_progress_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final projectName = project['projectName'] ?? 'Unnamed Project';
    final budget = (project['budget'] ?? 0).toDouble();
    final startDateStr = project['startDate'] ?? '';
    final endDateStr = project['endDate'] ?? '';

    // Date Formatting
    String dateRange = "";
    bool isActive = false;

    try {
      final start = DateTime.parse(startDateStr);
      final end = DateTime.parse(endDateStr);
      final formatter = DateFormat("MMM dd, yyyy");
      dateRange = "${formatter.format(start)} → ${formatter.format(end)}";

      isActive = end.isAfter(DateTime.now());
    } catch (_) {
      dateRange = "Invalid Date";
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, // Solid White
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading, // Dark text
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      isActive ? "Active" : "Completed",
                      style: TextStyle(
                        color: isActive ? AppColors.primary : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.subtitle, // Grey icon
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateRange,
                    style: TextStyle(
                      color: AppColors.subtitle, // Grey text
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(budget),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary, // Green
                    ),
                  ),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.folder_open_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDocumentsScreen(
                                projectId: project['_id'] ?? '',
                                projectName: projectName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.timelapse_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConstructionProgressScreen(
                                projectId: project['_id'] ?? '',
                                projectName: projectName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(icon: Icons.edit_outlined, onTap: onEdit),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        onTap: onDelete,
                        isDelete: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDelete;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.red.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDelete ? Colors.red : AppColors.primary,
        ),
      ),
    );
  }
}
