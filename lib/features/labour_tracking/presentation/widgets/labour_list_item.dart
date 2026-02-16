import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';
import '../../data/labour_model.dart';

class LabourListItem extends StatelessWidget {
  final Labour labour;

  const LabourListItem({super.key, required this.labour});

  @override
  Widget build(BuildContext context) {
    final bool isContract = labour.mode == 'contract';
    final double amount = isContract
        ? (labour.contractDetails?.paidAmount ?? 0.0)
        : (labour.dailyLabourDetails?.totalAmount ?? 0.0);

    final String title = isContract
        ? (labour.contractDetails?.contractorName ?? 'Unknown Contractor')
        : "Daily Wage (${labour.dailyLabourDetails?.labourers.length ?? 0} Workers)";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isContract ? Colors.orange : Colors.blue).withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isContract
                  ? Icons.business_center_outlined
                  : Icons.engineering_outlined,
              color: isContract ? Colors.orange : Colors.blue,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMM, y').format(labour.date),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            "₹${amount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  if (isContract && labour.contractDetails != null) ...[
                    _buildDetailRow(
                      "Estimated Amount",
                      "₹${labour.contractDetails!.estimatedAmount}",
                    ),
                    _buildDetailRow(
                      "Paid Today",
                      "₹${labour.contractDetails!.paidAmount}",
                      isBold: true,
                    ),
                  ],
                  if (!isContract && labour.dailyLabourDetails != null) ...[
                    const Text(
                      "Labourers:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...labour.dailyLabourDetails!.labourers.map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.name,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              "₹${l.wage}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      "Total for Day",
                      "₹${labour.dailyLabourDetails!.totalAmount}",
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isBold ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
