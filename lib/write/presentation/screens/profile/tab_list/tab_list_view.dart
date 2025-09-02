import 'package:flutter/material.dart';
import 'empty_state.dart';

class TabListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String emptyMessage;
  final IconData? emptyIcon;

  const TabListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.emptyMessage,
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(message: emptyMessage, icon: emptyIcon);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]), // <- 래핑
      separatorBuilder: (context, _) => Divider(
        height: 1, // 추가 여백 없이 1px만 차지
        thickness: 1, // 선 두께
        color: Theme.of(context).colorScheme.outlineVariant, // 회색(테마 기반)
      ),
    );
  }
}
