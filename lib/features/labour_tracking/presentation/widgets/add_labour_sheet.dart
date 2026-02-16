import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';

class AddLabourSheet extends StatefulWidget {
  final Map<String, dynamic>? labour; // For future edit support

  const AddLabourSheet({super.key, this.labour});

  @override
  State<AddLabourSheet> createState() => _AddLabourSheetState();
}

class _AddLabourSheetState extends State<AddLabourSheet> {
  String _mode = 'contract'; // 'contract' or 'daily'
  DateTime _date = DateTime.now();

  // Contract Mode Controllers
  final _contractorNameController = TextEditingController();
  final _estimatedAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  // Daily Mode Data
  final List<Map<String, dynamic>> _labourers = []; // [{name: '', wage: 0.0}]
  final _labourerNameController = TextEditingController();
  final _labourerWageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize if editing (not fully implemented yet as per requirement, but structure allows)
  }

  @override
  void dispose() {
    _contractorNameController.dispose();
    _estimatedAmountController.dispose();
    _paidAmountController.dispose();
    _labourerNameController.dispose();
    _labourerWageController.dispose();
    super.dispose();
  }

  void _addLabourer() {
    final name = _labourerNameController.text.trim();
    final wage = double.tryParse(_labourerWageController.text.trim()) ?? 0.0;

    if (name.isNotEmpty && wage > 0) {
      setState(() {
        _labourers.add({'name': name, 'wage': wage});
        _labourerNameController.clear();
        _labourerWageController.clear();
      });
    }
  }

  void _removeLabourer(int index) {
    setState(() {
      _labourers.removeAt(index);
    });
  }

  double _calculateDailyTotal() {
    return _labourers.fold(0.0, (sum, item) => sum + (item['wage'] as double));
  }

  void _save() {
    if (_mode == 'contract') {
      if (_contractorNameController.text.isEmpty ||
          _paidAmountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill contractor name and paid amount"),
          ),
        );
        return;
      }
    } else {
      if (_labourers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at least one labourer")),
        );
        return;
      }
    }

    final Map<String, dynamic> data = {
      'mode': _mode,
      'date': _date.toIso8601String(),
    };

    if (_mode == 'contract') {
      data['contractDetails'] = {
        'contractorName': _contractorNameController.text.trim(),
        'estimatedAmount':
            double.tryParse(_estimatedAmountController.text.trim()) ?? 0.0,
        'paidAmount': double.tryParse(_paidAmountController.text.trim()) ?? 0.0,
      };
    } else {
      data['dailyLabourDetails'] = {
        'labourers': _labourers,
        'totalAmount': _calculateDailyTotal(),
      };
    }

    Navigator.pop(context, data);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
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
      setState(() => _date = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Labour Record",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mode Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildModeTab("Contract", "contract"),
                  _buildModeTab("Daily Wage", "daily"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker
            _buildDatePicker(label: "Date", date: _date, onTap: _pickDate),
            const SizedBox(height: 20),

            // Form Fields
            if (_mode == 'contract') _buildContractForm(),
            if (_mode == 'daily') _buildDailyForm(),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: const Text(
                  "Save Record",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, String value) {
    final isSelected = _mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContractForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _contractorNameController,
          label: "Contractor Name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _estimatedAmountController,
          label: "Total Estimated Amount",
          icon: Icons.attach_money,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _paidAmountController,
          label: "Paid Amount (Today)",
          icon: Icons.payments_outlined,
          inputType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDailyForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Labourers",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Add Labourer Input
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: _labourerNameController,
                label: "Name",
                icon: Icons.person_add_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _labourerWageController,
                label: "Wage",
                icon: Icons.money,
                inputType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _addLabourer,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Added Labourers
        if (_labourers.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: _labourers.asMap().entries.map((entry) {
                final index = entry.key;
                final labourer = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          (labourer['name'] as String)[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          labourer['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        "₹${labourer['wage']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _removeLabourer(index),
                        child: const Icon(
                          Icons.remove_circle_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),
        // Total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Daily Wage:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${_calculateDailyTotal().toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
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
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date == null
                        ? "Select"
                        : DateFormat('dd MMM, yy').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
}
