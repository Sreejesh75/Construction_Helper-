import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../data/labour_api_service.dart';
import '../../bloc/labour_bloc.dart';
import '../../bloc/labour_event.dart';
import '../../bloc/labour_state.dart';
import '../../data/labour_model.dart';
import '../widgets/add_labour_sheet.dart';
import '../widgets/labour_list_item.dart';

class LabourScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const LabourScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LabourBloc(LabourApiService())..add(LoadLabourRecords(projectId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "$projectName Labour",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<LabourBloc, LabourState>(
          listener: (context, state) {
            if (state is LabourOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is LabourError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LabourLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is LabourLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummarySection(state),
                    const SizedBox(height: 24),

                    // List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "History",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: state.selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              context.read<LabourBloc>().add(
                                FilterLabourByDate(pickedDate),
                              );
                            } else if (state.selectedDate != null) {
                              // Optional: If user cancels, do we clear?
                              // Usually no, but we might want a "Clear" option.
                              // Let's look at the UI. A separate clear button might be needed if date is selected.
                            }
                          },
                          icon: Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: state.selectedDate != null
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          label: Text(
                            state.selectedDate != null
                                ? "${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}"
                                : "Filter Date",
                            style: TextStyle(
                              color: state.selectedDate != null
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        if (state.selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              context.read<LabourBloc>().add(
                                const FilterLabourByDate(null),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (state.filteredRecords.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            state.selectedDate != null
                                ? "No records found for this date"
                                : "No labour records found",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.filteredRecords.length,
                        itemBuilder: (context, index) {
                          return LabourListItem(
                            labour: state.filteredRecords[index],
                          );
                        },
                      ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Something went wrong"));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddLabourSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Labour",
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(LabourLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: "Total Paid",
            subtitle: "(Contract)",
            amount: state.totalContractPaid,
            color: Colors.orange,
            icon: Icons.business_center,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: "Total Wages",
            subtitle: "(Daily)",
            amount: state.totalDailyWage,
            color: Colors.blue,
            icon: Icons.engineering,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                // To prevent overflow if text is long
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLabourSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddLabourSheet(),
    );

    if (result != null && result is Map<String, dynamic>) {
      // Convert JSON to Model
      // We need to add projectId to the result map before creating model
      final data = Map<String, dynamic>.from(result);
      data['projectId'] = projectId;
      // The API/Model expects fully structured data.
      // The sheet returns partial structure (contractDetails or dailyLabourDetails).
      // We need to construct the Labour object carefully.

      // Actually, the sheet returns:
      // { mode: '...', date: '...', contractDetails: {...} OR dailyLabourDetails: {...} }
      // This matches Labour.fromJson expectation mostly, except projectId.

      // Wait, Labour.fromJson expects 'projectId'.
      // So adding it is correct.

      try {
        final labour = Labour.fromJson(data);
        context.read<LabourBloc>().add(AddLabourRecord(labour));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error processing data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
