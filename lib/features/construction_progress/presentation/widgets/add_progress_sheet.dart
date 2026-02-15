import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../data/models/construction_progress_model.dart';
import '../../bloc/construction_progress_bloc.dart';
import '../../bloc/construction_progress_event.dart';

class AddProgressSheet extends StatefulWidget {
  final String projectId;
  final ConstructionProgressModel? existingProgress;
  final ConstructionProgressBloc bloc;

  const AddProgressSheet({
    super.key,
    required this.projectId,
    this.existingProgress,
    required this.bloc,
  });

  @override
  State<AddProgressSheet> createState() => _AddProgressSheetState();
}

class _AddProgressSheetState extends State<AddProgressSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _section;
  double _progress = 0;
  String _status = 'Start';
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _remarksController;
  bool _showWarning = false;

  final List<String> _sections = [
    'Foundation',
    'Structure',
    'Brickwork',
    'Plastering',
    'Flooring',
    'Plumbing',
    'Electrical',
    'Painting',
    'Finishing',
    'Other',
  ];

  final List<String> _statuses = ['Start', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _section = widget.existingProgress?.section ?? _sections.first;
    _progress = widget.existingProgress?.progress.toDouble() ?? 0;
    _status = widget.existingProgress?.status ?? 'Start';
    _startDateController = TextEditingController(
      text: widget.existingProgress?.startDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.existingProgress?.endDate ?? '',
    );
    _remarksController = TextEditingController(
      text: widget.existingProgress?.remarks ?? '',
    );

    // Initial sync if adding new
    if (widget.existingProgress == null) {
      _updateValues(_status);
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _updateValues(String status) {
    setState(() {
      _status = status;
      if (status == 'Start') {
        _progress = 0;
        if (_startDateController.text.isEmpty) {
          _startDateController.text = _formatDate(DateTime.now());
        }
      } else if (status == 'In Progress') {
        _progress = 50;
        // Keep existing start date or set if empty
        if (_startDateController.text.isEmpty) {
          _startDateController.text = _formatDate(DateTime.now());
        }
      } else if (status == 'Completed') {
        _progress = 100;
        if (_endDateController.text.isEmpty) {
          _endDateController.text = _formatDate(DateTime.now());
        }
        // Ensure start date is set if jumped straight to completed
        if (_startDateController.text.isEmpty) {
          _startDateController.text = _formatDate(DateTime.now());
        }
      }
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newProgress = ConstructionProgressModel(
        id: widget.existingProgress?.id,
        projectId: widget.projectId,
        section: _section,
        progress: _progress.toInt(),
        status: _status,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        remarks: _remarksController.text,
      );

      widget.bloc.add(AddOrUpdateProgress(newProgress));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingProgress == null
                    ? "Add Progress"
                    : "Update Progress",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              if (_showWarning)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "you can set section only once",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 8),

              // Section Dropdown
              GestureDetector(
                onTap: () {
                  if (widget.existingProgress != null) {
                    setState(() {
                      _showWarning = true;
                    });
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _showWarning = false;
                        });
                      }
                    });
                  }
                },
                child: AbsorbPointer(
                  absorbing: widget.existingProgress != null,
                  child: DropdownButtonFormField<String>(
                    value: _sections.contains(_section) ? _section : 'Other',
                    decoration: const InputDecoration(
                      labelText: "Section",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _sections
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _section = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _updateValues(val);
                },
              ),
              const SizedBox(height: 16),

              // Progress Indicator (Read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Text(
                      "Progress",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_progress.toInt()}%",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dates Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: "Start Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: "End Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                      // End date is optional until completed, but let's keep it flexible
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    widget.existingProgress == null ? "Save" : "Update",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
