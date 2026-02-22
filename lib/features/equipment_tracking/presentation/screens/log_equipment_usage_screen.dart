import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/equipment_model.dart';
import '../../bloc/equipment_bloc.dart';
import '../../bloc/equipment_event.dart';
import '../../bloc/equipment_state.dart';

class LogEquipmentUsageScreen extends StatefulWidget {
  final Equipment equipment;

  const LogEquipmentUsageScreen({super.key, required this.equipment});

  @override
  State<LogEquipmentUsageScreen> createState() =>
      _LogEquipmentUsageScreenState();
}

class _LogEquipmentUsageScreenState extends State<LogEquipmentUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _fuelCostController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _hoursController.dispose();
    _fuelAmountController.dispose();
    _fuelCostController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<EquipmentBloc>().add(
        AddEquipmentLogEvent(
          equipmentId: widget.equipment.id,
          date: _selectedDate,
          hoursUsed: double.tryParse(_hoursController.text) ?? 0.0,
          fuelConsumed: double.tryParse(_fuelAmountController.text) ?? 0.0,
          fuelCost: double.tryParse(_fuelCostController.text) ?? 0.0,
          remarks: _remarksController.text.trim(),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log Usage: ${widget.equipment.name}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<EquipmentBloc, EquipmentState>(
        listener: (context, state) {
          if (state is EquipmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back after success
          } else if (state is EquipmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: primaryColor.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate: ₹${widget.equipment.rentalRate} ${widget.equipment.rentalUnit}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.equipment.fuelType != 'None')
                          Text(
                            'Fuel Type: ${widget.equipment.fuelType}',
                            style: GoogleFonts.poppins(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date of Usage',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                if (widget.equipment.rentalUnit == 'Per Hour')
                  _buildTextField(
                    controller: _hoursController,
                    label: 'Hours Used',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                if (widget.equipment.rentalUnit == 'Per Hour')
                  const SizedBox(height: 16),

                if (widget.equipment.fuelType != 'None') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _fuelAmountController,
                          label: 'Fuel (Liters)',
                          icon: Icons.local_gas_station,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _fuelCostController,
                          label: 'Fuel Cost (₹)',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: _remarksController,
                  label: 'Remarks (Optional)',
                  icon: Icons.notes,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Log',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
