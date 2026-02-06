import 'package:construction_app/features/auth/presentation/login_screen.dart';
import 'package:construction_app/features/home/presentation/dashboard_screen.dart';
import 'package:construction_app/features/home/presentation/widgets/add_project_bottom_sheet.dart';
import 'package:construction_app/features/home/presentation/widgets/home_header.dart';
import 'package:construction_app/features/home/presentation/widgets/home_summary_card.dart';
import 'package:construction_app/features/home/presentation/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isNewUser;
  final bool fromMainScreen;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.isNewUser = false,
    this.fromMainScreen = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load projects when the screen initializes
    context.read<HomeBloc>().add(
      LoadProjects(widget.userId, userName: widget.userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.fromMainScreen
        ? _buildBody(context)
        : Scaffold(
            body: SafeArea(child: _buildBody(context)),
            floatingActionButton: _buildFab(context),
          );
  }

  Widget _buildBody(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Calculate Stats
          double totalBudget = 0;
          int activeProjectsCount = 0;

          for (var project in state.projects) {
            totalBudget += (project['budget'] ?? 0).toDouble();

            // Check active status
            try {
              final endDate = DateTime.parse(project['endDate']);
              if (endDate.isAfter(DateTime.now())) {
                activeProjectsCount++;
              }
            } catch (_) {}
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeHeader(
                      userName: state.userName ?? widget.userName,
                      isNewUser: widget.isNewUser,
                      userId: widget.userId,
                      isDarkBackground: false,
                    ),
   const SizedBox(height: 25),
                    // Stats Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: HomeSummaryCard(
                        totalBudget: totalBudget,
                        // totalProjects: totalProjects, // Removed
                        activeProjects: activeProjectsCount,
                        onActiveProjectsTap: () {
                          if (state.projects.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DashboardScreen(
                                  userName: widget.userName,
                                  projects: state.projects,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              if (state.projects.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 30, // Adjust spacing
                    bottom: 10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Projects",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.heading,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "View All",
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final project = state.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DashboardScreen(
                                  userName: widget.userName,
                                  projects: state.projects,
                                  projectId:
                                      project['_id'], // Pass ID to enable single-project/material mode
                                ),
                              ),
                            );
                          },
                          child: ProjectCard(
                            project: project,
                            onEdit: () =>
                                _handleProjectAction(context, project: project),
                            onDelete: () =>
                                _confirmDelete(context, project['_id']),
                          ),
                        ),
                      );
                    }, childCount: state.projects.length),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ), // Bottom padding
              ] else ...[
                // Empty State
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No projects yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your first project to get started",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _handleProjectAction(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "New Project",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _handleProjectAction(
    BuildContext context, {
    Map<String, dynamic>? project,
  }) async {
    final isEditing = project != null;
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectBottomSheet(project: project),
    );

    if (result != null && result is Map) {
      final projectName = result["projectName"];
      final budget = result["budget"];
      final startDate = result["startDate"];
      final endDate = result["endDate"];

      if (projectName is String &&
          budget is double &&
          startDate is String &&
          endDate is String) {
        if (isEditing) {
          context.read<HomeBloc>().add(
            UpdateProject(
              projectId: project['_id'],
              userId: widget.userId,
              projectName: projectName,
              budget: budget,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        } else {
          context.read<HomeBloc>().add(
            CreateProject(
              userId: widget.userId,
              projectName: projectName,
              budget: budget,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        }
      }
    }
  }

  void _confirmDelete(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomeBloc>().add(
                DeleteProject(userId: widget.userId, projectId: projectId),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
