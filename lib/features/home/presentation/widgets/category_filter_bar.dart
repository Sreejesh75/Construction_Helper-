import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/constants/material_categories.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ["All", ...MaterialCategories.all];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Remove padding here as the parent usually handles horizontal padding
        // or keep consistent with previous implementation?
        // Previous had padding: const EdgeInsets.symmetric(horizontal: 20)
        // Since we are moving this inside the column which already has padding in the new layout (potentially),
        // let's check the usage.
        // In DashboardScreen, it was used inside a Column.
        // If we remove the white container, we might want this list to be edge-to-edge or padded?
        // Let's keep the padding for now to match exactly what it was, but maybe make it adjustable.
        // Actually, the previous implementation had padding inside the ListView.
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
