import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/equipment_model.dart';
import '../../bloc/equipment_bloc.dart';
import '../../bloc/equipment_event.dart';
import '../../bloc/equipment_state.dart';
import 'log_equipment_usage_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EquipmentBloc>().add(LoadEquipmentLogs(widget.equipment.id));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.equipment.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Type', widget.equipment.type),
                _buildDetailRow(
                  'Rental Rate',
                  '₹${widget.equipment.rentalRate} ${widget.equipment.rentalUnit}',
                ),
                _buildDetailRow('Fuel Type', widget.equipment.fuelType),
                _buildDetailRow('Status', widget.equipment.status),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Usage Logs',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<EquipmentBloc, EquipmentState>(
              builder: (context, state) {
                if (state is EquipmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EquipmentLogsLoaded) {
                  if (state.logs.isEmpty) {
                    return Center(
                      child: Text(
                        'No logs found for this equipment.',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.logs.length,
                    itemBuilder: (context, index) {
                      final log = state.logs[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(log.date),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Total: ₹${log.totalCost}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              if (widget.equipment.rentalUnit ==
                                  'Per Hour') ...[
                                Text(
                                  'Hours Used: ${log.hoursUsed}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],

                              Text(
                                'Rental Cost: ₹${log.rentalCost}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),

                              if (log.fuelCost > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Fuel: ${log.fuelConsumed}L (₹${log.fuelCost})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],

                              if (log.remarks.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Remarks: ${log.remarks}',
                                  style: GoogleFonts.poppins(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is EquipmentError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LogEquipmentUsageScreen(equipment: widget.equipment),
            ),
          ).then((_) {
            context.read<EquipmentBloc>().add(
              LoadEquipmentLogs(widget.equipment.id),
            );
          });
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: Text(
          'Log Usage',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
