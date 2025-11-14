import 'package:flutter/material.dart';

class ShareMenuWidget extends StatelessWidget {
  final VoidCallback? onWoltSelected;
  final VoidCallback? onDismiss;

  const ShareMenuWidget({
    super.key,
    this.onWoltSelected,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Share to',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // App grid
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                children: [
                  _ShareAppIcon(
                    icon: Icons.message,
                    label: 'Messages',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.email,
                    label: 'Email',
                    color: Colors.grey,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.link,
                    label: 'Copy Link',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.restaurant,
                    label: 'Wolt',
                    color: const Color(0xFF00C853), // Wolt green
                    onTap: onWoltSelected,
                    isHighlighted: true,
                  ),
                  _ShareAppIcon(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: Colors.blue[700]!,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.chat_bubble,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _ShareAppIcon(
                    icon: Icons.more_horiz,
                    label: 'More',
                    color: Colors.grey,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareAppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const _ShareAppIcon({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? color.withOpacity(0.15)
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: isHighlighted
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

