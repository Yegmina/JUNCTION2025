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
    // For 80+ scores, use green (Wolt primary green)
    final bool isHighScore = similarityScore >= 80;
    final Color badgeColor = isHighScore ? const Color(0xFF00C853) : 
                            similarityScore >= 70 ? Colors.orange : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16), // More oval shape
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighScore)
            Icon(
              Icons.check_circle,
              size: size * 0.9,
              color: Colors.white,
            ),
          if (isHighScore) const SizedBox(width: 4),
          Text(
            '${similarityScore.toStringAsFixed(0)}% match',
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

