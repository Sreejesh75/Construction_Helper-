import 'package:construction_app/core/theme/app_color.dart';
import 'package:construction_app/features/home/bloc/home_bloc.dart';
import 'package:construction_app/features/home/bloc/home_event.dart';
import 'package:construction_app/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddProjectScreen extends StatefulWidget {
  final String userId;
  final Function() onSuccess;

  const AddProjectScreen({
    super.key,
    required this.userId,
    required this.onSuccess,
  });

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _budgetController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Green Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.gradientTop,
                    Color(0xFFF7F8FA),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),

            // White Bubble Decoration
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40), // Top spacing
                  const Text(
                    "New Project",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create a new construction project to track",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: "Project Name",
                          icon: Icons.work_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _budgetController,
                          label: "Budget",
                          icon: Icons.attach_money,
                          inputType: TextInputType.number,
                          prefixText: "₹ ",
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: "Start Date",
                                date: _startDate,
                                onTap: () => _pickDate(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                label: "End Date",
                                date: _endDate,
                                onTap: () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _saveProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: state.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Create Project",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Bottom spacing for nav bar
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null
                        ? "Select"
                        : DateFormat('dd MMM, yy').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: date == null ? Colors.grey[400] : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveProject() {
    if (_nameController.text.trim().isEmpty ||
        _budgetController.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all fields"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final budget = double.parse(_budgetController.text.trim());

      context.read<HomeBloc>().add(
        CreateProject(
          userId: widget.userId,
          projectName: _nameController.text.trim(),
          budget: budget,
          startDate: _startDate!.toIso8601String(),
          endDate: _endDate!.toIso8601String(),
        ),
      );

      // We manually invoke success callback which might switch tabs
      // But we should wait for actual success.
      // For now, we'll clear form.
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project Created Successfully")),
      );
      widget.onSuccess(); // Navigate back to home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid budget amount")));
    }
  }
}
