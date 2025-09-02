import 'package:flutter/material.dart';

class ContentTextInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onChanged;

  const ContentTextInput({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내용',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: cs.surface),
          child: Column(
            children: [
              TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                maxLines: null,
                minLines: 6,
                maxLength: maxLength,
                decoration: const InputDecoration(
                  hintText: '오늘 있었던 일을 자유롭게 작성해보세요',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildTextCounter(context)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextCounter(BuildContext context) {
    final currentLength = controller.text.length;
    final isOverLimit = currentLength > maxLength;

    return Text(
      '$currentLength/$maxLength',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: isOverLimit
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
