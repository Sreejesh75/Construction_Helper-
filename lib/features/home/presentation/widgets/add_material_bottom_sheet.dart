import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/material_categories.dart';
import '../../../../core/theme/app_color.dart';

class AddMaterialBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? material;

  const AddMaterialBottomSheet({super.key, this.material});

  @override
  State<AddMaterialBottomSheet> createState() => _AddMaterialBottomSheetState();
}

class _AddMaterialBottomSheetState extends State<AddMaterialBottomSheet> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplierController = TextEditingController();

  DateTime? _date = DateTime.now();

  // Update initState to initialize _priceController with total price (unit price * quantity)
  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameController.text = widget.material!['name'] ?? '';
      _categoryController.text = widget.material!['category'] ?? '';

      final quantity =
          double.tryParse((widget.material!['quantity'] ?? '').toString()) ??
          0.0;
      final unitPrice =
          double.tryParse((widget.material!['price'] ?? '').toString()) ?? 0.0;

      _quantityController.text = (widget.material!['quantity'] ?? '')
          .toString();
      _unitController.text = widget.material!['unit'] ?? '';

      // Calculate and set total price for display
      final totalPrice = unitPrice * quantity;

      // Use modulus to check if it's an integer value effectively (e.g., 200.0 -> 200)
      if (totalPrice % 1 == 0) {
        _priceController.text = totalPrice.toInt().toString();
      } else {
        _priceController.text = totalPrice.toString();
      }

      _supplierController.text = widget.material!['supplier'] ?? '';
      try {
        _date = DateTime.tryParse(widget.material!['date'] ?? '');
      } catch (_) {}
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
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
        _date = date;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.material != null;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Material" : "Add Material",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: "Material Name",
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value:
                            _categoryController.text.isNotEmpty &&
                                MaterialCategories.all.contains(
                                  _categoryController.text,
                                )
                            ? _categoryController.text
                            : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.category_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          labelText: "Category",
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          isDense: true,
                        ),
                        items: MaterialCategories.all.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoryController.text = newValue!;
                          });
                        },
                        hint: const Text(
                          "Select Category",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      label: "Date",
                      date: _date,
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _quantityController,
                      label: "Qty",
                      icon: Icons.numbers,
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _unitController,
                      label: "Unit",
                      icon: Icons.scale_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: "Total Price",
                icon: Icons.attach_money,
                inputType: TextInputType.number,
                prefixText: "₹ ",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _supplierController,
                label: "Supplier (Optional)",
                icon: Icons.local_shipping_outlined,
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
                  onPressed: _saveMaterial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? "Update Material" : "Add Material",
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
          icon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          isDense: true,
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

  // Update _saveMaterial to calculate unit price before saving
  void _saveMaterial() {
    final category = _categoryController.text.trim();
    if (_nameController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please fill required fields (Name, Qty, Price, Date)",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Strict Category Validation
    if (!MaterialCategories.all.contains(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Invalid category '$category'. Please select one from the list.",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final quantity = double.parse(_quantityController.text.trim());
      final totalPrice = double.parse(_priceController.text.trim());

      // Calculate unit price to send to backend
      // Backend calculates spent as: unit_price * quantity
      // So we must store: unit_price = total_price / quantity
      double unitPrice = 0.0;
      if (quantity > 0) {
        unitPrice = totalPrice / quantity;
      }

      Navigator.pop(context, {
        "name": _nameController.text.trim(),
        "category": category,
        "quantity": quantity,
        "unit": _unitController.text.trim(),
        "price": unitPrice, // Sending calculated unit price
        "supplier": _supplierController.text.trim(),
        "date": _date!.toIso8601String(),
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid numeric values")));
    }
  }
}
