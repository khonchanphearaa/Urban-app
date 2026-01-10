import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A cool icon with a background circle
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColors.accentRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),
            // A stylish Retry button
            SizedBox(
              width: 160,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: onRetry,
                child: const Text("Refresh App"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}