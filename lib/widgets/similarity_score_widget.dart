import 'package:flutter/material.dart';

class SimilarityScoreWidget extends StatelessWidget {
  final double similarityScore;
  final double size;

  const SimilarityScoreWidget({
    super.key,
    required this.similarityScore,
    this.size = 16.0,
  });

  Color _getScoreColor() {
    if (similarityScore >= 90) {
      return Colors.green;
    } else if (similarityScore >= 80) {
      return Colors.lightGreen;
    } else if (similarityScore >= 70) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getScoreColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getScoreColor(),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: size,
            color: _getScoreColor(),
          ),
          const SizedBox(width: 4),
          Text(
            '${similarityScore.toStringAsFixed(0)}% match',
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(),
            ),
          ),
        ],
      ),
    );
  }
}

