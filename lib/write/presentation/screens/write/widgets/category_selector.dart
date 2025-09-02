import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((c) {
            final selected = selectedCategory == c;
            return Semantics(
              label: '$c 카테고리${selected ? " 선택됨" : ""}',
              hint: '탭하여 ${selected ? "선택 해제" : "선택"}',
              child: ChoiceChip(
                label: Text(c, style: theme.textTheme.titleSmall),
                selected: selected,
                onSelected: (_) => onCategorySelected(c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: selected ? cs.primary : cs.outline),
                ),
                selectedColor: cs.primary.withOpacity(.10),
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  color: selected
                      ? cs.primary
                      : theme.textTheme.titleSmall?.color,
                  fontWeight: FontWeight.w600,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
