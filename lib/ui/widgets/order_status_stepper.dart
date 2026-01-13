import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrderStatusStepper extends StatelessWidget {
  final int currentStep; // 0: Received, 1: Preparing, 2: On The Way, 3: Delivered

  const OrderStatusStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildStep(0, 'Sipariş\nAlındı', Icons.receipt_long),
            _buildConnector(0),
            _buildStep(1, 'Hazırlanıyor', Icons.restaurant),
            _buildConnector(1),
            _buildStep(2, 'Yolda', Icons.delivery_dining),
            _buildConnector(2),
            _buildStep(3, 'Teslim\nEdildi', Icons.check_circle),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(int step, String label, IconData icon) {
    final isCompleted = currentStep >= step;
    final isActive = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCompleted
                  ? AppColors.primaryGradient
                  : null,
              color: isCompleted ? null : AppColors.cardBackground,
              border: Border.all(
                color: isActive
                    ? AppColors.primaryRed
                    : isCompleted
                        ? AppColors.primaryRed
                        : AppColors.lightCard,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isCompleted ? AppColors.primaryText : AppColors.secondaryText,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isCompleted ? AppColors.primaryText : AppColors.secondaryText,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int step) {
    final isCompleted = currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? AppColors.primaryGradient
              : null,
          color: isCompleted ? null : AppColors.lightCard,
        ),
      ),
    );
  }
}
