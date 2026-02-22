import 'package:construction_app/features/home/presentation/widgets/add_material_bottom_sheet.dart';
import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/home/presentation/widgets/dashboard_stats.dart';
import 'package:construction_app/features/home/presentation/widgets/category_filter_bar.dart';
import 'package:construction_app/features/home/presentation/widgets/material_list.dart';
import 'package:construction_app/features/home/presentation/widgets/material_history_sheet.dart'; // Added
import 'package:construction_app/features/home/presentation/widgets/log_usage_dialog.dart';

import 'package:flutter/material.dart';

import 'package:construction_app/features/home/bloc/home_bloc.dart';
import 'package:construction_app/features/home/bloc/home_event.dart';
import 'package:construction_app/features/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:construction_app/features/labour_tracking/presentation/screens/labour_screen.dart';
import 'package:construction_app/features/equipment_tracking/presentation/screens/equipment_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final List<dynamic> projects;
  final String? projectId;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.projects,
    this.projectId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      context.read<HomeBloc>().add(LoadProjectSummary(widget.projectId!));
      context.read<HomeBloc>().add(LoadMaterials(widget.projectId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.updateMessage != current.updateMessage &&
          current.updateMessage != null,
      listener: (context, state) {
        if (state.updateMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Determine values to show
          int totalProjectsVal = widget.projects.length;
          int activeProjectsVal;
          double totalBudgetVal = 0;

          dynamic summary = state.projectSummary;
          bool isSingleProjectConfig =
              widget.projectId != null && summary != null;

          if (isSingleProjectConfig) {
            totalProjectsVal = summary['materialsCount'] ?? 0;
            activeProjectsVal = summary['totalSpent'] ?? 0;
            totalBudgetVal = (summary['budget'] ?? 0).toDouble();
          } else {
            activeProjectsVal = widget.projects.where((p) {
              try {
                if (p['endDate'] == null) return true;
                final end = DateTime.parse(p['endDate']);
                return end.isAfter(DateTime.now());
              } catch (e) {
                return false;
              }
            }).length;

            for (var p in widget.projects) {
              if (p['budget'] is num) {
                totalBudgetVal += p['budget'];
              }
            }
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            floatingActionButton: isSingleProjectConfig
                ? FloatingActionButton(
                    onPressed: () => _showAddMaterialDialog(context),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text(
                isSingleProjectConfig
                    ? (summary['projectName'] ?? "Project Insights")
                    : "Project Insights",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.gradientTop,
                    Color(0xFFF5F7FA),
                  ],
                  stops: [0.0, 0.4, 0.4],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(
                        height: 110 + MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              "Overview",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isSingleProjectConfig
                                  ? "Project Summary"
                                  : (widget.projects.isEmpty
                                        ? "No Data"
                                        : "Financial Summary"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      DashboardStats(
                        totalProjects: totalProjectsVal,
                        activeProjects: activeProjectsVal,
                        totalBudget: totalBudgetVal,
                        isSingleProject: isSingleProjectConfig,
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 10, // Reduced top padding
                            bottom: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isSingleProjectConfig)
                                    Text(
                                      "Analytics",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  if (!isSingleProjectConfig)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "This Month",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (isSingleProjectConfig) ...[
                                // Management Section
                                Row(
                                  children: [
                                    const Text(
                                      "Management",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Labour Tracking Entry Point
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LabourScreen(
                                            projectId: widget.projectId!,
                                            projectName:
                                                summary?['projectName'] ??
                                                'Project',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.engineering,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Labour Tracking",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.orange[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    "Manage contracts & daily wages",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.orange[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Equipment Tracking Entry Point
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EquipmentScreen(
                                            projectId: widget.projectId!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.precision_manufacturing,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Equipment & Machinery",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.blue[800],
                                                    ),
                                                  ),
                                                  Text(
                                                    "Track rentals & fuel logs",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Row(
                                  children: [
                                    Text(
                                      isSingleProjectConfig
                                          ? "Materials"
                                          : "Analytics",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                CategoryFilterBar(
                                  selectedCategory: _selectedCategory,
                                  onCategorySelected: (category) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                MaterialList(
                                  materials: state.materials.where((m) {
                                    if (_selectedCategory == "All") {
                                      return true;
                                    }

                                    final matCategory =
                                        (m['category'] as String?)?.trim() ??
                                        "";

                                    return matCategory.toLowerCase() ==
                                        _selectedCategory.toLowerCase();
                                  }).toList(),
                                  onEdit: (m) =>
                                      _showAddMaterialDialog(context, m),
                                  onDelete: (m) => context.read<HomeBloc>().add(
                                    DeleteMaterial(
                                      materialId: m['_id'],
                                      projectId: widget.projectId!,
                                    ),
                                  ),
                                  onHistory: (m) =>
                                      _showMaterialHistory(context, m),
                                  onLogUsage: (m, _, __) =>
                                      _showLogUsageDialog(context, m),
                                ),
                              ] else
                                Container(
                                  height: 220,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.grey.shade100,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.bar_chart_rounded,
                                        size: 48,
                                        color: Colors.grey[300],
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        child: Text(
                                          "No analytics data available",
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddMaterialDialog(
    BuildContext context, [
    Map<String, dynamic>? material,
  ]) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMaterialBottomSheet(material: material),
    );

    if (result != null && mounted) {
      if (material == null) {
        // Add
        context.read<HomeBloc>().add(
          AddMaterial(
            projectId: widget.projectId!,
            name: result['name'],
            category: result['category'],
            quantity: result['quantity'],
            unit: result['unit'],
            price: result['price'],
            supplier: result['supplier'],
            date: result['date'],
          ),
        );
      } else {
        // Update
        context.read<HomeBloc>().add(
          UpdateMaterial(
            materialId: material['_id'],
            projectId: widget.projectId!,
            name: result['name'],
            category: result['category'],
            quantity: result['quantity'],
            unit: result['unit'],
            price: result['price'],
            supplier: result['supplier'],
            date: result['date'],
          ),
        );
      }
    }
  }

  Future<void> _showMaterialHistory(
    BuildContext context,
    Map<String, dynamic> material,
  ) async {
    // Load history
    context.read<HomeBloc>().add(LoadMaterialHistory(material['_id']));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return MaterialHistorySheet(
            material: material,
            history: state.materialHistory,
            isLoading: state.isLoadingHistory,
          );
        },
      ),
    );
  }

  Future<void> _showLogUsageDialog(
    BuildContext context,
    Map<String, dynamic> material,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => LogUsageDialog(
        material: material,
        onLogUsage: (quantity, remark) {
          context.read<HomeBloc>().add(
            LogMaterialUsage(
              materialId: material['_id'],
              projectId: widget.projectId!,
              quantityUsed: quantity,
              remark: remark,
            ),
          );
        },
      ),
    );
  }
}
