import 'package:flutter/material.dart';

/// 通用信息行组件
class InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  final double labelWidth;

  const InfoRow({
    super.key,
    required this.label,
    required this.child,
    this.labelWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
