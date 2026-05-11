import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String recordLabel;

  const DeleteConfirmDialog({super.key, required this.recordLabel});

  static Future<bool?> show(BuildContext context, {required String recordLabel}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(recordLabel: recordLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('删除$recordLabel'),
      content: Text('确定要删除这条$recordLabel吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除'),
        ),
      ],
    );
  }
}
