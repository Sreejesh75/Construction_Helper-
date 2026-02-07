import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';

class AddProjectBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? project;
  final bool isFullScreen;

  const AddProjectBottomSheet({
    super.key,
    this.project,
    this.isFullScreen = false,
  });

  @override
  State<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends State<AddProjectBottomSheet> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!['projectName'] ?? '';
      _budgetController.text = (widget.project!['budget'] ?? '').toString();
      try {
        _startDate = DateTime.tryParse(widget.project!['startDate'] ?? '');
        _endDate = DateTime.tryParse(widget.project!['endDate'] ?? '');
      } catch (_) {}
    }
  }

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
          // Reset end date if it's before start date
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.gradientTop],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White Bubble Decoration
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isFullScreen)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                SizedBox(height: widget.isFullScreen ? 10 : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? "Edit Project" : "New Project",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!widget.isFullScreen)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // White Content Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _budgetController,
                        label: "Budget",
                        icon: Icons.attach_money,
                        inputType: TextInputType.number,
                        prefixText: "₹ ",
                      ),
                      const SizedBox(height: 20),
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
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveProject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isEditing ? "Update Project" : "Create Project",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        color: Colors.grey[50], // Soft background
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
      Navigator.pop(context, {
        "projectName": _nameController.text.trim(),
        "budget": budget,
        "startDate": _startDate!.toIso8601String(),
        "endDate": _endDate!.toIso8601String(),
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid budget amount")));
    }
  }
}
