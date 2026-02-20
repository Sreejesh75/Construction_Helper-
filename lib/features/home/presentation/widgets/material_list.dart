import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';

class MaterialList extends StatelessWidget {
  final List<dynamic> materials;
  final Function(Map<String, dynamic> material) onEdit;
  final Function(Map<String, dynamic> material) onDelete;
  final Function(Map<String, dynamic> material)? onHistory;
  final Function(
    Map<String, dynamic> material,
    double quantityUsed,
    String remark,
  )?
  onLogUsage;

  const MaterialList({
    super.key,
    required this.materials,
    required this.onEdit,
    required this.onDelete,
    this.onHistory,
    this.onLogUsage,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No materials added yet",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: materials.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final material = materials[index];
        final unitPrice = (material['price'] ?? 0).toDouble();
        final qty = (material['quantity'] ?? 0).toDouble();
        final unit = material['unit'] ?? '';

        final usedQty = (material['usedQuantity'] ?? 0).toDouble();
        final pendingQty = qty - usedQty;
        final usageRatio = qty > 0 ? (usedQty / qty).clamp(0.0, 1.0) : 0.0;
        final isLowStock = pendingQty <= (qty * 0.2); // 20% threshold

        // Calculate total price for display
        final totalPrice = unitPrice * qty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLowStock
                  ? Colors.red.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              width: isLowStock ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isLowStock
                    ? Colors.red.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLowStock
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2,
                color: isLowStock ? Colors.red : AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    material['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Low Stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${pendingQty % 1 == 0 ? pendingQty.toInt() : pendingQty} $unit pending",
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${qty % 1 == 0 ? qty.toInt() : qty} total",
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usageRatio,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLowStock ? Colors.red : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      material['category'] ?? '',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                    if (material['date'] != null)
                      Text(
                        DateFormat(
                          'd MMM, y',
                        ).format(DateTime.parse(material['date'])),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${totalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(material);
                      } else if (value == 'delete') {
                        onDelete(material);
                      } else if (value == 'history' && onHistory != null) {
                        onHistory!(material);
                      } else if (value == 'log_usage' && onLogUsage != null) {
                        onLogUsage!(material, 0, ''); // handled via dialog
                      }
                    },
                    itemBuilder: (context) => [
                      if (onLogUsage != null)
                        const PopupMenuItem(
                          value: 'log_usage',
                          child: Text('Log Usage'),
                        ),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (onHistory != null)
                        const PopupMenuItem(
                          value: 'history',
                          child: Text('History'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
