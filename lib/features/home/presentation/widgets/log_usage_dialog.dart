import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

class LogUsageDialog extends StatefulWidget {
  final Map<String, dynamic> material;
  final Function(double quantity, String remark) onLogUsage;

  const LogUsageDialog({
    super.key,
    required this.material,
    required this.onLogUsage,
  });

  @override
  State<LogUsageDialog> createState() => _LogUsageDialogState();
}

class _LogUsageDialogState extends State<LogUsageDialog> {
  final _quantityController = TextEditingController();
  final _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final qty = double.parse(_quantityController.text);
      widget.onLogUsage(qty, _remarkController.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qty = (widget.material['quantity'] ?? 0).toDouble();
    final usedQty = (widget.material['usedQuantity'] ?? 0).toDouble();
    final pendingQty = qty - usedQty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Log Usage (${widget.material['name']})",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pending Stock:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "$pendingQty ${widget.material['unit'] ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Quantity Used",
                hintText: "Enter amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter quantity";
                final val = double.tryParse(value);
                if (val == null || val <= 0) return "Valid quantity required";
                if (val > pendingQty) return "Exceeds pending stock";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: "Remark (Optional)",
                hintText: "E.g., Used for foundation",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: Colors.white,
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
