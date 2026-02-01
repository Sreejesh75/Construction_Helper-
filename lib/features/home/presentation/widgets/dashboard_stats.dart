import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_color.dart';

class DashboardStats extends StatelessWidget {
  final int totalProjects;
  final int activeProjects;
  final double totalBudget;
  final bool isSingleProject;

  const DashboardStats({
    super.key,
    required this.totalProjects,
    required this.activeProjects,
    required this.totalBudget,
    this.isSingleProject = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(
      locale: 'en_IN',
      name: '₹',
    );

    return SizedBox(
      height: 125, // Compact height
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          _StatCard(
            title: isSingleProject ? "Materials" : "Total",
            subtitle: isSingleProject ? "Count" : "Projects",
            value: totalProjects.toString(),
            icon: isSingleProject
                ? Icons.inventory_2_rounded
                : Icons.folder_copy_rounded,
            color: const Color(0xFF4A90E2), // Vibrant Blue
            delay: 0,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: isSingleProject ? "Spent" : "Active",
            subtitle: isSingleProject ? "Total" : "Ongoing",
            value: isSingleProject
                ? currencyFormat.format(activeProjects)
                : activeProjects.toString(),
            icon: isSingleProject
                ? Icons.money_off_csred_rounded
                : Icons.timelapse_rounded,
            color: const Color(0xFFF5A623), // Vibrant Orange
            delay: 100,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: "Budget",
            subtitle: "Total",
            value: currencyFormat.format(totalBudget),
            icon: Icons.monetization_on_rounded,
            color: AppColors.primary,
            isBudget: true,
            delay: 200,
          ),
          if (isSingleProject) ...[
            const SizedBox(width: 12),
            _StatCard(
              title: "Balance",
              subtitle: "Remaining",
              value: currencyFormat.format(totalBudget - activeProjects),
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF9B59B6), // Amethyst Purple
              isBudget: true,
              delay: 300,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final bool isBudget;
  final int delay;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    this.isBudget = false,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isBudget ? 140 : 110, // More compact width
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Smaller icon container
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20), // Smaller icon
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isBudget ? 15 : 18, // Adjusted font sizes
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, // Smaller title
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10, // Smaller subtitle
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
