import 'dart:async';

import 'package:flutter/material.dart';

class SocialShareAction {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final FutureOr<void> Function() onTap;

  const SocialShareAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
}

Future<void> showSocialShareSheet({
  required BuildContext context,
  String title = 'Compartir',
  required List<SocialShareAction> actions,
}) async {
  if (actions.isEmpty) return;

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                title,
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final action in actions)
                    _SocialShareChip(
                      icon: action.icon,
                      iconColor: action.iconColor,
                      label: action.label,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await action.onTap();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SocialShareChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _SocialShareChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
