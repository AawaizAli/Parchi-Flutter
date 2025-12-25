import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colours.dart';
import '../../../models/redemption_model.dart';
// import '../../../widgets/custom_button.dart'; // Ensure this exists or use ElevatedButton

class RedemptionDetailScreen extends StatelessWidget {
  final RedemptionModel redemption;

  const RedemptionDetailScreen({super.key, required this.redemption});

  @override
  Widget build(BuildContext context) {
    // Formatters
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');

    // Color logic based on status
    Color statusColor;
    IconData statusIcon;
    switch (redemption.status.toUpperCase()) {
      case 'APPROVED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.primary;
        statusIcon = Icons.hourglass_top;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Redemption Details',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        redemption.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transaction ID: ...${redemption.id.substring(redemption.id.length - 8)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Offer Details Card
            const Text("Offer Details",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  if (redemption.offer?.imageUrl != null)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        redemption.offer!.imageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(height: 10),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          redemption.offer?.title ?? "Unknown Offer",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.store,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              redemption.branchName ??
                                  redemption.offer?.merchant?.businessName ??
                                  "Mergechant",
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Transaction Details
            const Text("Transaction Details",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildRow(
                      "Date", dateFormatter.format(redemption.redeemedAt)),
                  _buildDivider(),
                  _buildRow(
                      "Time", timeFormatter.format(redemption.redeemedAt)),
                  _buildDivider(),
                  if (redemption.verifiedBy != null)
                    _buildRow("Verified By",
                        "Staff"), // ID is not user friendly, show "Staff" or similar
                  if (redemption.isBonusApplied) ...[
                    _buildDivider(),
                    _buildRow("Bonus Applied", "Yes",
                        valueColor: AppColors.success),
                    _buildDivider(),
                    _buildRow("Extra Discount",
                        "Rs. ${redemption.bonusDiscountApplied}",
                        valueColor: AppColors.success),
                  ],
                ],
              ),
            ),

            if (redemption.notes != null && redemption.notes!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text("Notes",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.1)),
                ),
                child: Text(
                  redemption.notes!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 16, color: AppColors.textSecondary.withOpacity(0.1));
}
