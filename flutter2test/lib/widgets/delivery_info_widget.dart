import 'package:flutter/material.dart';

class DeliveryInfoWidget extends StatelessWidget {
  final int deliveryTimeMinutes;
  final double distanceKm;

  const DeliveryInfoWidget({
    super.key,
    required this.deliveryTimeMinutes,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$deliveryTimeMinutes min',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.location_on,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${distanceKm.toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

