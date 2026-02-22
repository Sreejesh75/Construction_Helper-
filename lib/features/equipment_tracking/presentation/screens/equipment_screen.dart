import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/equipment_bloc.dart';
import '../../bloc/equipment_event.dart';
import '../../bloc/equipment_state.dart';
import 'add_equipment_screen.dart';
import 'equipment_detail_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final String projectId;

  const EquipmentScreen({super.key, required this.projectId});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EquipmentBloc>().add(LoadEquipment(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    // Fallback primary color if local theme isn't explicitly defined
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Equipment & Machinery',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<EquipmentBloc, EquipmentState>(
        listener: (context, state) {
          if (state is EquipmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EquipmentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EquipmentLoaded) {
            if (state.equipmentList.isEmpty) {
              return Center(
                child: Text(
                  'No equipment added yet.',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.equipmentList.length,
              itemBuilder: (context, index) {
                final equipment = state.equipmentList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.precision_manufacturing,
                        color: primaryColor,
                      ),
                    ),
                    title: Text(
                      equipment.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Type: ${equipment.type}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Rate: ₹${equipment.rentalRate} ${equipment.rentalUnit}',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EquipmentDetailScreen(equipment: equipment),
                        ),
                      ).then((_) {
                        // Refresh when returning
                        context.read<EquipmentBloc>().add(
                          LoadEquipment(widget.projectId),
                        );
                      });
                    },
                  ),
                );
              },
            );
          }
          // Default state while loading maybe fallback to previous items if persisting
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEquipmentScreen(projectId: widget.projectId),
            ),
          ).then((_) {
            context.read<EquipmentBloc>().add(LoadEquipment(widget.projectId));
          });
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Equipment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}
