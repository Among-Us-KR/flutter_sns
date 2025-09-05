import 'package:flutter/material.dart';

class CollapsedAvatar extends StatelessWidget {
  final String? imageUrl;
  const CollapsedAvatar({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 28,
          height: 28,
          child: imageUrl != null
              ? Image.network(imageUrl!, fit: BoxFit.cover)
              : const Icon(Icons.person, size: 18),
        ),
      ),
    );
  }
}

class StatDot extends StatelessWidget {
  const StatDot({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cs.onSurfaceVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}

class StatInline extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final int value;

  const StatInline({
    super.key,
    required this.theme,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: '$value',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
